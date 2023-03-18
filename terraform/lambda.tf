module "Deployer"{
  source = "git::git@github.com:ProgramGrader/terraform-aws-kotlin-image-deploy-lambda.git"
  account_id                      = "048962136615"
  ecr_tags = {
    Type    = "lambda"
    Version = "latest"
  }
  lambda_file_name                = ["AuthorizerCerbos"] //"EcsTaskRunner"]
  reserved_concurrent_executions = [null] // defining how many concurrent executions each respected lambda is allowed to have
  region                          = "us-east-2"

}