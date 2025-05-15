output "s3_user_access_key" {
  value     = aws_iam_access_key.media_key.id
  sensitive = true
  description = "Access key for IAM user with S3 media permissions"
}

output "s3_user_secret_key" {
  value     = aws_iam_access_key.media_key.secret
  sensitive = true
  description = "Secret access key for IAM user with S3 media permissions"
}

output "frontend_bucket_url" {
  value       = aws_s3_bucket.frontend.website_endpoint
  description = "URL to access the static website hosted on S3"
}

output "media_bucket_name" {
  value       = aws_s3_bucket.media.id
  description = "Name of the S3 bucket used for media uploads"
}
