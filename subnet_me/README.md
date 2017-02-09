# Terraform Public Subnet Module

Variables
---------

- `VPC_ID` - Important VPC id, Default: VPC
- `IGW_ID` - Important IGW id, Default: IGW
- `NAME` - Name for the PUBLIC subnets, Default: Public
- `CIDRS` - CIDR ** for PUBLIC blocks, Default: ["10.0.1.0/24","10.0.2.0/24"]
- `NAME_PRIV` - Name for PRIVATE subnets, Default: Private
- `CIDRS_PRIV` - CIDR ** for PRIVATE blocks, Default: ["10.0.101.0/24","10.0.102.0/24"]
- `AZS` - List of AZS, Default: ["${data.aws_availability_zones.available.names[0]}","${data.aws_availability_zones.available.names[1]}"]
- `ASSIGN_PUB_IP` - True or False, Default: true
- `tags` - Tags that you want to add to the resources created with this module.

** Note: CIDR must be within VPC assigned IP Addresses.

Example of Use
--------------

```js
module "public_subnets" {
  source      = "github.com/cascompany/terraform-modules/subnet_me"
  NAME        = "prod-public"
  CIDRS       = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  NAME_PRIV   = "prod-private"
  CIDRS_PRIV  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]  
  AZS         = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  VPC_ID      = "My-VPC-ID-123"
  IGW_ID      = "My-IGW-ID-456"
  TAGS {
      "Terraform" = "true"
      "Environment" = "${var.environment}"
  }
}
```

Output
------

- `public_subnet_ids` - Public subnet ids
- `public_route_table_ids` - Public route table ids
- `private_subnet_ids` - Private subnet ids
- `private_route_table_ids` - Private route table ids
- `private_nat_eips` - NAT EIPs

Credits
-------

Idea from [hashicorp/atlas-examples](https://github.com/hashicorp/atlas-examples/tree/master/infrastructures/terraform/aws/network/public_subnet).
This version by [Ariel Sepulveda](https://github.com/cascompany).

License
-------

See LICENSE for full details.
