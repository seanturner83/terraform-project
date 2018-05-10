variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_key_path" {}
variable "aws_key_name" {}

variable "aws_region" {
    description = "EC2 Region for the VPC"
    default = "eu-west-1"
}

variable "amis" {
    description = "AMIs by region"
    default = {
        eu-west-1 = "ami-6e28b517"
        eu-west-2 = "ami-ee6a718a"
    }
}

variable "key_name" {
    description = "ssh keypair to use"
    default = "testingonly"
}

variable "bastion_ami" {
    description = "ami for the bastion"
    default = "ami-6e28b517"
}

variable "bastion_instance_type" {
    description = "bastion instance type"
    default = "t2.micro"
}

variable "node_ami" {
    description = "ami for the nodes"
    default = "ami-1caef165"
}

variable "vpc_name" {
    description = "Friendly name for the VPC"
    default = "web"
}

variable "vpc_cidr" {
    description = "CIDR for the whole VPC"
    default = "10.0.0.0/16"
}

variable "availability_zones" {
    description = "List of AZs"
    default = ["eu-west-1a","eu-west-1b","eu-west-1c"]
}

variable "webapp_instance_count" {
    description = "Number of webapp instances, probably divisible by three"
    default = "3"
}

variable "webapp_min_instances" {
    description = "Minimum number of webapp instances, three for prod"
    default = "3"
}

variable "webapp_desired_capacity" {
    description = "Desired number of webapp instances"
    default = "3"
}

variable "webapp_data_size" {
    description = "Size of the extra EBS volume"
    default = "10"
}
