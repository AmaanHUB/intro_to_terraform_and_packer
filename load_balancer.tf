resource "aws_lb" "lb" {
  name = "eng74-amaan-load_balancer_Terraform"
  internal = false
  load_balancer_type = "network"
  subnets = aws_subnet.subnet_public.*.id

  tags = {
    Name = "eng74-amaan-load_balancer_Terraform"
  }
}

resource "aws_lb_target_group" "target_group" {
  name = "eng74-amaan-target_group_Terraform"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "eng74-amaan-target_group_Terraform"
  }
}
