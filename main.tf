module "lambda" {
  source       = "./modules/lambda"
  source_email = var.source_email
  dest_email   = var.dest_email
  aws_region   = var.aws_region
}

module "api_gateway" {
  source               = "./modules/api_gateway"
  lambda_function_arn  = module.lambda.lambda_function_arn
  lambda_function_name = module.lambda.lambda_function_name
  aws_region           = var.aws_region
}

module "ses" {
  source       = "./modules/ses"
  source_email = var.source_email
}

resource "aws_lambda_function" "my_lambda" {
  filename         = "lambda_function_payload.zip"
  function_name    = "my_lambda"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "lambda_function.lambda_handler"
  source_code_hash = filebase64sha256("lambda_function_payload.zip")
  runtime          = "python3.12"
  timeout          = 10
}

  # environment variables, timeout, etc.

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role_${random_id.suffix.hex}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "lambda_logs" {
  name       = "lambda_logs"
  roles      = [aws_iam_role.lambda_exec.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

