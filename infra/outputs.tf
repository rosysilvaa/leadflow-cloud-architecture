output "alb_dns_name" {
  description = "DNS público do Application Load Balancer (API)"
  value       = aws_lb.main.dns_name
}

output "cloudfront_domain" {
  description = "Domínio do CloudFront (frontend)"
  value       = aws_cloudfront_distribution.frontend.domain_name
}

output "rds_endpoint" {
  description = "Endpoint do RDS (acessível apenas dentro da VPC)"
  value       = aws_db_instance.main.address
  sensitive   = true
}

output "ecr_repository_url" {
  description = "URL do repositório ECR para push da imagem Docker"
  value       = aws_ecr_repository.api.repository_url
}

output "ecs_cluster_name" {
  description = "Nome do cluster ECS"
  value       = aws_ecs_cluster.main.name
}

output "s3_frontend_bucket" {
  description = "Nome do bucket S3 do frontend"
  value       = aws_s3_bucket.frontend.bucket
}
