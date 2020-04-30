output app_security_id {
  value = "${aws_security_group.app.id}"
}

output app_subnet_cidr {
  value = "${aws_subnet.app.cidr_block}"
}

output subnet_id {
  description = "the id of the subnet"
  value       = "${aws_subnet.app.id}"
}

output subnet_id1 {
  description = "the id of the subnet"
  value       = "${aws_subnet.app1.id}"
}
#
output subnet_id2 {
  description = "the id of the subnet"
  value       = "${aws_subnet.app2.id}"
}

output app_subnet_cidr1 {
  value = "${aws_subnet.app1.cidr_block}"
}

output app_subnet_cidr2 {
  value = "${aws_subnet.app2.cidr_block}"
}
