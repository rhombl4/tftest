output "rds_uri_key" {
  value = aws_ssm_parameter.rds_uri.name
}

output "ec2_private_dns_key" {
  value = aws_ssm_parameter.ec2_dns.name
}

output "nlb_ip_key" {
  value = aws_ssm_parameter.nlb_ip.name
}
