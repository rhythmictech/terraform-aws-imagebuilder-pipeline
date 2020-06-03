# basic example
A basic example for this repository

## Code
```hcl
module "test_pipeline" {
  source  = "rhythmictech/imagebuilder-pipeline/aws"
  version = "~> 0.3.0"

  description = "Testing pipeline"
  name        = "test-pipeline"
  tags        = local.tags
  recipe_arn  = module.test_recipe.recipe_arn
  public      = false
}
```

## Applying
```
>  terraform apply

Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

pipeline_arn = arn:aws:imagebuilder:us-east-1:000000000000:image-pipeline/test-pipeline
```
