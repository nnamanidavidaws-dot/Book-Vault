resource "aws_vpc" "bookvault" {
  cidr_block = "10.123.0.0/16"

  tags = {
    Name = "bookvault-vpc"
  }
}

resource "aws_subnet" "bookvault_public_subnet" {
  vpc_id            = aws_vpc.bookvault.id
  cidr_block        = "10.123.1.0/24"
  availability_zone = var.azs[0]

  tags = {
    Name = "bookvault-public-subnet"
  }
}

resource "aws_subnet" "bookvault_public_subnet_2" {
    vpc_id            = aws_vpc.bookvault.id
    cidr_block        = "10.123.4.0/24"
    availability_zone = var.azs[1]

    tags = {
        Name = "bookvault-public-subnet-2"
    }
}

resource "aws_subnet" "bookvault_private_subnet" {
  vpc_id            = aws_vpc.bookvault.id
  cidr_block        = "10.123.2.0/24"
  availability_zone = var.azs[0]

  tags = {
    Name = "bookvault-private-subnet"
  }
}

resource "aws_subnet" "bookvault_private_subnet_2" {
  vpc_id            = aws_vpc.bookvault.id
  cidr_block        = "10.123.3.0/24"
  availability_zone = var.azs[1]

  tags = {
    Name = "bookvault-private-subnet-2"
  }
}

resource "aws_db_subnet_group" "bookvault_db_subnet_group" {
  name = "bookvault-db-subnet-group"
  subnet_ids = [
    aws_subnet.bookvault_private_subnet.id,
    aws_subnet.bookvault_private_subnet_2.id
  ]

  tags = {
    Name = "bookvault-db-subnet-group"
  }
}

resource "aws_internet_gateway" "bookvault_igw" {
  vpc_id = aws_vpc.bookvault.id

  tags = {
    Name = "bookvault-igw"
  }
}



resource "aws_vpc_endpoint" "s3_endpoint" {
  vpc_id       = aws_vpc.bookvault.id
  service_name = "com.amazonaws.us-east-1.s3"
  route_table_ids = [aws_route_table.bookvault_private_rt.id]

  tags = {
    Name = "s3_endpoint"
  }
}

resource "aws_s3_bucket" "bookvault_bucket" {
  bucket = "bookvault-bucket-1234567890"

  tags = {
    Name = "bookvault-bucket"
  }
}

resource "aws_s3_bucket_ownership_controls" "bookvault_bucket_ownership_controls" {
  bucket = aws_s3_bucket.bookvault_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "bookvault_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.bookvault_bucket_ownership_controls]

  bucket = aws_s3_bucket.bookvault_bucket.id
  acl    = "private"
}


resource "aws_lb" "bookvault_alb" {
    name               = "bookvault-alb"
    internal           = false
    load_balancer_type = "application"
    security_groups    = [aws_security_group.alb_bv_sg.id]
    subnets            = [
        aws_subnet.bookvault_public_subnet.id,
        aws_subnet.bookvault_public_subnet_2.id
    ]

    tags = {
        Name = "bookvault-alb"
    }
}


resource "aws_lb_target_group" "bookvault_tg" {
  name     = "bookvault-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = aws_vpc.bookvault.id

  health_check {
    path                = "/health"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
  }
}

resource "aws_lb_target_group_attachment" "bookvault_tg_attachment" {
  target_group_arn = aws_lb_target_group.bookvault_tg.arn
  target_id        = aws_instance.bookvault_app_server.id
  port             = 3000
}

resource "aws_lb_listener" "bookvault_listener" {
  load_balancer_arn = aws_lb.bookvault_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.bookvault_tg.arn
  }
}


