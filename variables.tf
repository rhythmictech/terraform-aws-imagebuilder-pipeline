variable "additional_iam_policy_arns" {
  default     = []
  description = "List of ARN policies for addional builder permissions"
  type        = list(string)
}

variable "container_recipe_arn" {
  default     = null
  description = "ARN of the container recipe to use. Must change with Recipe version"
  type        = string

}

variable "custom_distribution_configs" {
  default     = []
  description = "To use your own distribution configurations for the ImageBuilder Distribution Configuration, supply a list of distribution configuration blocks as defined at https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/imagebuilder_distribution_configuration#distribution"
  type        = any
}

variable "description" {
  default     = null
  description = "description of component"
  type        = string
}

variable "enabled" {
  default     = true
  description = "Whether pipeline is ENABLED or DISABLED"
  type        = bool
}

variable "enhanced_image_metadata_enabled" {
  default     = true
  description = "Whether additional information about the image being created is collected. Default is true."
  type        = bool
}

variable "image_name" {
  default     = ""
  description = "The name prefix given to the AMI created by the pipeline (a timestamp will be added to the end)"
  type        = string
}

variable "image_recipe_arn" {
  default     = null
  description = "ARN of the image recipe to use. Must change with Recipe version"
  type        = string
}

variable "image_tests_enabled" {
  default     = true
  description = "Whether to run tests during image creation"
  type        = bool
}

variable "image_tests_timeout_minutes" {
  default     = 60
  description = "Maximum time to allow for image tests to run"
  type        = number
}

variable "instance_types" {
  default     = ["t3.medium"]
  description = "Instance types to create images from. It's unclear why this is a list. Possibly because different types can result in different images (like ARM instances)"
  type        = list(string)
}

variable "instance_key_pair" {
  default     = null
  description = "EC2 key pair to add to the default user on the builder"
  type        = string
}

variable "instance_metadata_http_put_hop_limit" {
  default     = null
  description = "The number of hops that an instance can traverse to reach its metadata."
  type        = number
}

variable "instance_metadata_http_tokens" {
  default     = "optional"
  description = "Whether a signed token is required for instance metadata retrieval requests. Valid values: required, optional."
  type        = string
}

variable "kms_key_id" {
  default     = null
  description = "KMS Key ID to use when encrypting the distributed AMI, if applicable"
  type        = string
}

variable "license_config_arns" {
  default     = null
  description = "If you're using License Manager, your ARNs go here"
  type        = set(string)
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

variable "public" {
  default     = false
  description = "Whether resulting AMI should be public"
  type        = bool
}

variable "regions" {
  default = [
    "us-east-1",
    "us-east-2",
    "us-west-1",
    "us-west-2",
    "ca-central-1"
  ]
  description = "Regions that AMIs will be available in"
  type        = list(string)
}

variable "resource_tags" {
  default     = null
  description = "Key-value map of tags to apply to resources created by this pipeline"
  type        = map(string)
}

variable "schedule_cron" {
  default     = ""
  description = "Schedule (in cron) for when pipeline should run automatically https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-imagebuilder-imagepipeline-schedule.html"
  type        = string
}

variable "schedule_pipeline_execution_start_condition" {
  default     = "EXPRESSION_MATCH_AND_DEPENDENCY_UPDATES_AVAILABLE"
  description = "Start Condition Expression for when pipeline should run automatically https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-imagebuilder-imagepipeline-schedule.html"
  type        = string
}

variable "schedule_timezone" {
  default     = "Etc/UTC"
  description = "Timezone (in IANA timezone format) that scheduled builds, as specified by schedule_cron, run on"
}

variable "security_group_ids" {
  default     = null
  description = "Security group IDs for the Image Builder"
  type        = list(string)
}

variable "shared_account_ids" {
  default     = []
  description = "AWS accounts to share AMIs with. If this is left null AMIs will be public"
  type        = set(string)
}

variable "shared_organization_arns" {
  default     = null
  description = "Set of AWS Organization ARNs to allow access to the created AMI"
  type        = set(string)
}

variable "shared_ou_arns" {
  default     = null
  description = "Set of AWS Organizational Unit ARNs to allow access to the created AMI"
  type        = set(string)
}

variable "sns_topic_arn" {
  default     = null
  description = "SNS topic to notify when new images are created"
  type        = string
}

variable "ssh_key_secret_arn" {
  default     = null
  description = "If your ImageBuilder Components need to use an SSH Key (private repos, etc.), specify the ARN of the secretsmanager secret containing the SSH key to add access permissions (use arn OR name, not both)"
  type        = string
}

variable "ssh_key_secret_name" {
  default     = null
  description = "If your ImageBuilder Components need to use an SSH Key (private repos, etc.), specify the Name of the secretsmanager secret containing the SSH key to add access permissions (use arn OR name, not both)"
  type        = string
}

variable "subnet" {
  default     = null
  description = "Subnet ID to use for builder"
  type        = string
}

variable "tags" {
  default     = {}
  description = "map of tags to use for component"
  type        = map(string)
}

variable "terminate_on_failure" {
  default     = true
  description = "Change to false if you want to connect to a builder for debugging after failure"
  type        = bool
}
