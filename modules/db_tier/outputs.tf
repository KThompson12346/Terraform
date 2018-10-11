output db_instance {
    description = "the db instance"
    value = "${aws_instance.db.private_ip}"
}
