module "vpc" {
  source = "git@github.com:aaomoware/terraform-modules.git//aws/vpc/vpc"

  tags       = "${local.tags["vpc"]}"
  basic_vpc  = true
  cidr_block = "${var.vpc_cidr_block}"
}

module "igw" {
  source = "git@github.com:aaomoware/terraform-modules.git//aws/vpc/internet_gateway"

  tags   = "${local.tags["igw"]}"
  vpc_id = "${module.vpc.basic_vpc_id}"
}

module "rt" {
  source = "git@github.com:aaomoware/terraform-modules.git//aws/vpc/route_table"

  rt_count = true
  azones   = "${data.aws_availability_zones.azones.names}"
  vpc_id   = "${module.vpc.basic_vpc_id}"
  tags     = "${local.tags["rt"]}"
}

module "routes" {
  source = "git@github.com:aaomoware/terraform-modules.git//aws/vpc/route_igw"

  igw_count              = 1
  gateway_id             = "${module.igw.int_gtw_id}"
  route_table_id         = "${module.rt.rt_id}"
  destination_cidr_block = "${var.wildcard}"
}

module "subnets" {
  source = "git@github.com:aaomoware/terraform-modules.git//aws/vpc/subnet"

  tags                    = "${local.tags["subnets"]}"
  vpc_id                  = "${module.vpc.basic_vpc_id}"
  cidr_block              = "${var.subnets_cidr_block}"
  availability_zone       = "${data.aws_availability_zones.azones.names}"
  map_public_ip_on_launch = "${var.map_public_ip_on_launch}"
}

module "rt_assoc" {
  source = "git@github.com:aaomoware/terraform-modules.git//aws/vpc/route_table_association"

  rt_count       = "${length(var.subnets_cidr_block)}"
  subnet_id      = "${module.subnets.subnets_id}"
  route_table_id = "${module.rt.rt_id}"
}
