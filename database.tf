resource "aws_db_instance" "bookvault_db" {
  identifier             = "bookvault-db"
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "16.4"
  instance_class         = "db.t3.micro"
  db_name                   = "bookvaultdb"
  username               = var.db_username
  password               = var.db_password
  vpc_security_group_ids = [aws_security_group.sqldb_bv_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.bookvault_db_subnet_group.name
  skip_final_snapshot    = true
  publicly_accessible    = false

  tags = {
    Name = "postgres-bv-db"
  }
}


resource "aws_docdb_cluster" "docdb" {
  cluster_identifier      = "nosql-docdb-cluster"
  engine                  = "docdb"
  master_username         = var.db_nosql_username
  master_password         = var.db_nosql_password
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
  db_subnet_group_name    = aws_db_subnet_group.bookvault_db_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.nosqldb_bv_sg.id]
  skip_final_snapshot     = true
}


resource "aws_docdb_cluster_instance" "docdb_instance" {
  count               = 1
  identifier          = "nosql-docdb-instance-${count.index + 1}"
  cluster_identifier  = aws_docdb_cluster.docdb.id
  instance_class      = "db.t3.medium"
  engine              = "docdb"
}