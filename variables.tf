variable "environment_name" {
  description = "The name of the environment"
}

variable "ec2_type" {
  description = "The type of EC2 instance"
  default     = "t3.micro"
}
