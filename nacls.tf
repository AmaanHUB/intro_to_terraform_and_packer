# create an NACL for Public subnet
resource "aws_network_acl" "public_nacl" {
  vpc_id = aws_vpc.vpc.id
  subnet_ids = [aws_subnet.subnet_public.id]

  egress {
    protocol = "all"
    rule_no = 100
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 0
    to_port = 0
  }

  # allow 27017 to the private subnet
  egress {
    protocol = "tcp"
    rule_no = 110
    action = "allow"
    cidr_block = "23.15.2.0/24"
    from_port = 27017
    to_port = 27017
  }

  ingress {
    protocol = "tcp"
    rule_no = 100
    action = "allow"
    cidr_block = "81.104.154.91/32"
    from_port = 22
    to_port = 22
  }

  ingress {
    protocol = "tcp"
    rule_no = 200
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 80
    to_port = 80
  }

  ingress {
    protocol = "tcp"
    rule_no = 300
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 443
    to_port = 443
  }

  ingress {
    protocol = "tcp"
    rule_no = 400
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 1024
    to_port = 65535
  }


  tags = {
    Name = "eng74-amaan-NACL_Public_Terraform"
  }
}

# NACLs for Private subnet
resource "aws_network_acl" "private_nacl" {
  vpc_id = aws_vpc.vpc.id
  subnet_ids = [aws_subnet.subnet_private.id]

  # allow SSH from public subnet
  ingress {
    protocol = "tcp"
    rule_no = 100
    action = "allow"
    cidr_block = "23.15.1.0/24"
    from_port = 22
    to_port = 22
  }

  # allow 27017 from public subnet
  ingress {
    protocol = "tcp"
    rule_no = 110
    action = "allow"
    cidr_block = "23.15.1.0/24"
    from_port = 27017
    to_port = 27017
  }

  ingress {
    protocol = "tcp"
    rule_no = 120
    action = "allow"
    cidr_block = "81.104.154.91/32"
    from_port = 22
    to_port = 22
  }

  # allow ephemeral to public subnet
  egress {
    protocol = "tcp"
    rule_no = 100
    action = "allow"
    cidr_block = "23.15.1.0/24"
    from_port = 1024
    to_port = 65535
  }

  tags = {
    Name = "eng74-amaan-NACL_Private_NACL"
  }
}
