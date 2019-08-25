module "eks_wn_instance_profile" {
  source = "git@github.com:aaomoware/terraform-modules.git//aws/iam/iam_instance_profile"

  name = "${var.eks_wn_instance_profile}"
  role = "${var.eks_wn_role_name}"
}

#-- EKS Master Cluster IAM Role
module "eks_mc_role" {
  source = "git@github.com:aaomoware/terraform-modules.git//aws/iam/iam_role"

  name               = ["${var.eks_mc_role_name}"]
  description        = "${local.description["roles"]}"
  assume_role_policy = "${local.assume_role_policy["roles"]}"
}

module "eks_mc_ca_iam_policy" {
  source = "git@github.com:aaomoware/terraform-modules.git//aws/iam/iam_policy"

  name        = "cluster_autoscaling"
  policy      = "${data.aws_iam_policy_document.eks_mc_ca_role.json}"
  description = "Cluster AutoScaling"
}

module "eks_mc_pl_attachment" {
  source = "git@github.com:aaomoware/terraform-modules.git//aws/iam/iam_role_policy_attachment"

  role       = ["${local.roles["mc"]}"]
  policy_arn = ["${local.eks_policy_arn["mc"]}"]
}

#--- Worker Nodes role & policy
module "eks_wn_role" {
  source = "git@github.com:aaomoware/terraform-modules.git//aws/iam/iam_role"

  name               = ["${var.eks_wn_role_name}"]
  description        = "${local.description["roles"]}"
  assume_role_policy = "${local.assume_role_policy["roles"]}"
}

module "eks_wn_pl_attachment" {
  source = "git@github.com:aaomoware/terraform-modules.git//aws/iam/iam_role_policy_attachment"

  role       = ["${local.roles["wn"]}"]
  policy_arn = ["${local.eks_policy_arn["wn"]}"]
}
