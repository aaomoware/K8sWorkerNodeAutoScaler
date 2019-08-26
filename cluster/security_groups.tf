#-- security for cluster access
module "sg_cluster" {
  source = "git@github.com:aaomoware/terraform-modules.git//aws/vpc/security_group"

  tags        = "${local.tags["mc"]}"
  name        = "${var.eks_cluster_name}-cluster-sg"
  vpc_id      = "${module.vpc.basic_vpc_id}"
  description = "Allows access to the  cluster master"
}

module "sg_cluster_egress" {
  source = "git@github.com:aaomoware/terraform-modules.git//aws/vpc/security_group_rule"

  type              = "egress"
  to_port           = "0"
  protocol          = "-1"
  from_port         = "0"
  cidr_block        = true
  description       = "all traffic allowed out"
  cidr_blocks       = ["${var.wildcard}"]
  security_group_id = "${module.sg_cluster.id}"
}

module "sg_cluster_ingress" {
  source = "git@github.com:aaomoware/terraform-modules.git//aws/vpc/security_group_rule"

  type              = "ingress"
  to_port           = "0"
  protocol          = "-1"
  from_port         = "0"
  cidr_block        = true
  cidr_blocks       = ["${var.cidr_blocks_remote}"]
  description       = "Cluster API Server access from remote location"
  security_group_id = "${module.sg_cluster.id}"
}

#---worker node seuciry group
module "sg_worker_node" {
  source = "git@github.com:aaomoware/terraform-modules.git//aws/vpc/security_group"

  tags        = "${local.tags["wn"]}"
  name        = "${var.eks_cluster_name}-worker-node-sg"
  vpc_id      = "${module.vpc.basic_vpc_id}"
  description = "Allows access to the  ${var.eks_cluster_name} worker nodes"
}

module "sg_worker_node_egress" {
  source = "git@github.com:aaomoware/terraform-modules.git//aws/vpc/security_group_rule"

  type              = "egress"
  to_port           = "0"
  protocol          = "-1"
  from_port         = "0"
  cidr_block        = true
  description       = "Security group for all nodes in the cluster"
  cidr_blocks       = ["${var.wildcard}"]
  security_group_id = "${module.sg_worker_node.id}"
}

module "sg_worker_node_allow_ssh" {
  source = "git@github.com:aaomoware/terraform-modules.git//aws/vpc/security_group_rule"

  type              = "ingress"
  to_port           = "0"
  protocol          = "-1"
  from_port         = "0"
  cidr_block        = true
  description       = "Allow SSH in from remote location"
  cidr_blocks       = ["${var.cidr_blocks_remote}"]
  security_group_id = "${module.sg_worker_node.id}"
}

# this rule negates all other internal security rules; this rule was an after thought.
module "sg_worker_node_allow_all_internally" {
  source = "git@github.com:aaomoware/terraform-modules.git//aws/vpc/security_group_rule"

  type              = "ingress"
  to_port           = "0"
  protocol          = "-1"
  from_port         = "0"
  cidr_block        = true
  description       = "Allow all from within this network"
  cidr_blocks       = ["${var.vpc_cidr_block}"]
  security_group_id = "${module.sg_worker_node.id}"
}

module "sg_worker_node_internal" {
  source = "git@github.com:aaomoware/terraform-modules.git//aws/vpc/security_group_rule"

  type                     = "ingress"
  to_port                  = 65535
  protocol                 = "-1"
  from_port                = 0
  description              = "Allow node to communicate with each other"
  ss_group_id              = true
  security_group_id        = "${module.sg_worker_node.id}"
  source_security_group_id = "${module.sg_worker_node.id}"
}

module "sg_worker_node_cluster_access" {
  source = "git@github.com:aaomoware/terraform-modules.git//aws/vpc/security_group_rule"

  type                     = "ingress"
  to_port                  = "0"
  protocol                 = "-1"
  from_port                = "0"
  ss_group_id              = true
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  security_group_id        = "${module.sg_worker_node.id}"
  source_security_group_id = "${module.sg_cluster.id}"
}

#--- Pods access to cluster API Server
module "sg_pods_cluster_api_server_access" {
  source = "git@github.com:aaomoware/terraform-modules.git//aws/vpc/security_group_rule"

  type                     = "ingress"
  to_port                  = 443
  protocol                 = "tcp"
  from_port                = 443
  ss_group_id              = true
  description              = "Allow pods to communicate with the cluster API Server"
  security_group_id        = "${module.sg_cluster.id}"
  source_security_group_id = "${module.sg_worker_node.id}"
}
