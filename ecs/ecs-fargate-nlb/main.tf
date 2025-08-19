// Security groups
module "sg_task_fargate" {
  source = "../../sg"


  layer    = var.layer
  stack_id = var.stack_id
  // configuration sg
  name    = "task-fargate"
  vpc_id  = var.vpc_id
  ingress = var.ingress
  egress  = var.egress
  // TAGS
  tags = var.tags
}

# ECS task execution role data
data "aws_iam_policy_document" "ecs_task_execution_role" {
  version = "2012-10-17"
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# ECS task execution role
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "myEcsTaskExecutionRole_${var.layer}_${var.stack_id}"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role.json
}

# ECS task execution role policy attachment
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_ssm" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}

resource "aws_iam_role_policy_attachment" "ecs_secretmanager" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

resource "aws_iam_role_policy_attachment" "ecs_s3" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

module "ecr" {
  source = "../../ecr"

  count = length(var.ecs_fargate)

  layer    = var.layer
  stack_id = var.stack_id
  //Configuration ECR
  ecr_repository = {
    name                 = "${lookup(element(var.ecs_fargate, count.index), "ecr_repository")}"
    image_tag_mutability = "MUTABLE"
  }
  // TAGS
  tags = var.tags
}

resource "aws_lb_target_group" "app" {
  count = length(var.ecs_fargate)

  name        = replace(substr(replace("tg-${lookup(element(var.ecs_fargate, count.index), "ecr_repository")}-${var.stack_id}-${var.layer}", "_", "-"), 0, 31), "/-$/", "")
  port        = lookup(element(var.ecs_fargate, count.index), "port")
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    protocol            = "HTTP" # O "HTTPS"
    port                = lookup(element(var.ecs_fargate, count.index), "port")
    path                = lookup(element(var.ecs_fargate, count.index), "health_check_path")
    matcher             = lookup(element(var.ecs_fargate, count.index), "matcher", "200")
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 10
  }
}

# Redirect all traffic from the ELB to the target group
resource "aws_lb_listener" "lb_listener" {

  count = length(var.ecs_fargate)

  load_balancer_arn = var.lb_id
  port              = lookup(element(var.ecs_fargate, count.index), "port")
  protocol          = "TCP"

  default_action {
    type             = lookup(element(var.listener_rule_fargate, count.index), "type", "forward")
    target_group_arn = element(aws_lb_target_group.app.*.id, lookup(element(var.listener_rule_fargate, count.index), "target_group", 1))
  }
}

resource "aws_ecs_task_definition" "app" {
  count = length(var.ecs_fargate)

  family                   = replace("task-${lookup(element(var.ecs_fargate, count.index), "ecr_repository")}-${var.stack_id}", "_", "-")
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = lookup(element(var.ecs_fargate, count.index), "cpu")
  memory                   = lookup(element(var.ecs_fargate, count.index), "memory")

  container_definitions = templatefile(lookup(element(var.ecs_fargate, count.index), "templatefile"),
    merge(lookup(element(var.ecs_fargate, count.index), "extra_environments", {}),
      {
        stack_id       = var.stack_id
        region         = var.region
        name           = "container-${lookup(element(var.ecs_fargate, count.index), "ecr_repository")}-${var.stack_id}"
        name_logsgroup = "/ecs/container_${lookup(element(var.ecs_fargate, count.index), "ecr_repository")}_${var.stack_id}"
        layer          = lookup(element(var.ecs_fargate, count.index), "ecr_repository")
        app_image      = "${element(module.ecr.*.ecr_reference.repository_url, count.index)}"
        fargate_cpu    = lookup(element(var.ecs_fargate, count.index), "cpu")
        fargate_memory = lookup(element(var.ecs_fargate, count.index), "memory")
        app_port       = lookup(element(var.ecs_fargate, count.index), "port")
        network_mode   = "awsvpc"
        aws_account_id = data.aws_caller_identity.current.account_id
      }
  ))

  dynamic "volume" {

    for_each = length(keys(var.efs)) != 0 && length(keys(lookup(element(var.ecs_fargate, count.index), "volume", {}))) != 0 ? [1] : []

    content {
      name = lookup(element(var.ecs_fargate, count.index), "extra_environments.sourceVolume", "efs")

      efs_volume_configuration {
        file_system_id          = lookup(var.efs, "file_system_id")
        root_directory          = lookup(element(var.ecs_fargate, count.index).volume, "root_directory", null)
        transit_encryption      = lookup(element(var.ecs_fargate, count.index).volume, "transit_encryption", null)
        transit_encryption_port = lookup(element(var.ecs_fargate, count.index).volume, "transit_encryption_port", null)
        authorization_config {
          access_point_id = lookup(var.efs, "access_point_id")
          iam             = lookup(element(var.ecs_fargate, count.index).volume, "iam", "DISABLED")
        }
      }
    }

  }
}

resource "aws_ecs_service" "main" {
  count           = length(var.ecs_fargate)
  name            = replace("service-${lookup(element(var.ecs_fargate, count.index), "ecr_repository")}-${var.stack_id}", "_", "-")
  cluster         = var.ecs_cluster_reference.id
  task_definition = element(aws_ecs_task_definition.app.*.arn, count.index)
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [module.sg_task_fargate.sg_reference.id]
    subnets          = var.db_subnets_private
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = element(aws_lb_target_group.app.*.id, count.index)
    container_name   = "container-${lookup(element(var.ecs_fargate, count.index), "ecr_repository")}-${var.stack_id}"
    container_port   = lookup(element(var.ecs_fargate, count.index), "port")
  }

  depends_on = [aws_iam_role_policy_attachment.ecs_task_execution_role]
}

# auto_scaling.tf
resource "aws_appautoscaling_target" "target" {
  count              = length(var.ecs_fargate)
  service_namespace  = "ecs"
  resource_id        = "service/${var.ecs_cluster_reference.name}/${element(aws_ecs_service.main.*.name, count.index)}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = lookup(element(var.ecs_fargate, count.index), "min_capacity_fargate", 1)
  max_capacity       = lookup(element(var.ecs_fargate, count.index), "max_capacity_fargate", 1)
}

# Automatically scale capacity up by one CPU
resource "aws_appautoscaling_policy" "up_cpu" {
  count              = length(var.ecs_fargate)
  name               = "scale_up_cpu_${lookup(element(var.ecs_fargate, count.index), "ecr_repository")}_${var.layer}_${var.stack_id}"
  service_namespace  = "ecs"
  resource_id        = "service/${var.ecs_cluster_reference.name}/${element(aws_ecs_service.main.*.name, count.index)}"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }

  depends_on = [aws_appautoscaling_target.target]
}

# Automatically scale capacity down by one CPU
resource "aws_appautoscaling_policy" "down_cpu" {
  count              = length(var.ecs_fargate)
  name               = "scale_down_cpu_${lookup(element(var.ecs_fargate, count.index), "ecr_repository")}_${var.layer}_${var.stack_id}"
  service_namespace  = "ecs"
  resource_id        = "service/${var.ecs_cluster_reference.name}/${element(aws_ecs_service.main.*.name, count.index)}"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }

  depends_on = [aws_appautoscaling_target.target]

}

# Automatically scale capacity up by one Memory
resource "aws_appautoscaling_policy" "up_memory" {
  count              = length(var.ecs_fargate)
  name               = "scale_up_memory_${lookup(element(var.ecs_fargate, count.index), "ecr_repository")}_${var.layer}_${var.stack_id}"
  service_namespace  = "ecs"
  resource_id        = "service/${var.ecs_cluster_reference.name}/${element(aws_ecs_service.main.*.name, count.index)}"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }

  depends_on = [aws_appautoscaling_target.target]

}

# Automatically scale capacity down by one Memory
resource "aws_appautoscaling_policy" "down_memory" {
  count              = length(var.ecs_fargate)
  name               = "scale_down_memory_${lookup(element(var.ecs_fargate, count.index), "ecr_repository")}_${var.layer}_${var.stack_id}"
  service_namespace  = "ecs"
  resource_id        = "service/${var.ecs_cluster_reference.name}/${element(aws_ecs_service.main.*.name, count.index)}"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }

  depends_on = [aws_appautoscaling_target.target]

}

#CloudWatch alarm that triggers the autoscaling up policy CPU
resource "aws_cloudwatch_metric_alarm" "service_cpu_high" {
  count               = length(var.ecs_fargate)
  alarm_name          = "cpu_utilization_high_${lookup(element(var.ecs_fargate, count.index), "ecr_repository")}_${var.layer}_${var.stack_id}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "70"

  dimensions = {
    ClusterName = var.ecs_cluster_reference.name
    ServiceName = element(aws_ecs_service.main.*.name, count.index)
  }

  alarm_actions = [element(aws_appautoscaling_policy.up_cpu.*.arn, count.index)]
}

# CloudWatch alarm that triggers the autoscaling down policy CPU
resource "aws_cloudwatch_metric_alarm" "service_cpu_low" {
  count               = length(var.ecs_fargate)
  alarm_name          = "cpu_utilization_low_${lookup(element(var.ecs_fargate, count.index), "ecr_repository")}_${var.layer}_${var.stack_id}"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "50"

  dimensions = {
    ClusterName = var.ecs_cluster_reference.name
    ServiceName = element(aws_ecs_service.main.*.name, count.index)
  }

  alarm_actions = [element(aws_appautoscaling_policy.down_cpu.*.arn, count.index)]
}

# CloudWatch alarm that triggers the autoscaling up policy Memory
resource "aws_cloudwatch_metric_alarm" "service_memory_high" {
  count               = length(var.ecs_fargate)
  alarm_name          = "memory_utilization_high_${lookup(element(var.ecs_fargate, count.index), "ecr_repository")}_${var.layer}_${var.stack_id}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "70"

  dimensions = {
    ClusterName = var.ecs_cluster_reference.name
    ServiceName = element(aws_ecs_service.main.*.name, count.index)
  }

  alarm_actions = [element(aws_appautoscaling_policy.up_memory.*.arn, count.index)]
}

# CloudWatch alarm that triggers the autoscaling down policy Memory
resource "aws_cloudwatch_metric_alarm" "service_memory_low" {
  count               = length(var.ecs_fargate)
  alarm_name          = "memory_utilization_low_${lookup(element(var.ecs_fargate, count.index), "ecr_repository")}_${var.layer}_${var.stack_id}"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "50"

  dimensions = {
    ClusterName = var.ecs_cluster_reference.name
    ServiceName = element(aws_ecs_service.main.*.name, count.index)
  }

  alarm_actions = [element(aws_appautoscaling_policy.down_memory.*.arn, count.index)]
}

# # logs.tf
# # Set up CloudWatch group and log stream and retain logs for 30 days
resource "aws_cloudwatch_log_group" "cloudwatch_log_group" {
  count             = length(var.ecs_fargate)
  name              = "/ecs/container_${lookup(element(var.ecs_fargate, count.index), "ecr_repository")}_${var.stack_id}"
  retention_in_days = var.cloudwatch_log_retention

  tags = {
    Name   = "cloudwatch_log_${lookup(element(var.ecs_fargate, count.index), "ecr_repository")}_${var.stack_id}"
    Source = "Terraform"
  }
}

resource "aws_cloudwatch_log_stream" "cloudwatch_log_stream" {
  count          = length(var.ecs_fargate)
  name           = "my_log_stream_${lookup(element(var.ecs_fargate, count.index), "ecr_repository")}_${var.stack_id}"
  log_group_name = element(aws_cloudwatch_log_group.cloudwatch_log_group.*.name, count.index)
}

