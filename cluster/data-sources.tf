data "aws_availability_zones" "azones" {}

#-- if is eks_ami assign this data source will be skipped
#-- otherwise it will go sort for AWS EKS AMI
data "aws_ami" "eks_ami" {
  filter {
    name   = "${var.eks_ami_name}"
    values = ["${var.eks_ami_values}"]
  }

  most_recent = "${var.eks_ami_recent}"
  owners      = ["${var.eks_ami_owners}"] # Amazon EKS AMI Account ID
}

data "aws_iam_policy_document" "eks_wn_role_policy" {
  statement {
    sid = "mc"

    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "eks_mc_role_policy" {
  statement {
    sid = "mc"

    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "eks_mc_ca_role" {
  statement {
    sid = "ca"

    effect = "Allow"

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
    ]

    resources = ["*"]
  }
}
