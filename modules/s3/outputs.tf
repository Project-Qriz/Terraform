output "model_bucket_name" {
  value       = aws_s3_bucket.model_storage.bucket
  description = "The name of the S3 bucket for model storage"
}

output "model_bucket_arn" {
  value       = aws_s3_bucket.model_storage.arn
  description = "The ARN of the S3 bucket for model storage"
}

output "data_bucket_name" {
  value       = aws_s3_bucket.data_storage.bucket
  description = "The name of the S3 bucket for data storage"
}

output "data_bucket_arn" {
  value       = aws_s3_bucket.data_storage.arn
  description = "The ARN of the S3 bucket for data storage"
}

output "logs_bucket_name" {
  value       = aws_s3_bucket.training_logs.bucket
  description = "The name of the S3 bucket for training logs"
}