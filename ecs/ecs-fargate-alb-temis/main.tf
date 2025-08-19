locals {
  # Transforma la lista de mapas en un mapa de mapas
  ecs_fargate_map = {
    for service in var.ecs_fargate :
    service.ecr_repository => service
  }
}


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

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
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

  for_each = local.ecs_fargate_map

  layer    = var.layer
  stack_id = var.stack_id
  //Configuration ECR
  ecr_repository = {
    name                 = each.key
    image_tag_mutability = "MUTABLE"
  }
  // TAGS
  tags = var.tags
}

resource "aws_lb_target_group" "app" {
  for_each = local.ecs_fargate_map

  # Usamos each.key para el nombre
  name = replace(substr(replace("tg-${each.key}-${var.stack_id}-${var.layer}", "_", "-"), 0, 31), "/-$/", "")
  # Usamos each.value para acceder al resto de los datos
  port        = each.value.port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    protocol            = "HTTP"
    port                = each.value.port
    path                = each.value.health_check_path
    matcher             = lookup(each.value, "matcher", "200")
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 60
  }
}

# Redirect all traffic from the ELB to the target group
resource "aws_lb_listener" "lb_listener" {

  load_balancer_arn = var.lb_id
  port              = "80"
  protocol          = "HTTP"

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
  count = length(var.listener_rule_fargate)

  listener_arn = aws_lb_listener.lb_listener.arn
  priority     = count.index + 1

  dynamic "action" {
    for_each = lookup(element(var.listener_rule_fargate, count.index), "type") != "forward" ? [] : [0]
    content {
      type             = "forward"
      target_group_arn = values(aws_lb_target_group.app)[var.listener_rule_fargate[count.index].target_group].arn
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

resource "aws_ecs_task_definition" "app" {
  # Usamos for_each para iterar sobre el mapa de servicios
  for_each = local.ecs_fargate_map

  # each.key es el ecr_repository (la clave del mapa)
  family                   = replace("task-${each.key}-${var.stack_id}", "_", "-")
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  # each.value es el mapa completo del servicio actual
  cpu    = each.value.cpu
  memory = each.value.memory

  container_definitions = templatefile(each.value.templatefile,
    merge(lookup(each.value, "extra_environments", {}),
      {
        stack_id       = var.stack_id
        region         = var.region
        name           = "container-${each.key}-${var.stack_id}"
        name_logsgroup = "/ecs/container_${each.key}_${var.stack_id}"
        layer          = each.key # Usamos each.key para el layer (ecr_repository)
        # Referencia al módulo ECR por su llave
        app_image      = module.ecr[each.key].ecr_reference.repository_url
        fargate_cpu    = each.value.cpu
        fargate_memory = each.value.memory
        app_port       = each.value.port
        network_mode   = "awsvpc"
        aws_account_id = data.aws_caller_identity.current.account_id
      }
    )
  )

  dynamic "volume" {
    # El for_each para el bloque dinámico debe producir una lista para iterar.
    # Si var.efs existe Y el servicio actual (each.value) tiene una configuración de volumen,
    # entonces iteramos sobre una lista que contiene el mapa de configuración del volumen.
    for_each = length(keys(var.efs)) != 0 && length(keys(lookup(each.value, "volume", {}))) != 0 ? [each.value.volume] : []

    content {
      # Accedemos a los valores del volumen a través de volume.value
      name = lookup(each.value.extra_environments, "sourceVolume", "efs")

      efs_volume_configuration {
        file_system_id          = lookup(var.efs, "file_system_id")
        root_directory          = lookup(volume.value, "root_directory", null)
        transit_encryption      = lookup(volume.value, "transit_encryption", null)
        transit_encryption_port = lookup(volume.value, "transit_encryption_port", null)
        authorization_config {
          access_point_id = lookup(var.efs, "access_point_id")
          iam             = lookup(volume.value, "iam", "DISABLED")
        }
      }
    }
  }
}

resource "aws_ecs_service" "main" {
  for_each = local.ecs_fargate_map

  name                          = replace("service-${each.key}-${var.stack_id}", "_", "-")
  cluster                       = var.ecs_cluster_reference.id
  availability_zone_rebalancing = "ENABLED"
  # Referencia al task_definition por su llave
  task_definition = aws_ecs_task_definition.app[each.key].arn
  desired_count   = lookup(each.value, "min_capacity_fargate", 1)
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [module.sg_task_fargate.sg_reference.id]
    subnets          = var.db_subnets_private
    assign_public_ip = false
  }

  load_balancer {
    # Referencia al target_group por su llave
    target_group_arn = aws_lb_target_group.app[each.key].id
    container_name   = "container-${each.key}-${var.stack_id}"
    container_port   = each.value.port
  }

  depends_on = [aws_iam_role_policy_attachment.ecs_task_execution_role]
}

# auto_scaling.tf
resource "aws_appautoscaling_target" "target" {
  for_each = local.ecs_fargate_map

  service_namespace = "ecs"
  # Referencia al servicio ECS por su llave
  resource_id        = "service/${var.ecs_cluster_reference.name}/${aws_ecs_service.main[each.key].name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = lookup(each.value, "min_capacity_fargate", 1)
  max_capacity       = lookup(each.value, "max_capacity_fargate", 1)
}

# Automatically scale capacity up by one CPU
resource "aws_appautoscaling_policy" "up_cpu" {
  for_each = local.ecs_fargate_map

  name              = "scale_up_cpu_${each.key}_${var.layer}_${var.stack_id}"
  service_namespace = "ecs"
  # Referencia al servicio ECS por su llave
  resource_id        = "service/${var.ecs_cluster_reference.name}/${aws_ecs_service.main[each.key].name}"
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

  # Dependencia al target específico por su llave
  depends_on = [aws_appautoscaling_target.target]
}

# Automatically scale capacity down by one CPU
resource "aws_appautoscaling_policy" "down_cpu" {
  for_each = local.ecs_fargate_map

  name              = "scale_down_cpu_${each.key}_${var.layer}_${var.stack_id}"
  service_namespace = "ecs"
  # Referencia al servicio ECS por su llave
  resource_id        = "service/${var.ecs_cluster_reference.name}/${aws_ecs_service.main[each.key].name}"
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

  # Dependencia al target específico por su llave
  depends_on = [aws_appautoscaling_target.target]
}

# Automatically scale capacity up by one Memory
resource "aws_appautoscaling_policy" "up_memory" {
  for_each = local.ecs_fargate_map

  name              = "scale_up_memory_${each.key}_${var.layer}_${var.stack_id}"
  service_namespace = "ecs"
  # Referencia al servicio ECS por su llave
  resource_id        = "service/${var.ecs_cluster_reference.name}/${aws_ecs_service.main[each.key].name}"
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

  # Dependencia al target específico por su llave
  depends_on = [aws_appautoscaling_target.target]
}

# Automatically scale capacity down by one Memory
resource "aws_appautoscaling_policy" "down_memory" {
  for_each = local.ecs_fargate_map

  name              = "scale_down_memory_${each.key}_${var.layer}_${var.stack_id}"
  service_namespace = "ecs"
  # Referencia al servicio ECS por su llave
  resource_id        = "service/${var.ecs_cluster_reference.name}/${aws_ecs_service.main[each.key].name}"
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

  # Dependencia al target específico por su llave
  depends_on = [aws_appautoscaling_target.target]
}

#CloudWatch alarm that triggers the autoscaling up policy CPU
resource "aws_cloudwatch_metric_alarm" "service_cpu_high" {
  for_each = local.ecs_fargate_map

  alarm_name          = "cpu_utilization_high_${each.key}_${var.layer}_${var.stack_id}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "60"

  dimensions = {
    ClusterName = var.ecs_cluster_reference.name
    # Referencia al servicio ECS por su llave
    ServiceName = aws_ecs_service.main[each.key].name
  }

  # Referencia a la política de autoscaling por su llave
  alarm_actions = [aws_appautoscaling_policy.up_cpu[each.key].arn]
}

# CloudWatch alarm that triggers the autoscaling down policy CPU
resource "aws_cloudwatch_metric_alarm" "service_cpu_low" {
  for_each = local.ecs_fargate_map

  alarm_name          = "cpu_utilization_low_${each.key}_${var.layer}_${var.stack_id}"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "40"

  dimensions = {
    ClusterName = var.ecs_cluster_reference.name
    # Referencia al servicio ECS por su llave
    ServiceName = aws_ecs_service.main[each.key].name
  }

  # Referencia a la política de autoscaling por su llave
  alarm_actions = [aws_appautoscaling_policy.down_cpu[each.key].arn]
}

# CloudWatch alarm that triggers the autoscaling up policy Memory
resource "aws_cloudwatch_metric_alarm" "service_memory_high" {
  for_each = local.ecs_fargate_map

  alarm_name          = "memory_utilization_high_${each.key}_${var.layer}_${var.stack_id}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "60"

  dimensions = {
    ClusterName = var.ecs_cluster_reference.name
    # Referencia al servicio ECS por su llave
    ServiceName = aws_ecs_service.main[each.key].name
  }

  # Referencia a la política de autoscaling por su llave
  alarm_actions = [aws_appautoscaling_policy.up_memory[each.key].arn]
}

# CloudWatch alarm that triggers the autoscaling down policy Memory
resource "aws_cloudwatch_metric_alarm" "service_memory_low" {
  for_each = local.ecs_fargate_map

  alarm_name          = "memory_utilization_low_${each.key}_${var.layer}_${var.stack_id}"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "40"

  dimensions = {
    ClusterName = var.ecs_cluster_reference.name
    # Referencia al servicio ECS por su llave
    ServiceName = aws_ecs_service.main[each.key].name
  }

  # Referencia a la política de autoscaling por su llave
  alarm_actions = [aws_appautoscaling_policy.down_memory[each.key].arn]
}

# # logs.tf
# # Set up CloudWatch group and log stream and retain logs for 30 days
resource "aws_cloudwatch_log_group" "cloudwatch_log_group" {
  for_each = local.ecs_fargate_map

  name              = "/ecs/container_${each.key}_${var.stack_id}"
  retention_in_days = var.cloudwatch_log_retention

  tags = {
    Name   = "cloudwatch_log_${each.key}_${var.stack_id}"
    Source = "Terraform"
  }
}

resource "aws_cloudwatch_log_stream" "cloudwatch_log_stream" {
  for_each = local.ecs_fargate_map

  name = "my_log_stream_${each.key}_${var.stack_id}"
  # Referencia al log group por su llave
  log_group_name = aws_cloudwatch_log_group.cloudwatch_log_group[each.key].name
}
