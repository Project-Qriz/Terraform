resource "aws_s3_bucket" "model_storage" {
  bucket = "${var.environment}-qriz-model-storage"
  
  tags = {
    Name        = "${var.environment}-qriz-model-storage"
    Environment = var.environment
  }
}

# 버전 관리 활성화
resource "aws_s3_bucket_versioning" "model_versioning" {
  bucket = aws_s3_bucket.model_storage.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 버킷 보안 설정 (기본적으로 프라이빗으로 설정)
resource "aws_s3_bucket_public_access_block" "model_access" {
  bucket = aws_s3_bucket.model_storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 수명 주기 정책 (오래된 버전 관리)
resource "aws_s3_bucket_lifecycle_configuration" "model_lifecycle" {
  bucket = aws_s3_bucket.model_storage.id

  rule {
    id     = "archive-old-versions"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 90
    }

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }
  }
}

# EC2/Lambda가 S3에 접근하기 위한 IAM 역할 및 정책
resource "aws_iam_role" "model_training_role" {
  name = "${var.environment}-model-training-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "model_storage_access" {
  name        = "${var.environment}-model-storage-access"
  description = "Allow access to model storage bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket",
          "s3:GetObjectVersion"
        ]
        Effect = "Allow"
        Resource = [
          aws_s3_bucket.model_storage.arn,
          "${aws_s3_bucket.model_storage.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "model_storage_access_attachment" {
  role       = aws_iam_role.model_training_role.name
  policy_arn = aws_iam_policy.model_storage_access.arn
}

# EC2 인스턴스 프로필
resource "aws_iam_instance_profile" "model_training_profile" {
  name = "${var.environment}-model-training-profile"
  role = aws_iam_role.model_training_role.name
}