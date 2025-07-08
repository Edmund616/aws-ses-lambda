resource "aws_api_gateway_rest_api" "email_api" {
  name        = "email-api"
  description = "API Gateway for sending email via Lambda"
}

resource "aws_api_gateway_resource" "send" {
  rest_api_id = aws_api_gateway_rest_api.email_api.id
  parent_id   = aws_api_gateway_rest_api.email_api.root_resource_id
  path_part   = "send"
}

resource "aws_api_gateway_method" "send_post" {
  rest_api_id   = aws_api_gateway_rest_api.email_api.id
  resource_id   = aws_api_gateway_resource.send.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id             = aws_api_gateway_rest_api.email_api.id
  resource_id             = aws_api_gateway_resource.send.id
  http_method             = aws_api_gateway_method.send_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${var.lambda_function_arn}/invocations"


}

resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    aws_api_gateway_method.send_post,
    aws_api_gateway_integration.lambda
  ]

  rest_api_id = aws_api_gateway_rest_api.email_api.id
}

resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.email_api.id
  stage_name    = "prod"
}
