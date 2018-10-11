output subnet_app_id {
  description = "the id of the subnet"
  value = "${aws_subnet.app.id}"
}

output subnet_cidr_block {
  description = "the cidr block of the subnet"
  value = "${aws_subnet.app.cidr_block}"
}

output security_group_id {
  description = "the id of the security group"
  value = "${aws_security_group.app.id}"
}
