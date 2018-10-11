variable "vpc_id" {
  description = "This is my vpc being used as a variable to pass into my module for the db (same as db)"
}
variable "name" {
  description = "Name of the user of the db"
}

variable "ami_id" {
  description = "ami for the db"
}
variable "app_sg" {
  description = "security group for app"
}
variable "app_subnet_cidr_block" {
  description = "cidr block for app"
}
