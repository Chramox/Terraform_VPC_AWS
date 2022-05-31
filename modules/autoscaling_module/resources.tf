module "launch_configuration" {
  source = "../launch_conf_module"
}

module "jmi_vpc" {
  source = "../vpc_module"
}

resource "aws_autoscaling_group" "autoscaling_group_jmi" {
  name                      = "tf_autoscaling_group_jmi"
  max_size                  = 2
  min_size                  = 1
  desired_capacity          = 2
  force_delete              = true
  launch_configuration      = module.launch_configuration.launch_conf_name
  vpc_zone_identifier       = module.jmi_vpc.private_subnets_ids


  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb" "tf_load_balancer_jmi" {
  name               = "tfloadbalancerjmi"
  internal           = false
  load_balancer_type = "network"
  subnets            = module.jmi_vpc.private_subnets_ids
}

resource "aws_lb_target_group" "tf_lb_target_group_jmi" {
  name = "tflbtargetgroupjmi"
  port = 80
  protocol = "TCP"
  vpc_id = module.jmi_vpc.vpc_id
}

resource "aws_autoscaling_attachment" "tf_autosc_attach_jmi" {
  autoscaling_group_name = aws_autoscaling_group.autoscaling_group_jmi.name
  alb_target_group_arn   = aws_lb_target_group.tf_lb_target_group_jmi.arn
}

resource "aws_lb_listener" "tf_lb_listener_jmi" {
  load_balancer_arn = aws_lb.tf_load_balancer_jmi.arn
  port = "80"
  protocol = "TCP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.tf_lb_target_group_jmi.arn
  }
}


