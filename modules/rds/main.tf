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

### Prod ###
resource "aws_db_instance" "database" {
  identifier = "${var.environment}-database"
  instance_class = "db.t3.micro"
  allocated_storage = 20
  engine = "mysql"
  engine_version = "8.0"

  db_name = var.database_name
  username = var.database_username
  password = var.database_password

  db_subnet_group_name = aws_db_subnet_group.database.name
  vpc_security_group_ids = [ aws_security_group.rds_sg.id, var.rds_ec2_security_group_id ]
  skip_final_snapshot = true
  multi_az = var.multi_az

  tags = {
    Name = "${var.environment}-database"
  }
}

# Read Replica for production
resource "aws_db_instance" "replica" {
  count = var.create_replica ? 1 : 0

  identifier = "${var.environment}-database-replica"
  replicate_source_db = aws_db_instance.database.identifier
  instance_class = "db.t3.micro"
  vpc_security_group_ids = [ aws_security_group.rds_sg.id, var.rds_ec2_security_group_id ]
  skip_final_snapshot = true

  tags = {
    Name = "${var.environment}-database-replica"
  }
}