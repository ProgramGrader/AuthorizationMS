# after terraform init go to /.terraform/modules/Deployer
# in the main file lambda_function resource add this to define the s3
# bucket where cerbos policies where stored
#  environment {
#variables = {
#  BUCKET_URL: ""
#  BUCKET_PREFIX: ""
#  CERBOS_LOG_LEVEL: INFO
#}
#}
module "Deployer"{
  source = "git::git@github.com:ProgramGrader/terraform-aws-kotlin-image-deploy-lambda.git"
  account_id                      = "048962136615"
  ecr_tags = {
    Type    = "lambda"
    Version = "latest"
  }

#  environment = [{
#    BUCKET_URL: data.aws_s3_bucket.csgraderPolicyBucket.bucket_regional_domain_name
#    BUCKET_PREFIX: ""
#    CERBOS_LOG_LEVEL: "INFO"
#    REMOTE_CERBOS_URL: aws_api_gateway_stage.default.invoke_url
#  }]


  lambda_file_name                = ["AuthorizerCerbos"]
  reserved_concurrent_executions = [null] // defining how many concurrent executions each respected lambda is allowed to have
  region                          = "us-east-2"
}

data "aws_s3_bucket" "csgraderPolicyBucket" {
  bucket = "csgrader-policy-bucket"
}
// how does cerbos parse the apigateway request to get the actual cerbos request