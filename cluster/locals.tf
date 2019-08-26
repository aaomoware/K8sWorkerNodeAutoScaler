locals {
  tags {
    "lc" {
      "Name"        = "${var.eks_cluster_name}"
      "Description" = "Launch Configuration for ${var.eks_cluster_name}"
    }

    "asg" {
      "Name"                                          = "${var.eks_cluster_name}"
      "Description"                                   = "Auto Scaling Group for ${var.eks_cluster_name}"
      "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned"
    }

    "nodes"   = {}
    "cluster" = {}

    "subnets" {
      "Name"                                          = "k8s-subnets"
      "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
    }

    "wn" {
      "Name"                                          = "wn-${var.eks_cluster_name}-sg"
      "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned"
    }

    "mc" {
      "Name" = "mc-${var.eks_cluster_name}-sg"
    }

    "rt" {
      "Name"        = "${var.eks_cluster_name}"
      "Description" = "Route Table for ${var.eks_cluster_name}"
    }

    "ngw" {
      "Name"        = "${var.eks_cluster_name}"
      "Description" = "Nat Gateway for ${var.eks_cluster_name}"
    }

    "igw" {
      "Name"        = "${var.eks_cluster_name}"
      "Description" = "Internet Gateway for ${var.eks_cluster_name}"
    }

    "lc" {
      "Name"        = "${var.eks_cluster_name}"
      "Description" = "Launch Configuration for ${var.eks_cluster_name}"
    }

    "vpc" {
      "Name"                                          = "${var.eks_cluster_name}"
      "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
    }

    "asg" {
      "Name"                                          = "${var.eks_cluster_name}"
      "Description"                                   = "Auto Scaling Group for ${var.eks_cluster_name}"
      "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned"
    }

    "subnets" {
      "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
    }
  }

  asg_tags {
    "tags" = ["${concat(
      list(
      map("key", "Name", "value", "${var.eks_cluster_name}-wn", "propagate_at_launch", "${var.propagate_at_launch}"),
      map("key", "kubernetes.io/cluster/${var.eks_cluster_name}", "value", "owned", "propagate_at_launch", "${var.propagate_at_launch}")
      ), var.extra_tags)}"]
  }

  description {
    "roles" {
      "mc" = "${var.eks_cluster_name} eks master cluster iam role"
      "wn" = "${var.eks_cluster_name} eks worker nodes iam role"
    }
  }

  assume_role_policy {
    "roles" {
      "mc" = "${data.aws_iam_policy_document.eks_mc_role_policy.json}"
      "wn" = "${data.aws_iam_policy_document.eks_wn_role_policy.json}"
    }
  }

  eks_policy_arn {
    "mc" = [
      "${module.eks_mc_ca_iam_policy.arn}",
      "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
      "arn:aws:iam::aws:policy/AmazonEKSServicePolicy",
    ]

    "wn" = [
      "${module.eks_mc_ca_iam_policy.arn}",
      "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
      "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
      "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    ]
  }

  roles {
    "wn" = [
      "${module.eks_wn_role.name[0]}",
      "${module.eks_wn_role.name[0]}",
      "${module.eks_wn_role.name[0]}",
      "${module.eks_wn_role.name[0]}",
    ]

    "mc" = [
      "${module.eks_mc_role.name[0]}",
      "${module.eks_mc_role.name[0]}",
      "${module.eks_mc_role.name[0]}",
    ]
  }

  wn_userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${module.eks_cluster.endpoint}' --b64-cluster-ca '${module.eks_cluster.certificate_authority_data}' '${var.eks_cluster_name}'
#/etc/eks/bootstrap.sh --apiserver-endpoint '${module.eks_cluster.endpoint}' --b64-cluster-ca '${module.eks_cluster.certificate_authority_data}' '${var.eks_cluster_name}'
USERDATA

  kubeconfig = <<KUBECONFIG
apiVersion: v1
clusters:
- cluster:
    server: ${module.eks_cluster.endpoint}
    certificate-authority-data: ${module.eks_cluster.certificate_authority_data}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: aws
current-context: aws
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - "${var.eks_cluster_name}"
KUBECONFIG

  config_map_aws_auth = <<CONFIGMAPAWSAUTH
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${module.eks_wn_role.arn[0]}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
CONFIGMAPAWSAUTH
}
