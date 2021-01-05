# tell which cloud provider is required
provider "aws" {
  region = "eu-west-1"
}

resource "aws_instance" "nodejs_app_instance" {
  # ami_id of the app image created by packer
  ami = "ami-090c52809b287ad01"
  instance_type = "t2.micro"
  associate_public_ip_address = true
  tags = {
    Name = "eng74-amaan-nodeapp_terraform"
  }
  key_name = "eng74-amaan-aws"
}
