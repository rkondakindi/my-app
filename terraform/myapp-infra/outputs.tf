# Outputs for AutoScaling Group
output "asg_sg_name" {
  description = "Security Group Name of the AutoScaling group"
  value = "${aws_security_group.asg_sg.name}"
}

output "alb_sg_name" {
  description = "Security Group Name of the Elastic Load Balancer"
  value = "${aws_security_group.alb_sg.name}"
}

output "asg_lc_name" {
  description = "AutoScaling Launch Configuration Name"
  value = "${aws_launch_configuration.launch_configuration.name}"
}

output "asg_id" {
  description = "AutoScaling ID"
  value = "${aws_autoscaling_group.autoscale_group.id}"
}

output "elb_arn" {
  description = "Elastic Load Balancer ID"
  value = "${aws_lb.lb.arn}"
}

output "elb_dns_name" {
  description = "DNS Name of the Elastic Load Balancer"
  value = "${aws_lb.lb.dns_name}"
}

output "elb_zone_id" {
  description = "Zone ID of the Elastic Load Balancer"
  value = "${aws_lb.lb.zone_id}"
}
