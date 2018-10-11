variable "vpc_id" {
  description = "This is my vpc being used as a variable to pass into my module for the app"
}

variable "name" {
  description = "Name of the user of the app"
}

variable "user_data" {
  description = "Data that is used to set up a machine when it is spun up"
}

variable "ig_id" {
  description = "internet gateway for my vpc"
}

variable "ami_id" {
  description = "ami for the app"
}
