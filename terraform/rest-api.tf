
module "authenticated_api_gateway"{
  source = "git::git@github.com:ProgramGrader/terraform-deploy-authenticated-api-gateway.git"
  account_id = "048962136615"
  api_gateway_name  = "AuthorizationMS"
  region            = "us-east-2"
  gateway_version = 2
}

// Defining permissions so that API gateway has permissions
resource "aws_iam_role" "apigw-role" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "aws_lambda_function" "auth" {
  function_name = "APIGatewayV2Authorizer"
}

data "aws_iam_role" "invocation_role" {
  name = "gateway_auth_invocation"
}


resource "aws_cloudwatch_log_group" "api_gateway_logs" {
  name = "/aws/apigateway/${module.authenticated_api_gateway.apigateway_name}"
}

resource "aws_api_gateway_account" "cloudwatch" {
  cloudwatch_role_arn = aws_iam_role.cloudwatch.arn
}
resource "aws_iam_role" "cloudwatch" {
  name               = "api_gateway_cloudwatch"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}
data "aws_iam_policy_document" "cloudwatch" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
      "logs:GetLogEvents",
      "logs:FilterLogEvents",
    ]

    resources = ["*"]
  }
}
resource "aws_iam_role_policy" "cloudwatch" {
  name   = "default"
  role   = aws_iam_role.cloudwatch.id
  policy = data.aws_iam_policy_document.cloudwatch.json
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "api_gateway_logs" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }
}


resource "aws_apigatewayv2_stage" "stage" {
  api_id = module.authenticated_api_gateway.api_gateway_id
  name   = "$default"
  default_route_settings {
    logging_level = "INFO"
    detailed_metrics_enabled = true
    throttling_rate_limit =20000
    throttling_burst_limit = 10000
  }
#  access_log_settings {
#    destination_arn = aws_iam_role.cloudwatch.arn
#    format          = "$context.requestId"
#  }

  auto_deploy =true
}

resource "aws_apigatewayv2_integration" "api_integration" {
  api_id             = module.authenticated_api_gateway.api_gateway_id
  integration_type   = "AWS_PROXY"
  integration_uri    =module.Deployer.lambda_invoke_arn["AuthorizerCerbos"]
  integration_method = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "route" {
  api_id    = module.authenticated_api_gateway.api_gateway_id
  route_key = "ANY /{proxy+}" //var.api_route_key
  authorization_type = "CUSTOM"
  authorizer_id = module.authenticated_api_gateway.authorizer_id
  target = "integrations/${aws_apigatewayv2_integration.api_integration.id}"

}


// adding permission to allow api gw to invoke the lambda
resource "aws_lambda_permission" "allow_apigw_to_trigger_lambda" {
  action        = "lambda:InvokeFunction"
  function_name = "AuthorizerCerbos"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${module.authenticated_api_gateway.api_gateway_execution_arn}/*/*/*"


}
