#!/bin/bash

mkdir -p modules/lambda modules/ses modules/api_gateway

# Lambda module
cat > modules/lambda/main.tf <<'EOF'
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "email_lambda" {
  filename         = "${path.module}/../../lambda.zip"
  function_name    = "sendEmailLambda"
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
  source_code_hash = filebase64sha256("${path.module}/../../lambda.zip")

  environment {
    variables = {
      SOURCE_EMAIL = var.source_email
      DEST_EMAIL   = var.dest_email
      AWS_REGION   = var.aws_region
    }
  }
}
EOF

cat > modules/lambda/variables.tf <<'EOF'
variable "source_email" {
  type = string
}

variable "dest_email" {
  type = string
}

variable "aws_region" {
  type = string
}
EOF

cat > modules/lambda/outputs.tf <<'EOF'
output "function_name" {
  value = aws_lambda_function.email_lambda.function_name
}

output "function_arn" {
  value = aws_lambda_function.email_lambda.arn
}
EOF

# SES module
cat > modules/ses/main.tf <<'EOF'
resource "aws_ses_email_identity" "email" {
  email = var.source_email
}
EOF

cat > modules/ses/variables.tf <<'EOF'
variable "source_email" {
  type = string
}
EOF

# API Gateway module
cat > modules/api_gateway/main.tf <<'EOF'
resource "aws_apigatewayv2_api" "http_api" {
  name          = "email-api"
  protocol_type = "HTTP"
}

resource "aws_lambda_permission" "allow_apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.lambda_function_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "post_send" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /send"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}
EOF

cat > modules/api_gateway/variables.tf <<'EOF'
variable "lambda_function_name" {
  type = string
}

variable "lambda_function_arn" {
  type = string
}
EOF

cat > modules/api_gateway/outputs.tf <<'EOF'
output "api_url" {
  value = aws_apigatewayv2_api.http_api.api_endpoint
}
EOF

echo "✅ All module .tf files generated successfully!"
