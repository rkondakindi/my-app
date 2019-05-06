# MyApp Infrastructure

Configuration in this directory creates the following AWS Resources
- Auto Scaling Group
- Elastic Load Balancer
- Health Check

## Usage

Create `terraform.tfvars` to provide inputs to variables like below

```
stack_name              = "mystack"
application_health_path = "/"
application_port        = 8080
autoscale_group_name    = "myapp-asg"
launch_config_name      = "myapp-lc"
lb_name                 = "myapp-alb"
environment             = "test"
image_id                = "ami-07079058aa890ee37"
instance_type           = "t2.large"
keypair_name            = "rtest"
vpc_id                  = "vpc-5b2f00b3b"
subnets                 = ["subnet-xxxxx","subnet-yyyyyyy"]
volume_size             = 30
volume_type             = "gp2"
your_source_ip          = "42.8.8.8/32"
``` 
you need to execute below to deploy your application

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example may create resources which can cost money. Run `terraform destroy` when you don't need these resources.

## Inputs

Here find the sample inputs required to deploy MyApp Infrastructure

| Name | Values |
|------|-------------|
| stack_name | my-invoice |
| environment | test |
| vpc_id | vpc-xxxxxx |
| image_id | ami-xxxxxxxxxxx |
| instance_type | t2.micro |
| keypair_name | ssh_keypair |
| volume_size | 30 |
| volume_type | gp2 |
| subnets | ["subnet-xxxxx","subnet-yyyyy","subnet-zzzzzz"] |
| application_health_path | /app/health |
| application_port | 8080 |
| autoscale_group_name | myapp-asg |
| launch_config_name | myapp-lc |
| lb_name | myapp-lc |
| your_source_ip | 54.x.x.x/32 |


## Outputs

| Name | Description |
|------|-------------|
| asg_sg_name | Security Group Name of the AutoScaling group |
| alb_sg_name | Security Group Name of the Elastic Load Balancer |
| asg_lc_name | AutoScaling Launch Configuration Name |
| asg_id | AutoScaling ID |
| elb_arn | Elastic Load Balancer ID |
| url_name | Application URL with ELB DNS Name |
| elb_zone_id | Zone ID of the Elastic Load Balancer |

