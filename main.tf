resource "aws_vpc" "custom_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.custom_vpc.id
}

resource "aws_subnet" "subnet" {
  vpc_id            = aws_vpc.custom_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-central-1a"
}
resource "aws_subnet" "subnet2" {
  vpc_id            = aws_vpc.custom_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-central-1b"
}

resource "aws_db_instance" "rds_instance" {
  instance_class       = "db.t4g.micro"
  engine               = "mysql"
  allocated_storage    = 20
  username             = "dbadmin"
  password             = "password"
  db_subnet_group_name = aws_db_subnet_group.db_subnet.id
  skip_final_snapshot  = true
  # availability_zone    = "eu-central-1a"
}

resource "aws_db_subnet_group" "db_subnet" {
  name       = "my-db-subnet-group"
  subnet_ids = [aws_subnet.subnet.id, aws_subnet.subnet2.id]
}

resource "aws_instance" "ec2_instance" {
  ami           = "ami-0233214e13e500f77"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.subnet.id
}

resource "aws_lb" "nlb" {
  load_balancer_type = "network"
  subnets            = [aws_subnet.subnet.id, aws_subnet.subnet2.id]
}

resource "aws_eip" "nlb_eip" {
  # vpc = true
}

resource "aws_lb_target_group" "tg" {
  vpc_id      = aws_vpc.custom_vpc.id
  target_type = "instance"
  protocol    = "TCP"
  port        = 80
}

resource "aws_lb_target_group_attachment" "tga" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.ec2_instance.id
}

resource "aws_ssm_parameter" "rds_uri" {
  name  = "/config/rds_uri"
  type  = "String"
  value = aws_db_instance.rds_instance.endpoint
}

resource "aws_ssm_parameter" "ec2_dns" {
  name  = "/config/ec2_dns"
  type  = "String"
  value = aws_instance.ec2_instance.private_dns
}

resource "aws_ssm_parameter" "nlb_ip" {
  name  = "/config/nlb_ip"
  type  = "String"
  value = aws_eip.nlb_eip.public_ip
}
