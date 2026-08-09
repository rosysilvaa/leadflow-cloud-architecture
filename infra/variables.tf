variable "project_name" {
  description = "Nome do projeto, usado como prefixo dos recursos"
  type        = string
  default     = "leadflow"
}

variable "aws_region" {
  description = "Região AWS onde os recursos serão criados"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Ambiente (production, staging, dev)"
  type        = string
  default     = "production"
}

variable "vpc_cidr" {
  description = "CIDR block da VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "AZs usadas para as subnets"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "db_username" {
  description = "Usuário administrador do RDS"
  type        = string
  default     = "leadflow_admin"
  sensitive   = true
}

variable "db_instance_class" {
  description = "Classe da instância RDS"
  type        = string
  default     = "db.t4g.micro"
}

variable "db_allocated_storage" {
  description = "Armazenamento do RDS em GB"
  type        = number
  default     = 20
}

variable "ecs_task_cpu" {
  description = "CPU da task ECS (unidades Fargate, 256 = 0.25 vCPU)"
  type        = number
  default     = 512
}

variable "ecs_task_memory" {
  description = "Memória da task ECS em MB"
  type        = number
  default     = 1024
}

variable "ecs_desired_count" {
  description = "Número de tasks rodando simultaneamente"
  type        = number
  default     = 2
}

variable "container_port" {
  description = "Porta exposta pelo container da API NestJS"
  type        = number
  default     = 3000
}
