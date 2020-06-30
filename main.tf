locals {
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

  description = "IAM policy granting write access to the logging bucket for ${var.name}"
  name_prefix = "${var.name}-logging-policy-"
  policy      = data.aws_iam_policy_document.log_write[count.index].json
}

locals {
  core_iam_policies = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilder"
  ]
  iam_policies = concat(
    local.core_iam_policies,
    aws_iam_policy.log_write[*].arn,
    var.additional_iam_policy_arns
  )
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

resource "aws_iam_role_policy_attachment" "this" {
  count = (
    var.log_bucket == null
    ? length(local.core_iam_policies) + length(var.additional_iam_policy_arns)
    : length(local.core_iam_policies) + length(var.additional_iam_policy_arns) + 1
  )

  policy_arn = local.iam_policies[count.index]
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
