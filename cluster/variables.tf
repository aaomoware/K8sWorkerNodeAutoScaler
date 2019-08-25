#-- vpc & sunet variables
variable region {
  description = "The region to deploy eks cluster and related resources to"
  default     = "eu-west-1"
}

variable wildcard {
  default = "0.0.0.0/0"
}

variable basic_vpc {
  default = true
}

variable public_key {
  description = "The public key for the k8s private key"
}

variable extra_tags {
  default = []

  type = "list"
}

variable cidr_blocks_remote {
  description = "External IP; curl ifconfig.co"
}

variable propagate_at_launch {
  default = true
}

variable eks_ami_name {
  default = "name"
}

variable eks_ami_recent {
  default = true
}

variable eks_ami_values {
  default = "amazon-eks-node-1.13-*"
}

variable eks_ami_owners {
  default = "602401143452"
} # -- we are using AWS eks ami

#-- EKS Cluster variables
variable eks_mc_role_name {
  default = "mc"
}

variable eks_cluster_name {
  default = "nike"
}

variable eks_mc_policy_arn {
  default = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSServicePolicy",
  ]

  type = "list"
}

variable eks_wn_policy_arn {
  default = [
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
  ]

  type = "list"
}

variable eks_wn_instance_profile {
  default = "eks_wn_role"
}

variable eks_wn_role_name {
  default = "wn"
}

variable subnets_cidr_block {
  description = "Subnets cidr block"
  type        = "list"

  default = [
    "10.10.1.0/27",
    "10.10.1.32/27",
    "10.10.1.64/27",
  ]
}

variable vpc_cidr_block {
  description = "VPC cidr block"
  default     = "10.10.1.0/24"
}

variable max_size {
  default = "4"
}

variable min_size {
  default = "1"
}

variable desired_capacity {
  default = "1"
}

variable instance_type {
  default = "t2.medium"
}

variable map_public_ip_on_launch {
  default = true
}
