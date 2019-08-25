module "key" {
  source = "git@github.com:aaomoware/terraform-modules.git//aws/ec2/key_pair"

  key_name   = "nike"
  public_key = "${var.public_key}"
}

#--- launch Configuration for worker node;
#--- used by autoscaling to launch worker nodes into the eks cluster
module "wn_lc" {
  source = "git@github.com:aaomoware/terraform-modules.git//aws/ec2/launch_configuration"

  key_name             = "${module.key.key_name}"
  image_id             = "${data.aws_ami.eks_ami.id}"
  name_prefix          = "${var.eks_cluster_name}-wn"
  instance_type        = "${var.instance_type}"
  security_groups      = ["${module.sg_worker_node.id}"]
  user_data_base64     = "${base64encode(local.wn_userdata)}"
  iam_instance_profile = "${module.eks_wn_instance_profile.name}"
}

#--- worker nodes autoscaling group
module "wn_asg" {
  source = "git@github.com:aaomoware/terraform-modules.git//aws/ec2/autoscaling_group"

  tags                 = "${local.asg_tags["tags"]}"
  max_size             = "${var.max_size}"
  min_size             = "${var.min_size}"
  name                 = "${var.eks_cluster_name}-asg"
  desired_capacity     = "${var.desired_capacity}"
  vpc_zone_identifier  = ["${module.subnets.subnets_id}"]
  launch_configuration = "${module.wn_lc.id_base64}"
}
