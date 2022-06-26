provider "aws" {
  region = "ap-southeast-2"
}

data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.2.0"


  name                 = "dev-vpc"
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["10.0.1.0/24"]
  public_subnets       = ["10.0.3.0/24", "10.0.4.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
}

resource "aws_security_group" "allow_alb" {
  name        = "allow_alb_traffic"
  description = "Allow traffic from application load balancer"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "HTTP"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.allow_web_ingress.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_elb"
  }
}

# for when we require SSH access to EC2 instance
resource "aws_key_pair" "default" {
  key_name   = "default-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCX905vxiHn30R6T/61slF7rMjByp1OvhcjOJD0A1gw0WIcL7R4439GLkrrzAxyx8p76EBs445Yy3ZPbilwO/WybJyYiJceI9FOp3R6a+hMJbP9pkqHOdPSDL22tS0GXFm967bc/ilwJNgCFf549qkYAlq7F48ar962+LmeuuD/ZotZFxyPqbXQ8o14W0m43RYrm7ZphBfWBsrWHoeRQFe5CcQc1Nf4mqPjitRLx+P0TZr9jZcek+3AXb3Qr2kLE9197Md3PNOaZYW042py6yT3ZugD7r24J1ytcko5mEYU//IT0B67UD0ZJgVV+eNxDMsLgmxUSWY2VOX/bvfK+mOOk9LlZ7RYfPBbiPK8lpn1b4jntPYB67X0HFTFbq3T8OmDgpL8YxZQp8XpBsn9voqNN6uNrAviwqygm5b0v4wmDiQ2XPP3TIoK7LLgw2pZTrBAVLmvuqmFeZ9jBUn8ll/5+Ozrs3StMvasM+ZBchgdwKWC3QKCvW+Yq7l9PnYeeV/OpWw4tuhNUGuPmOeOxzOC8L5mhpMXu9x9L3ahg7/yO4yLRTFQO0Yi9TkoYXErX+UQL2L1CUQDb/IOjf/8uvptONdsoIVAiXrldbeGeA9sRV9s1jI3qK3Ogd5+f2HxCU6obseMraTfrPIfnEAtbW9eaTLwPgd/ue6h7ZRql+b03Q== root@djameson-ThinkPad-E480"
}

resource "aws_instance" "web-server-instance" {
  ami               = "ami-0e040c48614ad1327" # Ubuntu 22.04 LTS
  instance_type     = "t2.micro"
  availability_zone = "ap-southeast-2a"
  key_name          = aws_key_pair.default.key_name
  subnet_id         = module.vpc.private_subnets[0]
  security_groups   = [aws_security_group.allow_alb.id]

  user_data = <<-EOF
                #!/bin/bash
                sudo apt install nginx -y
                sudo rm /var/www/html/*.html
                sudo echo 'Hello World!' > /var/www/html/index.html
                sudo systemctl restart nginx 
                sudo systemctl enable nginx
                EOF
  tags = {
    Name = "web-server"
  }
}
