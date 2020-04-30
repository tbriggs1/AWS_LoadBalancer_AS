provider "aws" {
  region = "eu-west-1"
}

# create a vpc
resource "aws_vpc" "app" {
  cidr_block = "${var.cidr_block}"

  tags = {
    Name = "${var.name}"
  }
}

# internet gateway
resource "aws_internet_gateway" "app" {
  vpc_id = "${aws_vpc.app.id}"

  tags = {
    Name = "${var.name}"
  }
}

# APP
# create a subnet
module "app" {
  source        = "./app_tier"
  vpc_id        = "${aws_vpc.app.id}"
  name          = "${var.name}"
  gateway_id    = "${aws_internet_gateway.app.id}"
  db_private_ip = "${module.db.db_private_ip}"
  app_ami_id    = "${var.app_ami_id}"
}


# DB
# create a subnet
module "db" {
  source          = "./db_tier"
  vpc_id          = "${aws_vpc.app.id}"
  name            = "${var.name}"
  app_security_id = "${module.app.app_security_id}"
  app_subnet_cidr = "${module.app.app_subnet_cidr}"
  # app_subnet_cidr1 = "${module.app.app_subnet_cidr1}"
  # app_subnet_cidr2 = "${module.app.app_subnet_cidr2}"
  db_ami_id = "${var.db_ami_id}"
}

resource "aws_lb" "app_lb" {
  name                       = "Final-Project-LB"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = ["${module.app.app_security_id}"]
  subnets                    = ["${module.app.subnet_id}", "${module.app.subnet_id1}", "${module.app.subnet_id2}"]
  enable_deletion_protection = false
  tags = {
    Name = "Eng47-Project-Final-LB"
  }
}

resource "aws_lb_listener" "Eng47-listener" {
  load_balancer_arn = "${aws_lb.app_lb.arn}"
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.app_TG.arn}"
  }
}
resource "aws_launch_configuration" "app_LC" {
  name            = "Eng47-launch-config-project"
  image_id        = "${var.app_ami_id}"
  instance_type   = "t2.micro"
  user_data       = "${data.template_file.app_init.rendered}"
  security_groups = ["${module.app.app_security_id}"]

}

data "template_file" "app_init" {
  template = "${file("./scripts/app/init.sh.tpl")}"
  vars = {
    db_host = "mongodb://${module.db.db_private_ip}:27017/posts"
  }
}

resource "aws_lb_target_group" "app_TG" {
  name     = "Eng47-FinalProject-TG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.app.id}"
}

# resource "aws_lb_target_group_attachment" "app_attach" {
#   target_group_arn = "${aws_lb_target_group.app_TG.arn}"
#   target_id        = "${module.app.subnet_id}"
#   port             = 80
# }

resource "aws_autoscaling_group" "app_AS" {
  name                      = "Eng47-FinalProject-AS"
  max_size                  = 4
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 3
  force_delete              = true
  launch_configuration      = "${aws_launch_configuration.app_LC.id}"
  vpc_zone_identifier       = ["${module.app.subnet_id}", "${module.app.subnet_id1}", "${module.app.subnet_id2}"]
  target_group_arns         = ["${aws_lb_target_group.app_TG.arn}"]
}
