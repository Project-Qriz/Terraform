resource "aws_security_group" "rds_ec2" {
  name = "${var.environment}-rds-ec2-sg"
  description = "Security group for RDS EC2"
  vpc_id = var.vpc_id
  
  tags = {
    Name = "${var.environment}-rds-ec2-sg"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group" "ec2_rds" {
  name = "${var.environment}-ec2-rds-sg"
  description = "Security group for EC2 RDS"
  vpc_id = var.vpc_id
  
  egress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    security_groups = [aws_security_group.rds_ec2.id]
  }
  
  tags = {
    Name = "${var.environment}-ec2-rds-sg"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group_rule" "rds_ec2_ingress" {
  type = "ingress"
  from_port = 3306
  to_port = 3306
  protocol = "tcp"
  security_group_id = aws_security_group.rds_ec2.id
  source_security_group_id = aws_security_group.ec2_rds.id
}
