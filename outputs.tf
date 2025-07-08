output "lambda_function_name" {
  value = module.lambda.lambda_function_name
}


output "api_gateway_url" {
  value = module.api_gateway.api_url
}

output "api_url" {
  value = module.api_gateway.api_url
}
