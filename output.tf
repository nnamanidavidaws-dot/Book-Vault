output "lb_public_dns" {
  value = aws_lb.bookvault_alb.dns_name
}

output "bastion_host_public_ip" {
  value = aws_instance.bastion_host.public_ip
}

output "app_server_private_ip" {
    value = aws_instance.bookvault_app_server.private_ip
}

output "rds_endpoint" {
    value = aws_db_instance.bookvault_db.endpoint
}

output "docdb_endpoint" {
    value = aws_docdb_cluster.docdb.endpoint
}

output "ecr_repository_url" {
    value = aws_ecr_repository.bookvault_ecr.repository_url
}

output "alb_dns_name" {
    value = aws_lb.bookvault_alb.dns_name
}
