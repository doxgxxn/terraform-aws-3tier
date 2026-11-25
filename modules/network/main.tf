terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)

  # Subnet layout inside the VPC CIDR (/16 -> /24 subnets):
  #   index 0..9   -> public  (ALB, NAT)
  #   index 10..19 -> private app (ECS tasks)
  #   index 20..29 -> private db  (RDS)
  public_cidrs = [for i in range(var.az_count) : cidrsubnet(var.vpc_cidr, 8, i)]
  app_cidrs    = [for i in range(var.az_count) : cidrsubnet(var.vpc_cidr, 8, i + 10)]
  db_cidrs     = [for i in range(var.az_count) : cidrsubnet(var.vpc_cidr, 8, i + 20)]

  nat_count = var.enable_nat ? (var.single_nat_gateway ? 1 : var.az_count) : 0
}

#tfsec:ignore:aws-ec2-require-vpc-flow-logs-for-all-vpcs -- omitted to keep the demo at zero cost; enable flow logs for real workloads
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, { Name = "${var.name}-vpc" })
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, { Name = "${var.name}-igw" })
}

# --- Public tier (ALB / NAT) ---

resource "aws_subnet" "public" {
  count = var.az_count

  vpc_id                  = aws_vpc.this.id
  cidr_block              = local.public_cidrs[count.index]
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = false

  tags = merge(var.tags, { Name = "${var.name}-public-${local.azs[count.index]}", Tier = "public" })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, { Name = "${var.name}-public-rt" })
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  count = var.az_count

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# --- NAT (optional; dev disables it and runs tasks in public subnets) ---

resource "aws_eip" "nat" {
  count = local.nat_count

  domain = "vpc"

  tags = merge(var.tags, { Name = "${var.name}-nat-eip-${count.index}" })

  depends_on = [aws_internet_gateway.this]
}

resource "aws_nat_gateway" "this" {
  count = local.nat_count

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(var.tags, { Name = "${var.name}-nat-${count.index}" })

  depends_on = [aws_internet_gateway.this]
}

# --- Private app tier (ECS tasks) ---

resource "aws_subnet" "app" {
  count = var.az_count

  vpc_id            = aws_vpc.this.id
  cidr_block        = local.app_cidrs[count.index]
  availability_zone = local.azs[count.index]

  tags = merge(var.tags, { Name = "${var.name}-app-${local.azs[count.index]}", Tier = "app" })
}

resource "aws_route_table" "app" {
  count = var.az_count

  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, { Name = "${var.name}-app-rt-${local.azs[count.index]}" })
}

resource "aws_route" "app_nat" {
  count = var.enable_nat ? var.az_count : 0

  route_table_id         = aws_route_table.app[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[var.single_nat_gateway ? 0 : count.index].id
}

resource "aws_route_table_association" "app" {
  count = var.az_count

  subnet_id      = aws_subnet.app[count.index].id
  route_table_id = aws_route_table.app[count.index].id
}

# --- Private db tier (RDS, no internet route by design) ---

resource "aws_subnet" "db" {
  count = var.az_count

  vpc_id            = aws_vpc.this.id
  cidr_block        = local.db_cidrs[count.index]
  availability_zone = local.azs[count.index]

  tags = merge(var.tags, { Name = "${var.name}-db-${local.azs[count.index]}", Tier = "db" })
}

resource "aws_route_table" "db" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, { Name = "${var.name}-db-rt" })
}

resource "aws_route_table_association" "db" {
  count = var.az_count

  subnet_id      = aws_subnet.db[count.index].id
  route_table_id = aws_route_table.db.id
}
