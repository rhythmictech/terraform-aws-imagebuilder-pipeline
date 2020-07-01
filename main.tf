locals {
  has_ssh_key = var.ssh_key_secret_arn != null || var.ssh_key_secret_name != null

  image_name = coalesce(
    var.image_name,
    var.name
  )

  log_prefix_computed = (
    var.log_prefix != null
    ? replace("/${var.log_prefix}/*", "//{2,}/", "/")
    : "/*"
  )
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
  count = local.has_ssh_key ? 1 : 0

  arn  = var.ssh_key_secret_arn
  name = var.ssh_key_secret_name
}

data "aws_iam_policy_document" "secret_read" {
  count = local.has_ssh_key ? 1 : 0

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
  count = local.has_ssh_key ? 1 : 0

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
  count = local.has_ssh_key ? 1 : 0

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

resource "aws_cloudformation_stack" "this" {
  name               = var.name
  on_failure         = "ROLLBACK"
  timeout_in_minutes = var.cloudformation_timeout

  tags = merge(
    var.tags,
    { Name : "${var.name}-stack" }
  )

  template_body = templatefile("${path.module}/cloudformation.yml.tpl", {
    name                 = var.name
    description          = var.description
    image_name           = local.image_name
    instance_profile     = aws_iam_instance_profile.this.name
    instance_types       = var.instance_types
    key_pair             = var.key_pair
    license_config_arns  = var.license_config_arns
    log_bucket           = var.log_bucket
    log_prefix           = var.log_prefix
    public               = var.public
    recipe_arn           = var.recipe_arn
    regions              = var.regions
    schedule             = var.schedule
    security_group_ids   = var.security_group_ids
    shared_account_ids   = var.shared_account_ids
    sns_topic_arn        = var.sns_topic_arn
    status               = var.enabled ? "ENABLED" : "DISABLED"
    subnet               = var.subnet
    terminate_on_failure = var.terminate_on_failure
    test_config          = var.test_config

    tags = merge(
      var.tags,
      { Name : var.name }
    )
  })
}
