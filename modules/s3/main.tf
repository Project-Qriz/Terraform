resource "aws_s3_bucket" "model_storage" {
  bucket = "qriz-model-data"
  
  tags = {
    Name = "qriz-model-storage"
  }
}

resource "aws_s3_bucket_versioning" "model_storage_versioning" {
  bucket = aws_s3_bucket.model_storage.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "model_storage_encryption" {
  bucket = aws_s3_bucket.model_storage.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# 데이터 저장소용 S3 버킷
resource "aws_s3_bucket" "data_storage" {
  bucket = "qriz-data-storage"
  
  tags = {
    Name = "qriz-data-storage"
  }
}

resource "aws_s3_bucket_versioning" "data_storage_versioning" {
  bucket = aws_s3_bucket.data_storage.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "data_storage_encryption" {
  bucket = aws_s3_bucket.data_storage.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# 학습 로그 저장용 S3 버킷
resource "aws_s3_bucket" "training_logs" {
  bucket = "qriz-training-logs"
  
  tags = {
    Name = "qriz-training-logs"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "training_logs_lifecycle" {
  bucket = aws_s3_bucket.training_logs.id

  rule {
    id     = "log-expiration"
    status = "Enabled"

    expiration {
      days = var.log_retention_days
    }
  }
}