resource "aws_security_group" "allow_web_ingress" {
  name        = "allow_web_ingress_traffic"
  description = "Allow Web ingress traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_web_ingress"
  }
}

module "alb" {
  source = "terraform-aws-modules/alb/aws"
  name   = "hello-world-alb"

  load_balancer_type = "application"

  vpc_id          = module.vpc.vpc_id
  subnets         = module.vpc.public_subnets
  security_groups = [aws_security_group.allow_web_ingress.id]

  # redirect http to https
  http_tcp_listeners = [
    {
      port        = 80
      protocol    = "HTTP"
      action_type = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    },
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = module.acm.acm_certificate_arn
      target_group_index = 0
    },
  ]

  target_groups = [
    {
      name_prefix          = "h1"
      backend_protocol     = "HTTP"
      backend_port         = 80
      target_type          = "instance"
      deregistration_delay = 10
      protocol_version     = "HTTP1"
      targets = {
        my_ec2 = {
          target_id = aws_instance.web-server-instance.id
          port      = 80
        },
      }
    },
  ]
}

resource "aws_route53_zone" "djameson" {
  name = "djameson.dev"
}

resource "aws_route53_record" "djameson-dev" {
  zone_id = aws_route53_zone.djameson.zone_id
  name    = "fuel50"
  type    = "CNAME"
  ttl     = "5"

  records = [module.alb.lb_dns_name]
}

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 3.0"

  domain_name = "fuel50.djameson.dev"
  zone_id     = aws_route53_zone.djameson.zone_id
}


