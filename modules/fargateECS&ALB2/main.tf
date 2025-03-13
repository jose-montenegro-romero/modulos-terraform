
# ALB Security Group: Edit to restrict access to the application
resource "aws_security_group" "lb_fargate" {
  name        = "load_balancer_security_group_${var.layer}_${var.stack_id}"
  description = "controls access to the ALB"
  vpc_id      = var.vpc

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name   = "lb_fargate_${var.layer}_${var.stack_id}"
    Source = "Terraform"
  }
}

# Traffic to the ECS cluster should only come from the ALB
resource "aws_security_group" "ecs_tasks_fargate" {
  name        = "ecs_tasks_security_group_${var.layer}_${var.stack_id}"
  description = "allow inbound access from the ALB only"
  vpc_id      = var.vpc

  ingress {
    protocol        = "tcp"
    from_port       = 80
    to_port         = 80
    security_groups = [aws_security_group.lb_fargate.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name   = "ecs_task_fargate_${var.layer}_${var.stack_id}"
    Source = "Terraform"
  }
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

#Create ECR repository
resource "aws_ecr_repository" "ecr" {
  count                = length(var.ecs_fargate)
  name                 = "ecr_${lookup(element(var.ecs_fargate, count.index), "ecr_repository")}_${var.layer}_${var.stack_id}"
  image_tag_mutability = "MUTABLE"

  tags = {
    Name   = "ecr_${lookup(element(var.ecs_fargate, count.index), "ecr_repository")}_${var.layer}_${var.stack_id}"
    Source = "Terraform"
  }
}

# Create ALB
resource "aws_alb" "main" {
  name            = replace("alb_${var.layer}_${var.stack_id}", "_", "-")
  subnets         = var.db_subnets_public
  security_groups = [aws_security_group.lb_fargate.id]
}

resource "aws_alb_target_group" "app" {
  count       = length(var.ecs_fargate)
  name        = substr(replace("tg-${lookup(element(var.ecs_fargate, count.index), "ecr_repository")}-${var.stack_id}${var.layer}", "_", "-"), 0, 31)
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = lookup(element(var.ecs_fargate, count.index), "matcher", "200")
    timeout             = "10"
    path                = lookup(element(var.ecs_fargate, count.index), "health_check_path")
    unhealthy_threshold = "5"
  }

  dynamic "stickiness" {

    for_each = length(keys(lookup(element(var.ecs_fargate, count.index), "lb_target_group", {}))) != 0 ? [1] : []

    content {
      enabled         = lookup(element(var.ecs_fargate, count.index).lb_target_group.stickiness, "enabled", null)
      type            = lookup(element(var.ecs_fargate, count.index).lb_target_group.stickiness, "type", "lb_cookie")
      cookie_name     = lookup(element(var.ecs_fargate, count.index).lb_target_group.stickiness, "cookie_name", null)
      cookie_duration = lookup(element(var.ecs_fargate, count.index).lb_target_group.stickiness, "cookie_duration", null)
    }
  }
}

# Redirect all traffic from the ALB to the target group
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_alb.main.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "front_end_https" {

  count = var.certificate_arn != null ? 1 : 0

  load_balancer_arn = aws_alb.main.id
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not work"
      status_code  = "503"
    }
  }

}

resource "aws_lb_listener_rule" "static" {
  count        = length(var.listener_rule_fargate)
  listener_arn = var.certificate_arn != null ? aws_lb_listener.front_end_https[0].arn : aws_lb_listener.front_end.arn
  priority     = count.index + 1

  dynamic "action" {
    for_each = lookup(element(var.listener_rule_fargate, count.index), "type") != "forward" ? [] : [0]
    content {
      type             = "forward"
      target_group_arn = element(aws_alb_target_group.app.*.id, lookup(element(var.listener_rule_fargate, count.index), "target_group", 1))
    }
  }

  dynamic "action" {
    for_each = lookup(element(var.listener_rule_fargate, count.index), "type") != "redirect" ? [] : [0]
    content {
      type = "redirect"
      redirect {
        host        = "www.#{host}"
        port        = "#{port}"
        protocol    = "#{protocol}"
        path        = "/#{path}"
        query       = "#{query}"
        status_code = "HTTP_301"
      }
    }
  }

  dynamic "condition" {
    for_each = length(lookup(element(var.listener_rule_fargate, count.index), "host_header", [])) == 0 ? [] : [0]
    content {
      host_header {
        values = var.listener_rule_fargate[count.index].host_header
      }
    }
  }

  dynamic "condition" {
    for_each = length(lookup(element(var.listener_rule_fargate, count.index), "path_pattern", [])) == 0 ? [] : [0]
    content {
      path_pattern {
        values = var.listener_rule_fargate[count.index].path_pattern
      }
    }
  }
}

# Create ECS cluster
resource "aws_ecs_cluster" "main" {
  name = "cluster_${var.layer}_${var.stack_id}"
}

resource "aws_ecs_task_definition" "app" {
  count                    = length(var.ecs_fargate)
  family                   = "task_${lookup(element(var.ecs_fargate, count.index), "ecr_repository")}_${var.stack_id}"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = lookup(element(var.ecs_fargate, count.index), "cpu")
  memory                   = lookup(element(var.ecs_fargate, count.index), "memory")

  container_definitions = templatefile(lookup(element(var.ecs_fargate, count.index), "templatefile"), merge(var.extra_environments,
    {
      stack_id       = var.stack_id
      region         = var.region
      layer          = lookup(element(var.ecs_fargate, count.index), "ecr_repository")
      app_image      = "${element(aws_ecr_repository.ecr.*.repository_url, count.index)}:latest"
      fargate_cpu    = lookup(element(var.ecs_fargate, count.index), "cpu")
      fargate_memory = lookup(element(var.ecs_fargate, count.index), "memory")
      app_port       = lookup(element(var.ecs_fargate, count.index), "port")
    }
  ))

  dynamic "volume" {

    for_each = length(keys(var.efs)) != 0 && length(keys(lookup(element(var.ecs_fargate, count.index), "volume", {}))) != 0 ? [1] : []

    content {
      name = lookup(var.extra_environments, "sourceVolume", "efs")

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
  name            = "service_${lookup(element(var.ecs_fargate, count.index), "ecr_repository")}_${var.stack_id}"
  cluster         = aws_ecs_cluster.main.id
  task_definition = element(aws_ecs_task_definition.app.*.arn, count.index)
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks_fargate.id]
    subnets          = var.db_subnets_private
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = element(aws_alb_target_group.app.*.id, count.index)
    container_name   = "container_${lookup(element(var.ecs_fargate, count.index), "ecr_repository")}_${var.stack_id}"
    container_port   = lookup(element(var.ecs_fargate, count.index), "port")
  }

  depends_on = [aws_iam_role_policy_attachment.ecs_task_execution_role]
}

# auto_scaling.tf
resource "aws_appautoscaling_target" "target" {
  count              = length(var.ecs_fargate)
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.main.name}/${element(aws_ecs_service.main.*.name, count.index)}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = lookup(element(var.ecs_fargate, count.index), "min_capacity_fargate", 1)
  max_capacity       = lookup(element(var.ecs_fargate, count.index), "max_capacity_fargate", 1)
}

# Automatically scale capacity up by one CPU
resource "aws_appautoscaling_policy" "up_cpu" {
  count              = length(var.ecs_fargate)
  name               = "scale_up_cpu_${lookup(element(var.ecs_fargate, count.index), "ecr_repository")}_${var.layer}_${var.stack_id}"
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.main.name}/${element(aws_ecs_service.main.*.name, count.index)}"
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

  # depends_on = [element(aws_appautoscaling_target.*, count.index)]
}

# Automatically scale capacity down by one CPU
resource "aws_appautoscaling_policy" "down_cpu" {
  count              = length(var.ecs_fargate)
  name               = "scale_down_cpu_${lookup(element(var.ecs_fargate, count.index), "ecr_repository")}_${var.layer}_${var.stack_id}"
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.main.name}/${element(aws_ecs_service.main.*.name, count.index)}"
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
}

# Automatically scale capacity up by one Memory
resource "aws_appautoscaling_policy" "up_memory" {
  count              = length(var.ecs_fargate)
  name               = "scale_up_memory_${lookup(element(var.ecs_fargate, count.index), "ecr_repository")}_${var.layer}_${var.stack_id}"
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.main.name}/${element(aws_ecs_service.main.*.name, count.index)}"
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
}

# Automatically scale capacity down by one Memory
resource "aws_appautoscaling_policy" "down_memory" {
  count              = length(var.ecs_fargate)
  name               = "scale_down_memory_${lookup(element(var.ecs_fargate, count.index), "ecr_repository")}_${var.layer}_${var.stack_id}"
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.main.name}/${element(aws_ecs_service.main.*.name, count.index)}"
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
    ClusterName = aws_ecs_cluster.main.name
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
    ClusterName = aws_ecs_cluster.main.name
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
    ClusterName = aws_ecs_cluster.main.name
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
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = element(aws_ecs_service.main.*.name, count.index)
  }

  alarm_actions = [element(aws_appautoscaling_policy.down_memory.*.arn, count.index)]
}

# # logs.tf
# # Set up CloudWatch group and log stream and retain logs for 30 days
resource "aws_cloudwatch_log_group" "myapp_log_group" {
  count             = length(var.ecs_fargate)
  name              = "/ecs/container_${lookup(element(var.ecs_fargate, count.index), "ecr_repository")}_${var.stack_id}"
  retention_in_days = 7

  tags = {
    Name   = "cloudwatch_log_${lookup(element(var.ecs_fargate, count.index), "ecr_repository")}_${var.stack_id}"
    Source = "Terraform"
  }
}

resource "aws_cloudwatch_log_stream" "myapp_log_stream" {
  count          = length(var.ecs_fargate)
  name           = "my_log_stream_${lookup(element(var.ecs_fargate, count.index), "ecr_repository")}_${var.stack_id}"
  log_group_name = element(aws_cloudwatch_log_group.myapp_log_group.*.name, count.index)
}

