output "pipeline_arn" {
  description = "ARN of EC2 Image Builder Pipeline"
  value       = aws_cloudformation_stack.this.outputs["PipelineArn"]
}

output "role_name" {
  description = "The name of the IAM role for use if additional permissions are needed."
  value       = aws_iam_role.this.name
}
