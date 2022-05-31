output "vpc_id" {
    value = aws_vpc.jmi_terraform_vpc.id
}

output "private_subnets_ids" {
  value = aws_subnet.private_subnet_jmi.*.id
}