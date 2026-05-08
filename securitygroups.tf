resource "aws_security_group" "alb_bv_sg" {
    name        = "alb_bv_sg"
    description = "Security group for ALB in BookVault"
    vpc_id      = aws_vpc.bookvault.id

    tags = {
        Name = "alb_bv_sg"
    }
}

resource "aws_security_group" "app_bv_sg" {
    name        = "app_bv_sg"
    description = "Security group for app server in BookVault"
    vpc_id      = aws_vpc.bookvault.id

    tags = {
        Name = "app_bv_sg"
    }
}

resource "aws_security_group" "sqldb_bv_sg" {
    name        = "sqldb_bv_sg"
    description = "Security group for RDS in BookVault"
    vpc_id      = aws_vpc.bookvault.id

    tags = {
        Name = "sqldb_bv_sg"
    }
}

resource "aws_security_group" "nosqldb_bv_sg" {
    name        = "nosqldb_bv_sg"
    description = "Security group for DocumentDB in BookVault"
    vpc_id      = aws_vpc.bookvault.id

    tags = {
        Name = "nosqldb_bv_sg"
    }
}

resource "aws_security_group" "bastion_bv_sg" {
    name        = "bastion_bv_sg"
    description = "Security group for bastion host in BookVault"
    vpc_id      = aws_vpc.bookvault.id

    tags = {
        Name = "bastion_bv_sg"
    }
}



resource "aws_security_group_rule" "alb_ingress_http" {
    type              = "ingress"
    description       = "Allow HTTP from internet"
    from_port         = 80
    to_port           = 80
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
    security_group_id = aws_security_group.alb_bv_sg.id
}

resource "aws_security_group_rule" "alb_ingress_https" {
    type              = "ingress"
    description       = "Allow HTTPS from internet"
    from_port         = 443
    to_port           = 443
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
    security_group_id = aws_security_group.alb_bv_sg.id
}

resource "aws_security_group_rule" "alb_egress_app" {
    type                     = "egress"
    description              = "Forward traffic to app server"
    from_port                = 3000
    to_port                  = 3000
    protocol                 = "tcp"
    source_security_group_id = aws_security_group.app_bv_sg.id
    security_group_id        = aws_security_group.alb_bv_sg.id
}



resource "aws_security_group_rule" "app_ingress_alb" {
    type                     = "ingress"
    description              = "Allow traffic from ALB"
    from_port                = 3000
    to_port                  = 3000
    protocol                 = "tcp"
    source_security_group_id = aws_security_group.alb_bv_sg.id
    security_group_id        = aws_security_group.app_bv_sg.id
}

resource "aws_security_group_rule" "app_ingress_bastion" {
    type                     = "ingress"
    description              = "Allow SSH from bastion"
    from_port                = 22
    to_port                  = 22
    protocol                 = "tcp"
    source_security_group_id = aws_security_group.bastion_bv_sg.id
    security_group_id        = aws_security_group.app_bv_sg.id
}

resource "aws_security_group_rule" "app_egress_rds" {
    type                     = "egress"
    description              = "Allow outbound to RDS"
    from_port                = 5432
    to_port                  = 5432
    protocol                 = "tcp"
    source_security_group_id = aws_security_group.sqldb_bv_sg.id
    security_group_id        = aws_security_group.app_bv_sg.id
}

resource "aws_security_group_rule" "app_egress_docdb" {
    type                     = "egress"
    description              = "Allow outbound to DocumentDB"
    from_port                = 27017
    to_port                  = 27017
    protocol                 = "tcp"
    source_security_group_id = aws_security_group.nosqldb_bv_sg.id
    security_group_id        = aws_security_group.app_bv_sg.id
}

resource "aws_security_group_rule" "app_egress_https" {
    type              = "egress"
    description       = "Allow outbound HTTPS via NAT"
    from_port         = 443
    to_port           = 443
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
    security_group_id = aws_security_group.app_bv_sg.id
}

resource "aws_security_group_rule" "app_egress_http" {
    type              = "egress"
    description       = "Allow outbound HTTP via NAT"
    from_port         = 80
    to_port           = 80
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
    security_group_id = aws_security_group.app_bv_sg.id
}


resource "aws_security_group_rule" "rds_ingress_app" {
    type                     = "ingress"
    description              = "Allow PostgreSQL from app server"
    from_port                = 5432
    to_port                  = 5432
    protocol                 = "tcp"
    source_security_group_id = aws_security_group.app_bv_sg.id
    security_group_id        = aws_security_group.sqldb_bv_sg.id
}



resource "aws_security_group_rule" "docdb_ingress_app" {
    type                     = "ingress"
    description              = "Allow MongoDB from app server"
    from_port                = 27017
    to_port                  = 27017
    protocol                 = "tcp"
    source_security_group_id = aws_security_group.app_bv_sg.id
    security_group_id        = aws_security_group.nosqldb_bv_sg.id
}




resource "aws_security_group_rule" "bastion_ingress_ssh" {
    type              = "ingress"
    description       = "Allow SSH from local machine"
    from_port         = 22
    to_port           = 22
    protocol          = "tcp"
    cidr_blocks       = ["102.90.96.188/32"]
    security_group_id = aws_security_group.bastion_bv_sg.id
}


resource "aws_security_group_rule" "bastion_egress_app" {
    type                     = "egress"
    description              = "Allow SSH to app server"
    from_port                = 22
    to_port                  = 22
    protocol                 = "tcp"
    source_security_group_id = aws_security_group.app_bv_sg.id
    security_group_id        = aws_security_group.bastion_bv_sg.id
}
