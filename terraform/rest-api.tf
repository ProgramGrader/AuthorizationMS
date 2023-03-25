resource "aws_apigatewayv2_api" "api" {
  name          = "AuthorizationMS"
  protocol_type = "HTTP"
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
  function_name = "LambdaAuthorizer"
}

data "aws_iam_role" "invocation_role" {
  name = "gateway_auth_invocation"
}

resource "aws_apigatewayv2_authorizer" "auth" {
  api_id          =  aws_apigatewayv2_api.api.id
  authorizer_type = "REQUEST"
  identity_sources = ["$request.header.Authorization"]
  authorizer_credentials_arn = data.aws_iam_role.invocation_role.arn
  name            = data.aws_lambda_function.auth.function_name
  authorizer_uri = data.aws_lambda_function.auth.invoke_arn
  authorizer_payload_format_version = "1.0"
}

resource "aws_apigatewayv2_stage" "stage" {
  api_id = aws_apigatewayv2_api.api.id
  name   = "dev"
  auto_deploy = true
}

resource "aws_apigatewayv2_integration" "api_integration" {
  api_id             = aws_apigatewayv2_api.api.id
  integration_type   = "AWS_PROXY"
  integration_uri    =module.Deployer.lambda_invoke_arn["AuthorizerCerbos"]
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "route" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "ANY /{proxy+}" //var.api_route_key
  authorization_type = "CUSTOM"
  authorizer_id = aws_apigatewayv2_authorizer.auth.id
  target = "integrations/${aws_apigatewayv2_integration.api_integration.id}"

}


resource "aws_apigatewayv2_deployment" "deployment" {
  depends_on = [aws_apigatewayv2_route.route]
  api_id      = aws_apigatewayv2_api.api.id
}

// adding permission to allow api gw to invoke the lambda
resource "aws_lambda_permission" "allow_apigw_to_trigger_lambda" {
  action        = "lambda:InvokeFunction"
  function_name = "AuthorizerCerbos"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*"


}
