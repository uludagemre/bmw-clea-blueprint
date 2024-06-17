provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Env       = "dev"
      App       = "dev-my-elt"
      ManagedBy = "Terraform"
    }
  }
}
