
variable "aws_access_key" {
  description = "Access key ID"
  default     = ""
}

variable "aws_secret_key" {
  description = "Secret key of access key ID"
  default     = ""
}

variable "region" {
  description = "AWS region where the project is applied"
  default     = "eu-central-1"
}

variable "public_key" {
  description = "Public key for access to the instances (only main part, without ssh-rsa and comment)"
  default     = ""
}
