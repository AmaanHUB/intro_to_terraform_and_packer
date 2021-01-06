variable "region" {
  default = "eu-west-1"
}

variable "key_name" {
  default = "eng74-amaan-aws"
}

variable "nodejs_app_ami" {
  default = "ami-090c52809b287ad01"
}

variable "mongodb_ami" {
  default = "ami-0ac79c29e0394a94f"
}

variable "nodejs_app_SG" {
  default = "eng74-amaan-SG_APP_Terraform"
}

variable "mongodb_SG" {
  default = "eng74-amaan-SG_DB_Terraform"
}

variable "aws_key_path" {
  default = "~/.ssh/eng74-amaan-aws.pem"
}


