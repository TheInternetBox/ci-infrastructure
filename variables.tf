
variable "github_app_key_base64" {
    type = string
}

variable "github_app_id" {
    type = string
}

variable "environment" {
    type = string
    default = "internetbox-ephemeral-ci"
}

variable "aws_region" {
    type = string
    default = "us-east-2"
}