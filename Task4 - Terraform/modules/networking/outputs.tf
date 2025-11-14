output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.Task4-vpc-zaeem.id
}

output "public_subnet_id_A" {
  description = "The ID of the public subnet"
  value       = aws_subnet.Task4-publicSNA-zaeem.id
}

output "public_subnet_id_B" {
  description = "The ID of the public subnet"
  value       = aws_subnet.Task4-publicSNB-zaeem.id
}

output "internet_gateway_id" {
  description = "The ID of the internet gateway"
  value       = aws_internet_gateway.Task4-igw-zaeem.id
}

output "public_route_table_id" {
  description = "The ID of the public route table"
  value       = aws_route_table.Task4-publicRT-zaeem.id
}