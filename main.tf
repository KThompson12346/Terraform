provider "aws" {
  region  = "eu-central-1"
}

# create a vpc
resource "aws_vpc" "app" {
  cidr_block = "${var.cidr_block}"

  tags {
    Name = "${var.name}"
  }
}

# internet gateway
resource "aws_internet_gateway" "app" {
  vpc_id = "${aws_vpc.app.id}"

  tags {
    Name = "${var.name}"
  }
}

# This will assign values to the created variables within the "app_tier" module
module "app" {
  source = "./modules/app_tier"
  vpc_id = "${aws_vpc.app.id}"
  name = "KiromeApp"
  user_data = "${data.template_file.app_init.rendered}"
  ig_id =  "${aws_internet_gateway.app.id}"
  ami_id = "${var.app_ami_id}"
}
module "db" {
  source = "./modules/db_tier"
  vpc_id = "${aws_vpc.app.id}"
  name = "kirome-db"
  ami_id = "${var.db_ami_id}"
  app_sg = "${module.app.security_group_id}"
  app_subnet_cidr_block = "${module.app.subnet_cidr_block}"
}

# load the init template
data "template_file" "app_init" {
   template = "${file("./scripts/app/init.sh.tpl")}"
   vars {
      db_host="mongodb://${module.db.db_instance}:27017/posts"
   }
}

# Launch configuration used by auto scaling group when creating more instances with the correct configuration
resource "aws_launch_configuration" "launch_conf" {
  name = "auto_scale_conf"
  image_id = "${var.app_ami_id}"
  instance_type = "t2.micro"
  security_groups = ["${module.app.security_group_id}"]
  user_data = "${data.template_file.app_init.rendered}"
  lifecycle {
    create_before_destroy = true
  }
}


# The target groups used by the load balancer when redirecting on the end users
resource "aws_lb_target_group" "kirome-target-group" {
  name = "kirome-target-group"
  port = 80
  protocol = "TCP"
  vpc_id = "${aws_vpc.app.id}"
}

resource "aws_alb" "kirome-load-balancer" {
  name = "kirome-load-balancer"
  internal = false
  load_balancer_type = "network"
  subnets = ["${module.app.subnet_app_id}"]

  enable_deletion_protection = false

  tags {
    Name =  "kirome-load-balance"
  }
}

resource "aws_autoscaling_policy" "auto_scaler_policy" {
  name                   = "auto_scaling_group_app"
  scaling_adjustment     = "1"
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 120
  autoscaling_group_name = "${aws_autoscaling_group.auto_scaler.name}"
}

# This is the auto scaling group that holds ec2 instances with "launch_conf" configuration
resource "aws_autoscaling_group" "auto_scaler" {
  name = "auto_scaling_group_app"
  max_size = 2
  min_size = 1
  desired_capacity = 2
  health_check_grace_period = 120
  health_check_type = "ELB"
  force_delete = true
  launch_configuration = "${aws_launch_configuration.launch_conf.name}"
  vpc_zone_identifier = ["${module.app.subnet_app_id}"]
  target_group_arns = ["${aws_lb_target_group.kirome-target-group.arn}"]
  lifecycle {
    create_before_destroy = true
  }
}

# Listener used by the load balancer to listen to requests from end user
resource "aws_lb_listener" "kirome-lb-listener" {
  load_balancer_arn = "${aws_alb.kirome-load-balancer.id}"
  port = "80"
  protocol = "TCP"

  default_action {
  target_group_arn = "${aws_lb_target_group.kirome-target-group.arn}"
  type             = "forward"
  }
}
