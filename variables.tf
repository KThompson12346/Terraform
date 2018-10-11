variable "name" {
  default="app-KiromeT"
}

variable "app_ami_id" {
  default="ami-010a4cc4b1d0733a6"

}

variable "db_ami_id" {
  default="ami-0f5fc05abcfa588d0"
}

variable "cidr_block" {
  default="10.0.0.0/16"
}

variable "internal" {
  description = "should the ELB be internal or external"
  default = "false"
}
