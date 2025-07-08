variable "source_email" {
  description = "Verified SES email address to send from"
  type        = string
}

variable "dest_email" {
  description = "Recipient email address"
  type        = string
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}
