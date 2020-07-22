locals {
  parent_name = "parent_image"
  parent_version = "1._0.0"

  child_name = "child_image"
  child_version = "1.0.0"
}

# Parent component
module "parent_component" {
  source  = "rhythmictech/imagebuilder-component-ansible/aws"

  name              = local.parent_name

  component_version = local.parent_version
  playbook_dir      = "base"
  playbook_repo     = "https://github.com/rhythmictech/imagepipeline-examples.git"
}

module "parent_recipe" {
  source  = "rhythmictech/imagebuilder-recipe/aws"

  name           = local.parent_name

  parent_image   = "arn:aws:imagebuilder:us-east-1:aws:image/amazon-linux-2-x86/x.x.x"
  recipe_version = local.parent_version
  update         = true

  component_arns = [
    module.parent_component.component_arn,
    "arn:aws:imagebuilder:us-east-1:aws:component/simple-boot-test-linux/1.0.0/1",
    "arn:aws:imagebuilder:us-east-1:aws:component/reboot-test-linux/1.0.0/1"
  ]
}

module "parent_pipeline" {
  source  = "rhythmictech/imagebuilder-pipeline/aws"

  name        = local.parent_name

  public      = false
  recipe_arn  = module.parent_recipe.recipe_arn

  # run mondays at 00:00 GMT
  schedule = {
    PipelineExecutionStartCondition = "EXPRESSION_MATCH_AND_DEPENDENCY_UPDATES_AVAILABLE"
    ScheduleExpression              = "cron(0 0 * * mon)"
  }
}

# Child component
module "child_component" {
  source  = "rhythmictech/imagebuilder-component-ansible/aws"

  name              = local.child_name

  component_version = local.child_version
  playbook_dir      = "app"
  playbook_repo     = "https://github.com/rhythmictech/imagepipeline-examples.git"
}

module "child_recipe" {
  source  = "rhythmictech/imagebuilder-recipe/aws"

  name           = local.child_name

  parent_image   = "arn:aws:imagebuilder:us-east-1:aws:image/amazon-linux-2-x86/x.x.x"
  recipe_version = local.child_version
  update         = true

  component_arns = [
    module.child_component.component_arn,
    "arn:aws:imagebuilder:us-east-1:aws:component/simple-boot-test-linux/1.0.0/1",
    "arn:aws:imagebuilder:us-east-1:aws:component/reboot-test-linux/1.0.0/1"
  ]
}

module "child_pipeline" {
  source  = "rhythmictech/imagebuilder-pipeline/aws"

  name        = local.child_name

  public      = false
  recipe_arn  = module.child_recipe.recipe_arn

  # run mondays at 02:00 GMT
  schedule = {
    PipelineExecutionStartCondition = "EXPRESSION_MATCH_AND_DEPENDENCY_UPDATES_AVAILABLE"
    ScheduleExpression              = "cron(0 2 * * mon)"
  }
}
