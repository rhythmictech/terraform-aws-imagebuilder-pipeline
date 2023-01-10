locals {
  has_ssh_key_secret = var.ssh_key_secret_arn != null || var.ssh_key_secret_name != null

  image_name = coalesce(
    var.image_name,
    var.name
  )

  log_prefix_computed = (
    var.log_prefix != null
    ? replace("/${var.log_prefix}/*", "//{2,}/", "/")
    : "/*"
  )

  shared_user_groups             = var.public ? ["all"] : null
  use_custom_distribution_config = var.custom_distribution_configs != null ? true : false

}

data "aws_iam_policy_document" "log_write" {
  count = var.log_bucket != null ? 1 : 0

  statement {
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${var.log_bucket}${local.log_prefix_computed}"]
  }
}

resource "aws_iam_policy" "log_write" {
  count = var.log_bucket != null ? 1 : 0

  name_prefix = "${var.name}-logging-policy-"
  description = "IAM policy granting write access to the logging bucket for ${var.name}"
  policy      = data.aws_iam_policy_document.log_write[0].json
}

data "aws_secretsmanager_secret" "ssh_key" {
  count = local.has_ssh_key_secret ? 1 : 0

  arn  = var.ssh_key_secret_arn
  name = var.ssh_key_secret_name
}

data "aws_iam_policy_document" "secret_read" {
  count = local.has_ssh_key_secret ? 1 : 0

  statement {
    resources = [data.aws_secretsmanager_secret.ssh_key[0].arn]

    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds"
    ]
  }
}

resource "aws_iam_policy" "secret_read" {
  count = local.has_ssh_key_secret ? 1 : 0

  name_prefix = "${var.name}-secret-read-policy-"
  description = "IAM policy granting read access to the ssh key secret at ${data.aws_secretsmanager_secret.ssh_key[0].name}"
  policy      = data.aws_iam_policy_document.secret_read[0].json
}

locals {
  core_iam_policies = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilder"
  ]
}

data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  assume_role_policy = data.aws_iam_policy_document.assume.json
  name_prefix        = "${var.name}-imagebuilder-role-"

  tags = merge(
    var.tags,
    {
      Name : "${var.name}-imagebuilder-role"
    }
  )
}

resource "aws_iam_role_policy_attachment" "core" {
  count = length(local.core_iam_policies)

  policy_arn = local.core_iam_policies[count.index]
  role       = aws_iam_role.this.name
}

resource "aws_iam_role_policy_attachment" "log_write" {
  count = var.log_bucket != null ? 1 : 0

  policy_arn = aws_iam_policy.log_write[0].arn
  role       = aws_iam_role.this.name
}

resource "aws_iam_role_policy_attachment" "secret_read" {
  count = local.has_ssh_key_secret ? 1 : 0

  policy_arn = aws_iam_policy.secret_read[0].arn
  role       = aws_iam_role.this.name
}

resource "aws_iam_role_policy_attachment" "additional" {
  count = length(var.additional_iam_policy_arns)

  policy_arn = var.additional_iam_policy_arns[count.index]
  role       = aws_iam_role.this.name
}

resource "aws_iam_instance_profile" "this" {
  name_prefix = "${var.name}-imagebuilder-instance-profile-"
  role        = aws_iam_role.this.name
}


resource "aws_imagebuilder_image_pipeline" "this" {
  name = var.name

  container_recipe_arn             = var.container_recipe_arn
  description                      = var.description
  distribution_configuration_arn   = aws_imagebuilder_distribution_configuration.this.arn
  enhanced_image_metadata_enabled  = var.enhanced_image_metadata_enabled
  image_recipe_arn                 = var.image_recipe_arn
  infrastructure_configuration_arn = aws_imagebuilder_infrastructure_configuration.this.arn
  status                           = var.enabled
  tags                             = var.tags

  image_tests_configuration {
    image_tests_enabled = var.image_tests_enabled
    timeout_minutes     = var.image_tests_timeout_minutes
  }

  dynamic "schedule" {
    for_each = var.schedule_cron != "" ? ["1"] : []
    content {
      pipeline_execution_start_condition = var.schedule_pipeline_execution_start_condition
      schedule_expression                = var.schedule_cron
      timezone                           = var.schedule_timezone
    }
  }
}

resource "aws_imagebuilder_infrastructure_configuration" "this" {
  name                          = "${var.name} - Infrastructure Config"
  description                   = var.description
  instance_profile_name         = aws_iam_instance_profile.this.name
  instance_types                = var.instance_types
  key_pair                      = var.instance_key_pair
  resource_tags                 = var.resource_tags
  security_group_ids            = var.security_group_ids
  sns_topic_arn                 = var.sns_topic_arn
  subnet_id                     = var.subnet
  tags                          = var.tags
  terminate_instance_on_failure = var.terminate_on_failure

  dynamic "logging" {
    for_each = var.log_bucket != "" ? ["1"] : []
    content {
      s3_logs {
        s3_bucket_name = var.log_bucket
        s3_key_prefix  = var.log_prefix
      }
    }
  }

  instance_metadata_options {
    http_put_response_hop_limit = var.instance_metadata_http_put_hop_limit
    http_tokens                 = var.instance_metadata_http_tokens
  }

}

resource "aws_imagebuilder_distribution_configuration" "this" {
  name        = "${var.name} - Distribution Config"
  description = var.description
  tags        = var.tags
  # We'll normally use this, a sane distribution configuration for creating AMIs
  dynamic "distribution" {
    for_each = var.regions
    content {
      region                     = distribution.value
      license_configuration_arns = var.license_config_arns
      ami_distribution_configuration {
        ami_tags    = var.tags
        description = var.description
        kms_key_id  = var.kms_key_id
        name        = "${local.image_name}-{{ imagebuilder:buildDate }}"
        launch_permission {
          organization_arns        = var.shared_organization_arns
          organizational_unit_arns = var.shared_ou_arns
          user_groups              = local.shared_user_groups
          user_ids                 = var.shared_account_ids
        }
      }
    }
  }
  # Here be dragons. This is for specifying a custom set of distribution configurations as a parameter to the module.
  # If you're not using the custom_distribution_configs var you can ignore this dynamic block safely.
  dynamic "distribution" {
    for_each = local.use_custom_distribution_config ? var.custom_distribution_configs : []
    content {
      region                     = lookup(distribution.value, "region", null)
      license_configuration_arns = lookup(distribution.value, "license_configuration_arns", null)

      dynamic "ami_distribution_configuration" {
        for_each = length(keys(lookup(distribution.value, "ami_distribution_configuration", {}))) == 0 ? [] : [lookup(distribution.value, "ami_distribution_configuration", {})]
        content {
          ami_tags           = lookup(ami_distribution_configuration.value, "ami_tags", null)
          description        = lookup(ami_distribution_configuration.value, "description", null)
          kms_key_id         = lookup(ami_distribution_configuration.value, "kms_key_id", null)
          name               = lookup(ami_distribution_configuration.value, "name", null)
          target_account_ids = lookup(ami_distribution_configuration.value, "target_account_ids", null)

          dynamic "launch_permission" {
            for_each = length(keys(lookup(ami_distribution_configuration.value, "launch_permission", {}))) == 0 ? [] : [lookup(ami_distribution_configuration.value, "launch_permission", {})]
            content {
              organization_arns        = lookup(launch_permission.value, organization_arns, null)
              organizational_unit_arns = lookup(launch_permission.value, organizational_unit_arns, null)
              user_groups              = lookup(launch_permission.value, user_groups, null)
              user_ids                 = lookup(launch_permission.value, user_ids, null)
            }
          }
        }
      }

      dynamic "container_distribution_configuration" {
        for_each = length(keys(lookup(distribution.value, "container_distribution_configuration", {}))) == 0 ? [] : [lookup(distribution.value, "container_distribution_configuration", {})]
        content {
          container_tags = lookup(container_distribution_configuration.value, "container_tags", null)
          description    = lookup(container_distribution_configuration.value, "description", null)
          dynamic "target_repository" {
            for_each = length(keys(lookup(container_distribution_configuration.value, "target_repository", {}))) == 0 ? [] : [lookup(container_distribution_configuration.value, "target_repository", {})]
            content {
              repository_name = lookup(target_repository.value, "repository_name", null)
              service         = lookup(target_repository.value, "service", null)
            }
          }
        }
      }

      dynamic "fast_launch_configuration" {
        for_each = length(keys(lookup(distribution.value, "fast_launch_configuration", {}))) == 0 ? [] : [lookup(distribution.value, "fast_launch_configuration", {})]
        content {
          account_id            = lookup(fast_launch_configuration.value, "account_id", null)
          enabled               = lookup(fast_launch_configuration.value, "enabled", null)
          max_parallel_launches = lookup(fast_launch_configuration.value, "max_parallel_launches", null)

          dynamic "launch_template" {
            for_each = length(keys(lookup(fast_launch_configuration.value, "launch_template", {}))) == 0 ? [] : [lookup(fast_launch_configuration.value, "launch_template", {})]
            content {
              launch_template_id      = lookup(launch_template.value, "launch_template_id", null)
              launch_template_name    = lookup(launch_template.value, "launch_template_name", null)
              launch_template_version = lookup(launch_template.value, "launch_template_version", null)
            }
          }

          dynamic "snapshot_configuration" {
            for_each = length(keys(lookup(fast_launch_configuration.value, "snapshot_configuration", {}))) == 0 ? [] : [lookup(fast_launch_configuration.value, "snapshot_configuration", {})]
            content {
              target_resource_count = lookup(snapshot_configuration.value, "target_resource_count", null)
            }
          }
        }
      }

      dynamic "launch_template_configuration" {
        for_each = length(keys(lookup(distribution.value, "launch_template_configuration", {}))) == 0 ? [] : [lookup(distribution.value, "launch_template_configuration", {})]
        content {
          default            = lookup(launch_template_configuration.value, "default", null)
          account_id         = lookup(launch_template_configuration.value, "account_id", null)
          launch_template_id = lookup(launch_template_configuration.value, "launch_template_id", null)
        }
      }
    }
  }
}
