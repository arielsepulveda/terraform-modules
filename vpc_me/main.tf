# # # # VPC & GATEWAY # # # # #

### VARIABLES ###
variable "NAME"        { default = "VPC" }
variable "VPC_CIDR"    { default = "10.0.0.0/16" }
variable "AWS_REGION"  { default = "eu-west-1" }
variable "TAGS"        { default = {} }
#################


provider "aws" { region = "${var.AWS_REGION}" }
data "aws_availability_zones" "available" {}

# VPC Resource
resource "aws_vpc" "VPC" {
    cidr_block = "${var.VPC_CIDR}"
    instance_tenancy = "default"
    enable_dns_support = "true"
    enable_dns_hostnames = "true"
    enable_classiclink = "false"
    tags = "${merge(var.TAGS, map("Name", format("%s.%s", var.NAME, element(var.AWS_REGION, count.index))))}"
}
# Internet Gateway
resource "aws_internet_gateway" "myVPC-gateway" {
    vpc_id = "${aws_vpc.VPC.id}"
    tags { Name = "${var.VPC_NAME}" }
}
