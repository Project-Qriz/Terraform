# 기본 RDS 서브넷 그룹 (공통)
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

  multi_az = var.multi_az
  publicly_accessible = false
  storage_encrypted = var.environment == "prod" ? true : false

  # 복제본 생성 시 자동 백업 활성화
  backup_retention_period = var.create_replica ? 7 : 1

  # 백업 설정 추가
  backup_window = "03:00-04:00"  # UTC 기준 백업 시간
  maintenance_window = "mon:04:00-mon:05:00"
  
  # 다중 AZ 전환 시간 명시
  apply_immediately = true

  tags = {
    Name = "${var.environment}-mysql"
    Environment = "${var.environment}"
  }
}

# Read Replica for production
resource "aws_db_instance" "replica" {
  count = var.create_replica ? 1 : 0

  identifier = "${var.environment}-mysql-replica"
  replicate_source_db = aws_db_instance.mysql.identifier
  instance_class = "db.t3.micro"

  vpc_security_group_ids = [ var.rds_ec2_security_group_id ]
  skip_final_snapshot = true

  depends_on = [ aws_db_instance.mysql ]

  tags = {
    Name = "${var.environment}-mysql-replica"
    Environment = "${var.environment}"
  }
}