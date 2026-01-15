#Create LB vpc-link
module "sg_lb" {
  source = "../sg"


  project    = var.project
  environment = var.environment
  // configuration sg
  name   = replace(substr(replace("lb-${lookup(var.configuration_pagestatic_private, "name")}-${var.environment}-${var.project}", "_", "-"), 0, 31), "/-$/", "")
  vpc_id = var.vpc_id
  ingress = [
    {
      protocol    = "tcp"
      from_port   = 80
      to_port     = 80
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
  egress = [
    {
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
  // TAGS
  tags = var.tags
}


#Create LB vpc-link
module "sg_vpc_link" {
  source = "../sg"


  project    = var.project
  environment = var.environment
  // configuration sg
  name   = "vpc-${lookup(var.configuration_pagestatic_private, "name")}"
  vpc_id = var.vpc_id
  ingress = [
    {
      protocol        = "tcp"
      from_port       = 80
      to_port         = 80
      security_groups = [module.sg_lb.sg_reference.id]
    },
    {
      protocol        = "tcp"
      from_port       = 443
      to_port         = 443
      security_groups = [module.sg_lb.sg_reference.id]
    }
  ]
  egress = [
    {
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
  // TAGS
  tags = var.tags
}

resource "aws_vpc_endpoint" "vpc_endpoint" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [module.sg_vpc_link.sg_reference.id]
  subnet_ids          = var.subnets
  private_dns_enabled = false # Permite que el DNS de S3 resuelva a IPs privadas en tu VPC

  tags = merge(var.tags, {
    Name        = replace("vpc-endpoint-${lookup(var.configuration_pagestatic_private, "name")}-${var.project}-${var.environment}", "_", "-")
    Environment = var.environment
    Source      = "Terraform"
    }
  )
}

resource "aws_s3_object" "index_html" {
  bucket       = var.s3_bucket_id
  key          = "index.html"
  content_type = "text/html"

  # Usa el argumento 'content' para proporcionar el texto directamente
  content = <<EOF
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hola Mundo S3</title>
</head>
<body>
    <h1>¡Hola Mundo desde S3 y ALB!</h1>
    <p>Este es un sitio web estático simple servido a través de AWS S3 y un Application Load Balancer.</p>
</body>
</html>
EOF
}

# Política del Bucket S3 para permitir acceso desde el VPC Endpoint
resource "aws_s3_bucket_policy" "static_website_bucket_policy" {
  bucket = var.s3_bucket_id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*" # Se restringe por la condición del VPC Endpoint, no por Principal específico aquí
        Action    = "s3:GetObject"
        Resource  = "${var.s3_bucket_arn}/*"
        Condition = {
          StringEquals = {
            "aws:SourceVpce" = aws_vpc_endpoint.vpc_endpoint.id # Permite solo desde este VPC Endpoint
          }
        }
      },
    ]
  })
}

resource "aws_lb" "website_alb" {
  name               = replace("lb-${lookup(var.configuration_pagestatic_private, "name")}-${var.project}-${var.environment}", "_", "-")
  internal           = true
  load_balancer_type = "application"
  security_groups    = [module.sg_lb.sg_reference.id]
  subnets            = var.subnets

  enable_deletion_protection = lookup(var.configuration_pagestatic_private, "enable_deletion_protection")

  tags = merge(var.tags, {
    Name        = replace("lb-webstatic-${lookup(var.configuration_pagestatic_private, "name")}-${var.project}-${var.environment}", "_", "-")
    Environment = var.environment
    Source      = "Terraform"
    }
  )
}

# Listener HTTPS para el ALB
resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.website_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-Res-2021-06"
  certificate_arn   = var.acm_arn

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/html"
      status_code  = "503"
      message_body = "<h1>503 Service Unavailable</h1><p>El servicio no está disponible temporalmente.</p>"
    }
  }
}

resource "aws_lb_listener_rule" "redirect_root_to_index" {
  listener_arn = aws_lb_listener.https_listener.arn
  priority     = 3


  action {
    type = "redirect"
    redirect {
      host        = "#{host}"            # Mantiene el host original
      path        = "/#{path}index.html" # Redirecciona a la ruta con index.html
      port        = "#{port}"            # Mantiene el puerto original (443)
      query       = "#{query}"
      protocol    = "HTTPS"    # Mantiene el protocolo original (HTTPS)
      status_code = "HTTP_301" # Redirección permanente (301)
    }
  }

  condition {
    host_header {
      values = [var.s3_bucket_id]
    }
  }

  condition {
    path_pattern {
      values = ["*/"]
    }
  }
}

resource "aws_lb_listener_rule" "redirect_to_tg" {
  listener_arn = aws_lb_listener.https_listener.arn
  priority     = 4


  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.s3_target_group.arn
  }

  condition {
    host_header {
      values = [var.s3_bucket_id]
    }
  }
}

# (Opcional) Listener HTTP para redirigir todo el tráfico a HTTPS
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.website_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301" # Redirección permanente
    }
  }
}

resource "aws_lb_target_group" "s3_target_group" {
  name        = replace("tg-${lookup(var.configuration_pagestatic_private, "name")}-${var.project}-${var.environment}", "_", "-")
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/" # Asegúrate de que este archivo exista en tu bucket S3
    protocol            = "HTTP"
    port                = 80
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = "200,307,405"
  }

  tags = merge(var.tags, {
    Name        = replace("tg-${lookup(var.configuration_pagestatic_private, "name")}-${var.project}-${var.environment}", "_", "-")
    Environment = var.environment
    Source      = "Terraform"
    }
  )
}
