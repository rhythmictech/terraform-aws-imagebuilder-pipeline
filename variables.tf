variable "additional_iam_policy_arns" {
  default     = []
  description = "List of ARN policies for addional builder permissions"
  type        = list(string)
}

variable "description" {
  default     = null
  description = "description of component"
  type        = string
}

variable "instance_types" {
  default     = ["t3.medium"]
  description = "Instance types to create images from. It's unclear why this is a list. Possibly because different types can result in different images (like ARM instances)"
  type        = list(string)
}

variable "key_pair" {
  default     = null
  description = "EC2 key pair to add to the default user on the builder"
  type        = string
}

variable "license_config_arns" {
  default     = null
  description = "If you're using License Manager, your ARNs go here"
  type        = list(string)
}

variable "log_bucket" {
  default     = null
  description = "Bucket to store logs in. If this is ommited logs will not be stored"
  type        = string
}

variable "log_prefix" {
  default     = null
  description = "S3 prefix to store logs at. Recommended if sharing bucket with other pipelines"
  type        = string
}

variable "name" {
  description = "name to use for component"
  type        = string
}

variable "recipe_arn" {
  description = "ARN of the recipe to use. Must change with Recipe version"
  type        = string
}

variable "regions" {
  default = [
    "us-east-1",
    "us-east-2",
    "us-west-1",
    "us-west-2",
    "ca-central-1"
  ]
}

variable "schedule" {
  default = {
    PipelineExecutionStartCondition = "EXPRESSION_MATCH_AND_DEPENDENCY_UPDATES_AVAILABLE"
    ScheduleExpression              = "cron(0 0 * * mon)"
  }
  description = "Schedule expression for when pipeline should run automatically https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-imagebuilder-imagepipeline-schedule.html"
  type = object({
    PipelineExecutionStartCondition = string
    ScheduleExpression              = string
  })
}

variable "security_groups" {
  default     = null
  description = "Security groups for the Image Builder"
  type        = list(string)
}

variable "shared_accounts" {
  default     = null
  description = "AWS accounts to share AMIs with. If this is left null AMIs will be public"
  type        = list(string)
}

variable "sns_topic" {
  default     = null
  description = "SNS topic to notify when new images are created"
  type        = string
}

# TODO: Add validation
variable "status" {
  default     = "ENABLED"
  description = "Whether pipeline is ENABLED or DISABLED"
  type        = string
}

variable "subnet" {
  default     = null
  description = "Subnet ID to use for builder"
  type        = string
}

variable "tags" {
  default     = {}
  description = "map of tags to use for CFN stack and component"
  type        = map(string)
}

variable "terminate_on_failure" {
  default     = true
  description = "Change to false if you want to ssh into a builder for debugging after failure"
  type        = bool
}

variable "test_config" {
  default = {
    ImageTestsEnabled = true
    TimeoutMinutes    = 60
  }
  description = "Whether to run tests during image creation and maximum time to allow tests to run"
  type = object({
    ImageTestsEnabled = bool
    TimeoutMinutes    = number
  })
}

variable "timeout" {
  default     = 10
  description = "How long to wait (in minutes) for CFN to apply before giving up"
  type        = number
}
