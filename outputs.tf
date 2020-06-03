output "pipeline_arn" {
  description = "ARN of EC2 Image Builder Pipeline"
  value       = aws_cloudformation_stack.this.outputs["PipelineArn"]
}
