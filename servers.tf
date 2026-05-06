data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}



resource "aws_instance" "bookvault_app_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.bookvault_private_subnet.id
  vpc_security_group_ids = [aws_security_group.app_bv_sg.id]
  key_name               = "bookvault"
  iam_instance_profile = aws_iam_instance_profile.app_server_profile.name
  


  tags = {
    Name = "BookVaultAppServer"
  }
}

resource "aws_instance" "bastion_host" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.bookvault_public_subnet.id
  vpc_security_group_ids = [aws_security_group.bastion_bv_sg.id]
  key_name               = "bookvault"
  associate_public_ip_address = true

  tags = {
    Name = "BVBastionHost"
  }
}


resource "aws_iam_role" "app_server_role" {
    name = "bookvault-app-server-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action    = "sts:AssumeRole"
                Effect    = "Allow"
                Principal = {
                    Service = "ec2.amazonaws.com"
                }
            }
        ]
    })
}


resource "aws_iam_role_policy" "app_server_s3_policy" {
    name = "bookvault-s3-policy"
    role = aws_iam_role.app_server_role.id

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect   = "Allow"
                Action   = ["s3:PutObject", "s3:GetObject", "s3:DeleteObject", "s3:ListBucket"]
                Resource = [
                    "arn:aws:s3:::bookvault-bucket-1234567890",
                    "arn:aws:s3:::bookvault-bucket-1234567890/*"
                ]
            }
        ]
    })
}

resource "aws_iam_instance_profile" "app_server_profile" {
    name = "bookvault-app-server-profile"
    role = aws_iam_role.app_server_role.name
}


resource "aws_ecr_repository" "bookvault_ecr" {
    name                 = "bookvault"
    image_tag_mutability = "MUTABLE"

    image_scanning_configuration {
        scan_on_push = true
    }

    tags = {
        Name = "bookvault-ecr"
    }
}