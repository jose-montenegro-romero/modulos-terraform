
resource "aws_lb_target_group" "app" {
  name        = replace("tg_${lookup(var.lb_definition, "name")}_${var.project}_${var.environment}", "_", "-")
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
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
  load_balancer_arn = aws_lb.lb.id
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
  load_balancer_arn = aws_lb.lb.id
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.id
  }
}