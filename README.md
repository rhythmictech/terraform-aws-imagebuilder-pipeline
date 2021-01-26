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

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12.19 |
| aws | >= 2.44 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 2.44 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | name to use for component | `string` | n/a | yes |
| recipe\_arn | ARN of the recipe to use. Must change with Recipe version | `string` | n/a | yes |
| additional\_iam\_policy\_arns | List of ARN policies for addional builder permissions | `list(string)` | `[]` | no |
| cloudformation\_timeout | How long to wait (in minutes) for CFN to apply before giving up | `number` | `10` | no |
| description | description of component | `string` | `null` | no |
| enabled | Whether pipeline is ENABLED or DISABLED | `bool` | `true` | no |
| image\_name | The name prefix given to the AMI created by the pipeline (a timestamp will be added to the end) | `string` | `""` | no |
| instance\_types | Instance types to create images from. It's unclear why this is a list. Possibly because different types can result in different images (like ARM instances) | `list(string)` | <pre>[<br>  "t3.medium"<br>]</pre> | no |
| key\_pair | EC2 key pair to add to the default user on the builder | `string` | `null` | no |
| license\_config\_arns | If you're using License Manager, your ARNs go here | `list(string)` | `null` | no |
| log\_bucket | Bucket to store logs in. If this is ommited logs will not be stored | `string` | `null` | no |
| log\_prefix | S3 prefix to store logs at. Recommended if sharing bucket with other pipelines | `string` | `null` | no |
| public | Whether resulting AMI should be public | `bool` | `false` | no |
| regions | Regions that AMIs will be available in | `list(string)` | <pre>[<br>  "us-east-1",<br>  "us-east-2",<br>  "us-west-1",<br>  "us-west-2",<br>  "ca-central-1"<br>]</pre> | no |
| schedule | Schedule expression for when pipeline should run automatically https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-imagebuilder-imagepipeline-schedule.html | <pre>object({<br>    PipelineExecutionStartCondition = string<br>    ScheduleExpression              = string<br>  })</pre> | <pre>{<br>  "PipelineExecutionStartCondition": "EXPRESSION_MATCH_AND_DEPENDENCY_UPDATES_AVAILABLE",<br>  "ScheduleExpression": "cron(0 0 * * mon)"<br>}</pre> | no |
| security\_group\_ids | Security group IDs for the Image Builder | `list(string)` | `null` | no |
| shared\_account\_ids | AWS accounts to share AMIs with. If this is left null AMIs will be public | `list(string)` | `[]` | no |
| sns\_topic\_arn | SNS topic to notify when new images are created | `string` | `null` | no |
| ssh\_key\_secret\_arn | ARN of a secretsmanager secret containing an SSH key (use arn OR name, not both) | `string` | `null` | no |
| ssh\_key\_secret\_name | Name of a secretsmanager secret containing an SSH key (use arn OR name, not both) | `string` | `null` | no |
| subnet | Subnet ID to use for builder | `string` | `null` | no |
| tags | map of tags to use for CFN stack and component | `map(string)` | `{}` | no |
| terminate\_on\_failure | Change to false if you want to ssh into a builder for debugging after failure | `bool` | `true` | no |
| test\_config | Whether to run tests during image creation and maximum time to allow tests to run | <pre>object({<br>    ImageTestsEnabled = bool<br>    TimeoutMinutes    = number<br>  })</pre> | <pre>{<br>  "ImageTestsEnabled": true,<br>  "TimeoutMinutes": 60<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| pipeline\_arn | ARN of EC2 Image Builder Pipeline |
| role\_name | The name of the IAM role for use if additional permissions are needed. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## The Giants underneath this module
- pre-commit.com/
- terraform.io/
- github.com/tfutils/tfenv
- github.com/segmentio/terraform-docs
