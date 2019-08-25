module "eks_cluster" {
  source = "git@github.com:aaomoware/terraform-modules.git//aws/eks/cluster"

  name               = "${var.eks_cluster_name}"
  role_arn           = "${module.eks_mc_role.arn[0]}"
  subnet_ids         = ["${module.subnets.subnets_id}"]
  security_group_ids = ["${module.sg_cluster.id}"]
}

#--- kubectl config file
resource "local_file" "kubectl_config" {
  content  = "${local.config_map_aws_auth}"
  filename = "${path.module}/aws-auth-cm.yaml"
}
