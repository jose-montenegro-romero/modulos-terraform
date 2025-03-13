#Create ALB por two ec2 Imaginex
resource "aws_security_group" "security_group_lb" {
  name        = "lb_security_group_${lookup(var.lb_definition, "name_lb")}_${var.layer}_${var.stack_id}"
  description = "controls access to the LB"
  vpc_id      = var.vpc

  dynamic "ingress" {

    for_each = lookup(var.lb_definition, "ingress")

    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  dynamic "egress" {

    for_each = lookup(var.lb_definition, "egress")

    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }

  tags = {
    Name   = "lb_${lookup(var.lb_definition, "name_lb")}_${var.layer}_${var.stack_id}"
    Source = "Terraform"
  }
}

resource "aws_lb" "main" {
  name                       = replace("lb_${lookup(var.lb_definition, "name_lb")}_${var.layer}_${var.stack_id}", "_", "-")
  internal                   = lookup(var.lb_definition, "internal_lb", false)
  subnets                    = var.db_subnets_public
  security_groups            = [aws_security_group.security_group_lb.id]
  enable_deletion_protection = lookup(var.lb_definition, "enable_deletion_protection", false)
  idle_timeout               = lookup(var.lb_definition, "idle_timeout", 60)

  tags = {
    Name   = "lb_${lookup(var.lb_definition, "name_lb")}_${var.layer}_${var.stack_id}"
    Source = "Terraform"
  }
}

resource "aws_lb_target_group" "app" {
  name        = replace("tg_${lookup(var.lb_definition, "name_lb")}_${var.layer}_${var.stack_id}", "_", "-")
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc
  target_type = lookup(var.lb_definition, "target_type", "instance")

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "10"
    path                = "/"
    unhealthy_threshold = "5"
  }
}

resource "aws_lb_target_group_attachment" "target_group_attachment" {

  target_group_arn = aws_lb_target_group.app.arn
  target_id        = var.target_id
  port             = 80
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.main.id
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
  load_balancer_arn = aws_lb.main.id
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.id
  }
}