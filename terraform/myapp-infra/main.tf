# Author: Rajesh Kondakindi <KondakindiRajesh@gmail.com>

# NOTE: I have tested this code with terraform version: 0.11.13. So, keeping an condition. this can be removed.
terraform {
  required_version = "<= 0.11.13"
}

# NOTE: you have to configure AWS CLI environment and make sure defailt profile is available. Otherwise you can set AWS Access keys here.
provider "aws" {
  region     = "us-east-1"
}

# Create Security Group for Application ASG
resource "aws_security_group" "asg_sg" {
  name        = "${var.stack_name}-${var.autoscale_group_name}-sg-${var.environment}"
  description = "${var.stack_name}-${var.autoscale_group_name}-security-group-${var.environment}"
  vpc_id      = "${var.vpc_id}"
  tags        = {
    Name        = "${var.stack_name}-${var.autoscale_group_name}-sg-${var.environment}"
    environment = "${var.environment}"
    owner       = "rkondakindi"
  }
}

# Ingres Rule from ELB SG (Whitelist application port)
resource "aws_security_group_rule" "asg_ingress_rule1" {
  type                      = "ingress"
  from_port                 = "${var.application_port}"
  to_port                   = "${var.application_port}"
  protocol                  = "tcp"
  source_security_group_id  = "${aws_security_group.alb_sg.id}"
  security_group_id         = "${aws_security_group.asg_sg.id}"
}

# Ingres Rule for SSH access to instances under ASG
resource "aws_security_group_rule" "ssh_ingress_rule2" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "TCP"
  cidr_blocks       = ["${var.your_source_ip}"]
  security_group_id = "${aws_security_group.asg_sg.id}"
}

# Egress Rule allowing all traffic.
resource "aws_security_group_rule" "asg_egress_rule1" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.asg_sg.id}"
}

# ASG User_data
data "template_file" "asg_user_data" {
  template  = "${file("${path.module}/user_data_asg.tpl")}"
}

# AWS Launch Configuration Resouce
resource "aws_launch_configuration" "launch_configuration" {
  name_prefix                 = "${var.stack_name}-${var.launch_config_name}-${var.environment}"
  image_id                    = "${var.image_id}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${var.keypair_name}"
  security_groups             = ["${aws_security_group.asg_sg.id}"]
  associate_public_ip_address = true
  user_data                   = "${data.template_file.asg_user_data.rendered}"

  root_block_device {
    volume_type           = "${var.volume_type}"
    volume_size           = "${var.volume_size}"
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

# AWS AutoScaling Group Resouce
resource "aws_autoscaling_group" "autoscale_group" {
  name                 = "${var.stack_name}-${var.autoscale_group_name}-${var.environment}"
  launch_configuration = "${aws_launch_configuration.launch_configuration.name}"
  vpc_zone_identifier  = ["${var.subnets}"]
  max_size             = 10
  min_size             = 2
  desired_capacity     = 2

  default_cooldown          = 300
  health_check_grace_period = 30
  health_check_type         = "EC2"

  target_group_arns         = ["${aws_lb_target_group.lb_target_group.arn}"]
  termination_policies      = ["OldestLaunchConfiguration"]
  tags                      = [
    {
      key   = "Name"
      value = "${var.stack_name}-${var.autoscale_group_name}-${var.environment}"
      propagate_at_launch = true
    },
    {
      key   = "owner"
      value = "rkondakindi"
      propagate_at_launch = true
    },
    {
      key   = "environment"
      value = "${var.environment}"
      propagate_at_launch = true
    }
  ]

  lifecycle {
    create_before_destroy = true
  }
}

################# Elasitc Load Balancer Resources ###################
# Create Security Group for Application Load Balancer
resource "aws_security_group" "alb_sg" {
  name        = "${var.stack_name}-${var.lb_name}-sg-${var.environment}"
  description = "${var.stack_name}-${var.lb_name}-security-group-${var.environment}"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.your_source_ip}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.stack_name}-${var.lb_name}-sg-${var.environment}"
    environment = "${var.environment}"
    owner       = "rkondakindi"
  }
}

# application Load Balancer
resource "aws_lb" "lb" {
  name                             = "${var.stack_name}-${var.lb_name}-${var.environment}"
  internal                         = false  # This option can be a variable when you have your organization VPC
  load_balancer_type               = "application"
  security_groups                  = ["${aws_security_group.alb_sg.id}"]
  subnets                          = "${var.subnets}"
  enable_http2                     = true
  tags                             = {
    Name        = "${var.stack_name}-${var.lb_name}-${var.environment}"
    owner       = "rkondakindi"
    environment = "${var.environment}"
  }
}

# Create application Load Balancer Listener for forward
resource "aws_lb_listener" "lb_listener_forward" {
  load_balancer_arn = "${aws_lb.lb.arn}"
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.lb_target_group.arn}"
  }
}

# Load Balancer target group
resource "aws_lb_target_group" "lb_target_group" {
  name                 = "${var.stack_name}-${var.lb_name}-tg-${var.environment}"
  port                 = "${var.application_port}"
  protocol             = "HTTP"
  vpc_id               = "${var.vpc_id}"
  stickiness {
    type            = "lb_cookie"
    cookie_duration = 300
    enabled         = true
  }
  # Target Health Checks
  health_check {
    path                 = "${var.application_health_path}"
    port                 = "${var.application_port}"
    protocol             = "HTTP"
    healthy_threshold    = 3
    unhealthy_threshold  = 3
    matcher              = "200,301,302"
  }
  target_type = "instance"
  tags        = {
    Name        = "${var.stack_name}-${var.lb_name}-tg-${var.environment}"
    owner       = "rkondakindi"
    environment = "${var.environment}"
  }
}

########### Chef integration with Terraform  #################
# NOTE: you can use chef provisioner to converge chef resources if you have EC2 resource.
# NOTE: Chef provisioner only supports fetching cookbooks from chef server. So, all your cookbooks should be available in chef server.
# Ref Doc: https://www.terraform.io/docs/provisioners/chef.html

# Here, I don't have a chef server and using ASG. So, you can achieve chef converge in 2 methods
# 1. Semi-automatic method
#    a. Install chef-client through user_data
#    b. Write bash script under user_data to setup chef-client environment to connect with Chef server (/etc/chef/client.rb)
#    c. Run chef-client with sepecific role/recipe.
# 2. Manual Method (chef-solo)
#    a. Make sure cookbooks are available in git repo and set paths properly
#    b. Run `terraform apply`
#    c. Autoscaling user_data will install chefdk and run `chef-solo` command to apply recipe.
# check code at https://github.com/rkondakindi/my-app/terraform/myapp-infra/user_data_asg.tpl
