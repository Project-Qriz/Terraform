resource "aws_db_subnet_group" "rds" {
  name = "${var.environment}-rds-subnet-group"
  description = "Subnet group for RDS"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.environment}-rds-subnet-group"
    Environment = "${var.environment}"
  }
}

resource "aws_db_instance" "mysql" {
  identifier = "${var.environment}-mysql"
  instance_class = "db.t3.micro"
  allocated_storage = 20
  engine = "mysql"
  engine_version = "8.0"

  db_name = var.database_name
  username = var.database_username
  password = var.database_password

  vpc_security_group_ids = [var.rds_ec2_security_group_id]
  db_subnet_group_name = aws_db_subnet_group.rds.name
  
  skip_final_snapshot = true  # 개발 환경이므로 최종 스냅샷 생성 건너뛰기

  multi_az = false
  publicly_accessible = false
  storage_encrypted = false

  tags = {
    Name = "${var.environment}-mysql"
    Environment = "${var.environment}"
  }
}
