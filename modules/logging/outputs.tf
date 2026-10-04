output "cloudtrail_bucket_arn" {
  value       = aws_s3_bucket.cloudtrail_bucket.arn
  description = "The ARN of the CloudTrail S3 logging bucket"
}

output "cloudtrail_bucket_id" {
  value       = aws_s3_bucket.cloudtrail_bucket.id
  description = "The name/ID of the CloudTrail S3 logging bucket"
}

output "cloudtrail_arn" {
  value       = aws_cloudtrail.main_trail.arn
  description = "The ARN of the provisioned CloudTrail instance"
}
