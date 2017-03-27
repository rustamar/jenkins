# Specify the provider and access details
provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.aws_region}"
}

resource "aws_key_pair" "admin" {
  key_name   = "admin"
  public_key = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAmRKwi6zbhzrg+tEl1O9c2LiHACFN+/j3ZgDKe2/5J4qKlGTmc8KUzSSwO9LApPAeHu0efsxCCzSXHr9YfSgt2Bg1j7ppxdLlxPMmtLf3i2gROmY/CcV/wUOnZ+L6O3PXpKz2XT0iwjbTlCG/NO9NvHuQxYE01hVDHjdEZiXBtRBurwFP7aXZ2XgxbCEMgQhLJhkTXPhyNQMDtw/yo/i4eETnKvKmt7DdTZP+hUMMXhRvwKsoXPIKPYtH82G1eXPtv19O1EnZUDIPUy+ZR34ZP66gxxzi8/xKkZOH6FRAYkmoXfZWAQrpngosay1AbhlX+5TfuAFgU2AB2ig8rzb7hQIDAQAB"
}
