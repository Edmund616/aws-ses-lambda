output "lambda_function_arn" {
  value = aws_lambda_function.email_lambda.arn
}

output "lambda_function_name" {
  value = aws_lambda_function.email_lambda.function_name
}

