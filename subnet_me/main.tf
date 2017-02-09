# This module will generate Public Subnets and Routes
variable "NAME" { default = "Public" }
variable "CIDRS" { default = ["10.0.1.0/24","10.0.2.0/24"] }
variable "NAME_PRIV" { default = "Private" }
variable "CIDRS_PRIV" { default = ["10.0.101.0/24","10.0.102.0/24"] }
variable "AZS" { default = ["eu-west-1a","eu-west-1b"] }
variable "VPC_ID" { default = "VPC" }
variable "IGW_ID" { default = "IGW" }
variable "ASSIGN_PUB_IP" { default = true }
variable "TAGS" { default = {} }
variable "nat_gateways_count" { default = "2" }
variable "environment" {description = "Environment tag, e.g prod"}

# Public Subnets
resource "aws_subnet" "public" {
  vpc_id                  = "${var.VPC_ID}"
  cidr_block              = "${element(var.CIDRS, count.index)}"
  availability_zone       = "${element(var.AZS, count.index)}"
  count                   = "${length(var.CIDRS)}"
  map_public_ip_on_launch = "${var.ASSIGN_PUB_IP}"
  lifecycle { create_before_destroy = true }
  tags = "${merge(var.TAGS, map("Name", format("%s.%s", var.NAME, element(var.AZS, count.index))))}"
}
# Route Table
resource "aws_route_table" "public" {
  vpc_id = "${var.VPC_ID}"
  count  = "${length(var.CIDRS)}"
  tags = "${merge(var.TAGS, map("Name", format("%s.%s", var.NAME, element(var.AZS, count.index))))}"
}
# Route Association
resource "aws_route_table_association" "public" {
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.public.*.id, count.index)}"
  count          = "${length(var.CIDRS)}"
  lifecycle      { create_before_destroy = true }
}
# Internet Gateway
resource "aws_route" "igw" {
  route_table_id         = "${element(aws_route_table.public.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${var.IGW_ID}"
  count                  = "${length(var.CIDRS)}"
  depends_on             = [ "aws_route_table.public" ]
  lifecycle              { create_before_destroy = true }
}

# This part will generate Private Subnets, Routes, and NAT.

# Private Subnets
resource "aws_subnet" "private" {
  vpc_id                  = "${var.VPC_ID}"
  cidr_block              = "${element(var.CIDRS_PRIV, count.index)}"
  availability_zone       = "${element(var.AZS, count.index)}"
  count                   = "${length(var.CIDRS_PRIV)}"
  lifecycle { create_before_destroy = true }
  tags = "${merge(var.TAGS, map("Name", format("%s.%s", var.NAME, element(var.AZS, count.index))))}"
}
# Route Table
resource "aws_route_table" "private" {
  vpc_id = "${var.VPC_ID}"
  count  = "${length(var.CIDRS_PRIV)}"
  tags = "${merge(var.TAGS, map("Name", format("%s.%s", var.NAME, element(var.AZS, count.index))))}"
}
# Route Association
resource "aws_route_table_association" "private" {
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
  count          = "${length(var.CIDRS_PRIV)}"
}
# NAT Gateway
resource "aws_route" "nat_gateway" {
  route_table_id         = "${element(aws_route_table.private.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${element(aws_nat_gateway.nat.*.id, count.index)}"
  count                  = "${length(var.CIDRS_PRIV)}"
  depends_on             = [ "aws_route_table.private" ]
}
# EIP
resource "aws_eip" "nat" {
  vpc   = true
  count = "${var.nat_gateways_count}"
}
# NAT
resource "aws_nat_gateway" "nat" {
  allocation_id = "${element(aws_eip.nat.*.id, count.index)}"
  subnet_id     = "${element(aws_subnet.public.*.id, count.index)}"
  count         = "${var.nat_gateways_count}"
}

# Output
output "public_subnet_ids" { value = [ "${aws_subnet.public.*.id}" ] }
output "public_route_table_ids" { value = [ "${aws_route_table.public.*.id}" ] }
output "private_subnet_ids" { value = [ "${aws_subnet.private.*.id}" ] }
output "private_route_table_ids" { value = [ "${aws_route_table.private.*.id}" ] }
output "private_nat_eips" { value = [ "${aws_eip.nat.*.public_ip}" ] }
