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
  source  = "app.terraform.io/zacclifton/kotlin-image-deploy-lambda/aws"
  version = "0.0.8"
  account_id                      = "048962136615"
  ecr_tags = {
    Type    = "lambda"
    Version = "latest"
  }

  environment = [{
    BUCKET_URL: "s3://${data.aws_s3_bucket.csgraderPolicyBucket.id}?region=${data.aws_s3_bucket.csgraderPolicyBucket.region}"
    BUCKET_PREFIX: "policies" #Look for policies only under this key prefix.
    CERBOS_LOG_LEVEL: "INFO"
    REMOTE_CERBOS_URL: aws_apigatewayv2_stage.stage.invoke_url
#    AWS_ACCESS_KEY_ID: var.aws_access_key # These are reserved aws environment names and are not allowed to be overwritten
#    AWS_SECRET_ACCESS_KEY: var.aws_secret_key
  }]


  lambda_file_name                = ["AuthorizerCerbos"]
  reserved_concurrent_executions = [null] // defining how many concurrent executions each respected lambda is allowed to have
  region                          = "us-east-2"
}

data "aws_s3_bucket" "csgraderPolicyBucket" {
  bucket = "csgrader-policy-bucket"
}

resource "aws_iam_policy" "s3_permissions_lambda" {
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [{
      "Action": [
        "s3:ListBucket",
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_to_lambda_role" {
  policy_arn = aws_iam_policy.s3_permissions_lambda.arn
  role       = module.Deployer.lambda_role_name["AuthorizerCerbos"]
}
