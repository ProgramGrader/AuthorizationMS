module "authenticated_rest_api" {
  source = "git::git@github.com:ProgramGrader/terraform-deploy-authenticated-api-gateway.git"
  account_id= "048962136615"
  api_gateway_name = "AuthorizationMS"
  region = "us-east-2"
}

resource "aws_api_gateway_resource" "auth_resource" {
  parent_id   =  module.authenticated_rest_api.api_gateway_root_resource_id
  path_part   = "/"
  rest_api_id = module.authenticated_rest_api.api_gateway_id
}


resource "aws_api_gateway_method" "POST" {
  authorization = "Custom"
  authorizer_id = module.authenticated_rest_api.authorizer_id
  http_method   = "POST"
  resource_id   = aws_api_gateway_resource.auth_resource.id
  rest_api_id   = module.authenticated_rest_api.api_gateway_id

  request_parameters = {
    "method.request.path.proxy" = true
  }
}

// this resource describes how we are going to react to the request received
resource "aws_api_gateway_integration" "integrate" {
  http_method = aws_api_gateway_method.POST.http_method
  integration_http_method = "POST"
  resource_id = aws_api_gateway_resource.auth_resource.id
  rest_api_id = module.authenticated_rest_api.api_gateway_id
  type        = "AWS_PROXY"
  uri = module.Deployer.lambda_invoke_arn["AuthorizerCerbos"]
}

resource "aws_api_gateway_deployment" "deploy" {
  depends_on = [aws_api_gateway_integration.integrate]
  rest_api_id = module.authenticated_rest_api.api_gateway_id

  lifecycle {
    create_before_destroy = true
  }

  description = "Deployed endpoint at ${timestamp()}"
}

resource "aws_api_gateway_stage" "dev"{
  deployment_id = aws_api_gateway_deployment.deploy.id
  rest_api_id   = module.authenticated_rest_api.api_gateway_id
  stage_name    = "dev"
  xray_tracing_enabled = true
}

resource "aws_lambda_permission" "allow_apigw_to_trigger_auth_lambda" {
  depends_on = [module.Deployer["AuthorizerCerbos"]]
  statement_id = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "AuthorizerCerbos"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${module.authenticated_rest_api.api_gateway_execution_arn}/*/*"
}
