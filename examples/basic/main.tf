module "test_component" {
  source = "rhythmictech/imagebuilder-component-ansible/aws"

  name = "testing-component"

  component_version = "1.0.0"
  description       = "Testing component"
  playbook_dir      = "packer-generic-images/base"
  playbook_repo     = "https://github.com/rhythmictech/packer-generic-images.git"
}

module "test_recipe" {
  source = "rhythmictech/imagebuilder-recipe/aws"

  name = "test-recipe"

  description    = "Testing recipe"
  parent_image   = "arn:aws:imagebuilder:us-east-1:aws:image/amazon-linux-2-x86/x.x.x"
  recipe_version = "1.0.0"
  update         = true

  component_arns = [
    module.test_component.component_arn,
    "arn:aws:imagebuilder:us-east-1:aws:component/simple-boot-test-linux/1.0.0/1",
    "arn:aws:imagebuilder:us-east-1:aws:component/reboot-test-linux/1.0.0/1"
  ]
}

module "test_pipeline" {
  source = "rhythmictech/imagebuilder-pipeline/aws"

  name = "test-pipeline"

  description = "Testing pipeline"
  public      = false
  recipe_arn  = module.test_recipe.recipe_arn

  regions = [
    "us-east-1",
    "us-east-2"
  ]
}
