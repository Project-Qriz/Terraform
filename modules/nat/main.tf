# NAT Instance Security Group
resource "aws_security_group" "main" {
  name = "${var.environment}-nat-sg"
  description = "Security group for NAT instance"
  vpc_id = var.vpc_id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "-1"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [var.private_subnet_cidr]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [var.private_subnet_cidr]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-nat-sg"
    Environment = "${var.environment}"
  }
}

# NAT Instance
resource "aws_instance" "main" {
  ami = var.nat_ami_id
  instance_type = var.instance_type
  subnet_id = var.public_subnet_id

  vpc_security_group_ids = [aws_security_group.main.id]
  key_name = var.key_name

  source_dest_check = false

  tags = {
    Name = "${var.environment}-nat-instance"
    Environment = "${var.environment}"
  }
}

