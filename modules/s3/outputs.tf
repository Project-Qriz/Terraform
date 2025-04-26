output "model_bucket_name" {
  value       = aws_s3_bucket.model_storage.bucket
  description = "The name of the S3 bucket for model storage"
}

output "model_bucket_arn" {
  value       = aws_s3_bucket.model_storage.arn
  description = "The ARN of the S3 bucket for model storage"
}

output "model_training_role_arn" {
  value       = aws_iam_role.model_training_role.arn
  description = "The ARN of the IAM role for model training"
}

output "model_training_profile_name" {
  value       = aws_iam_instance_profile.model_training_profile.name
  description = "The name of the IAM instance profile for model training"
}