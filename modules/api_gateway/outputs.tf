output "api_url" {
  value = "https://${aws_api_gateway_rest_api.email_api.id}.execute-api.${var.aws_region}.amazonaws.com/prod"
}

