output "rds_endpoint" {
  value = aws_db_instance.library.address
}

output "ecr_repository" {
  value = aws_ecr_repository.library.repository_url
}

output "ecs_cluster" {
  value = aws_ecs_cluster.library.name
}