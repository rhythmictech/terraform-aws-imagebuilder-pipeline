# terraform-aws-imagebuilder-pipeline
[![tflint](https://github.com/rhythmictech/terraform-aws-rds-mysql/workflows/tflint/badge.svg?branch=master&event=push)](https://github.com/rhythmictech/terraform-aws-rds-mysql/actions?query=workflow%3Atflint+event%3Apush+branch%3Amaster)
[![tfsec](https://github.com/rhythmictech/terraform-aws-rds-mysql/workflows/tfsec/badge.svg?branch=master&event=push)](https://github.com/rhythmictech/terraform-aws-rds-mysql/actions?query=workflow%3Atfsec+event%3Apush+branch%3Amaster)
[![yamllint](https://github.com/rhythmictech/terraform-aws-rds-mysql/workflows/yamllint/badge.svg?branch=master&event=push)](https://github.com/rhythmictech/terraform-aws-rds-mysql/actions?query=workflow%3Ayamllint+event%3Apush+branch%3Amaster)
[![misspell](https://github.com/rhythmictech/terraform-aws-rds-mysql/workflows/misspell/badge.svg?branch=master&event=push)](https://github.com/rhythmictech/terraform-aws-rds-mysql/actions?query=workflow%3Amisspell+event%3Apush+branch%3Amaster)
[![pre-commit-check](https://github.com/rhythmictech/terraform-aws-rds-mysql/workflows/pre-commit-check/badge.svg?branch=master&event=push)](https://github.com/rhythmictech/terraform-aws-rds-mysql/actions?query=workflow%3Apre-commit-check+event%3Apush+branch%3Amaster)
<a href="https://twitter.com/intent/follow?screen_name=RhythmicTech"><img src="https://img.shields.io/twitter/follow/RhythmicTech?style=social&logo=twitter" alt="follow on Twitter"></a>


Terraform module for creating EC2 Image Builder Pipelines from CloudFormation

## Example
Here's what using the module will look like. Note that this module needs at least one recipe and component to be useful. See `examples` for details.
```hcl
module "test_pipeline" {
  source  = "rhythmictech/imagebuilder-pipeline/aws"

  description = "Testing pipeline"
  name        = "test-pipeline"
  recipe_arn  = module.test_recipe.recipe_arn
  public      = false
}
```

## About
Allows the creation of EC2 Image Builder Pipelines with Cloudformation until native support is added to TF

## Build Scheduling
Builds are scheduled by a cron pattern. The pipeline takes a schedule argument as follows:

```hcl
  schedule = {
    PipelineExecutionStartCondition = "EXPRESSION_MATCH_AND_DEPENDENCY_UPDATES_AVAILABLE"
    ScheduleExpression              = "cron(0 0 * * mon)"
  }
```

The default expects an upstream AMI as a parent image and will build weekly *only if an updated image is found upstream*. By setting `PipelineExecutionStartCondition = "EXPRESSION_MATCH_ONLY"`, the build pipeline will always run.

When scheduling linked jobs, it is important to be mindful of the cron schedules. If both pipelines run with `ScheduleExpression = "cron(0 0 * * mon)"`, the downstream build will always run one week late. Due to the testing phase and startup/teardown time, even a short EC2 Image Builder process can take over 15 minutes to run end to end. Complex test suites can take much longer.

See Amazon's [EC2 Image Builder API Reference](https://docs.aws.amazon.com/imagebuilder/latest/APIReference/API_Schedule.html) for further details.

## Providing your own Distribution Configuration
By default this module will try to handle the aws_imagebuilder_distribution_configuration configuration by itself. This works for more simple builds that only need to create EC2 images, but it may not be suitable for all users. The `custom_distribution_configs` aims to handle this by allowing users to provide a list of distribution configuration blocks, based off of the terraform described at https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/imagebuilder_distribution_configuration#distribution. Where additional configuration blocks are present, they must be replaced with a map of the same name. An example of this is:
```hcl
  custom_distribution_configs = [
    {
      region = "us-east-1",
      ami_distribution_configuration = {
        name = "example-build-{{ imagebuilder:buildDate }}"
        launch_permission = {
          user_ids = ["123456789012"]
        }
      }
      launch_template_configuration = {
        launch_template_id = "lt-0123456789abcde"
      }
    },
    {
      region = "us-west-1"
      ami_distribution_configuration = {
        name = "example-build-{{ imagebuilder:buildDate }}"
      }
      ...
    }
  ]
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.22.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.22.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_instance_profile.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.log_write](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.secret_read](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.core](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.log_write](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.secret_read](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_imagebuilder_distribution_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/imagebuilder_distribution_configuration) | resource |
| [aws_imagebuilder_image_pipeline.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/imagebuilder_image_pipeline) | resource |
| [aws_imagebuilder_infrastructure_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/imagebuilder_infrastructure_configuration) | resource |
| [aws_iam_policy_document.assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.log_write](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.secret_read](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_secretsmanager_secret.ssh_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_iam_policy_arns"></a> [additional\_iam\_policy\_arns](#input\_additional\_iam\_policy\_arns) | List of ARN policies for addional builder permissions | `list(string)` | `[]` | no |
| <a name="input_container_recipe_arn"></a> [container\_recipe\_arn](#input\_container\_recipe\_arn) | ARN of the container recipe to use. Must change with Recipe version | `string` | `null` | no |
| <a name="input_custom_distribution_configs"></a> [custom\_distribution\_configs](#input\_custom\_distribution\_configs) | To use your own distribution configurations for the ImageBuilder Distribution Configuration, supply a list of distribution configuration blocks as defined at https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/imagebuilder_distribution_configuration#distribution | `any` | `[]` | no |
| <a name="input_description"></a> [description](#input\_description) | description of component | `string` | `null` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Whether pipeline is ENABLED or DISABLED | `bool` | `true` | no |
| <a name="input_enhanced_image_metadata_enabled"></a> [enhanced\_image\_metadata\_enabled](#input\_enhanced\_image\_metadata\_enabled) | Whether additional information about the image being created is collected. Default is true. | `bool` | `true` | no |
| <a name="input_image_name"></a> [image\_name](#input\_image\_name) | The name prefix given to the AMI created by the pipeline (a timestamp will be added to the end) | `string` | `""` | no |
| <a name="input_image_recipe_arn"></a> [image\_recipe\_arn](#input\_image\_recipe\_arn) | ARN of the image recipe to use. Must change with Recipe version | `string` | `null` | no |
| <a name="input_image_tests_enabled"></a> [image\_tests\_enabled](#input\_image\_tests\_enabled) | Whether to run tests during image creation | `bool` | `true` | no |
| <a name="input_image_tests_timeout_minutes"></a> [image\_tests\_timeout\_minutes](#input\_image\_tests\_timeout\_minutes) | Maximum time to allow for image tests to run | `number` | `60` | no |
| <a name="input_instance_key_pair"></a> [instance\_key\_pair](#input\_instance\_key\_pair) | EC2 key pair to add to the default user on the builder | `string` | `null` | no |
| <a name="input_instance_metadata_http_put_hop_limit"></a> [instance\_metadata\_http\_put\_hop\_limit](#input\_instance\_metadata\_http\_put\_hop\_limit) | The number of hops that an instance can traverse to reach its metadata. | `number` | `null` | no |
| <a name="input_instance_metadata_http_tokens"></a> [instance\_metadata\_http\_tokens](#input\_instance\_metadata\_http\_tokens) | Whether a signed token is required for instance metadata retrieval requests. Valid values: required, optional. | `string` | `"optional"` | no |
| <a name="input_instance_types"></a> [instance\_types](#input\_instance\_types) | Instance types to create images from. It's unclear why this is a list. Possibly because different types can result in different images (like ARM instances) | `list(string)` | <pre>[<br>  "t3.medium"<br>]</pre> | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | KMS Key ID to use when encrypting the distributed AMI, if applicable | `string` | `null` | no |
| <a name="input_license_config_arns"></a> [license\_config\_arns](#input\_license\_config\_arns) | If you're using License Manager, your ARNs go here | `set(string)` | `null` | no |
| <a name="input_log_bucket"></a> [log\_bucket](#input\_log\_bucket) | Bucket to store logs in. If this is ommited logs will not be stored | `string` | `null` | no |
| <a name="input_log_prefix"></a> [log\_prefix](#input\_log\_prefix) | S3 prefix to store logs at. Recommended if sharing bucket with other pipelines | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | name to use for component | `string` | n/a | yes |
| <a name="input_public"></a> [public](#input\_public) | Whether resulting AMI should be public | `bool` | `false` | no |
| <a name="input_regions"></a> [regions](#input\_regions) | Regions that AMIs will be available in | `list(string)` | <pre>[<br>  "us-east-1",<br>  "us-east-2",<br>  "us-west-1",<br>  "us-west-2",<br>  "ca-central-1"<br>]</pre> | no |
| <a name="input_resource_tags"></a> [resource\_tags](#input\_resource\_tags) | Key-value map of tags to apply to resources created by this pipeline | `map(string)` | `null` | no |
| <a name="input_schedule_cron"></a> [schedule\_cron](#input\_schedule\_cron) | Schedule (in cron) for when pipeline should run automatically https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-imagebuilder-imagepipeline-schedule.html | `string` | `""` | no |
| <a name="input_schedule_pipeline_execution_start_condition"></a> [schedule\_pipeline\_execution\_start\_condition](#input\_schedule\_pipeline\_execution\_start\_condition) | Start Condition Expression for when pipeline should run automatically https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-imagebuilder-imagepipeline-schedule.html | `string` | `"EXPRESSION_MATCH_AND_DEPENDENCY_UPDATES_AVAILABLE"` | no |
| <a name="input_schedule_timezone"></a> [schedule\_timezone](#input\_schedule\_timezone) | Timezone (in IANA timezone format) that scheduled builds, as specified by schedule\_cron, run on | `string` | `"Etc/UTC"` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | Security group IDs for the Image Builder | `list(string)` | `null` | no |
| <a name="input_shared_account_ids"></a> [shared\_account\_ids](#input\_shared\_account\_ids) | AWS accounts to share AMIs with. If this is left null AMIs will be public | `set(string)` | `[]` | no |
| <a name="input_shared_organization_arns"></a> [shared\_organization\_arns](#input\_shared\_organization\_arns) | Set of AWS Organization ARNs to allow access to the created AMI | `set(string)` | `null` | no |
| <a name="input_shared_ou_arns"></a> [shared\_ou\_arns](#input\_shared\_ou\_arns) | Set of AWS Organizational Unit ARNs to allow access to the created AMI | `set(string)` | `null` | no |
| <a name="input_sns_topic_arn"></a> [sns\_topic\_arn](#input\_sns\_topic\_arn) | SNS topic to notify when new images are created | `string` | `null` | no |
| <a name="input_ssh_key_secret_arn"></a> [ssh\_key\_secret\_arn](#input\_ssh\_key\_secret\_arn) | If your ImageBuilder Components need to use an SSH Key (private repos, etc.), specify the ARN of the secretsmanager secret containing the SSH key to add access permissions (use arn OR name, not both) | `string` | `null` | no |
| <a name="input_ssh_key_secret_name"></a> [ssh\_key\_secret\_name](#input\_ssh\_key\_secret\_name) | If your ImageBuilder Components need to use an SSH Key (private repos, etc.), specify the Name of the secretsmanager secret containing the SSH key to add access permissions (use arn OR name, not both) | `string` | `null` | no |
| <a name="input_subnet"></a> [subnet](#input\_subnet) | Subnet ID to use for builder | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | map of tags to use for component | `map(string)` | `{}` | no |
| <a name="input_terminate_on_failure"></a> [terminate\_on\_failure](#input\_terminate\_on\_failure) | Change to false if you want to connect to a builder for debugging after failure | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_pipeline_arn"></a> [pipeline\_arn](#output\_pipeline\_arn) | ARN of EC2 Image Builder Pipeline |
| <a name="output_role_name"></a> [role\_name](#output\_role\_name) | The name of the IAM role for use if additional permissions are needed. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## The Giants underneath this module
- pre-commit.com/
- terraform.io/
- github.com/tfutils/tfenv
- github.com/segmentio/terraform-docs
