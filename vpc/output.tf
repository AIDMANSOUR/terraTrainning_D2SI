output "ineternet_gateway_id" {
  value       = "${aws_internet_gateway.labs1_igw.id}"
  description = "ineternet_gateway_id"
}

output "aws_route_table.labs1_rt_id" {
  value       = "${aws_route_table.labs1_rt.id}"
  description = "routr_table_id"
}

#output "aws_route_table_association.labs1_association" {
#  value       = "${aws_route_table_association.labs1_art.depends_on}"
#  description = "Association Route table"
#}

#output "aws_subnet.labs1_public_id" {
#  value       = "${aws_subnet.labs1_public_1a.id}"
#  description = "subnet Id"
#}

output "aws_labs1_vpc_id" {
  value       = "${aws_vpc.labs1_vpc.id}"
  description = "subnet Id"
}
output "aws_labs1_subnet"{
  value = "${aws_subnet.labs1.*.id}"
}