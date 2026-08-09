# 04 · Guia de Deploy — Passo a Passo

> Pré-requisitos: conta AWS, [AWS CLI](https://aws.amazon.com/cli/) configurado (`aws configure`), [Terraform](https://developer.hashicorp.com/terraform/install) instalado, Docker instalado.

## Passo 1 — Preparar variáveis do Terraform

Copie o arquivo de exemplo e ajuste com seus valores:

```bash
cd infra/terraform
cp terraform.tfvars.example terraform.tfvars
```

Edite `terraform.tfvars`:
```hcl
project_name    = "leadflow"
aws_region      = "us-east-1"
db_username     = "leadflow_admin"
db_password     = "" # será gerado e armazenado no Secrets Manager, deixe vazio
environment     = "production"
```

## Passo 2 — Provisionar a infraestrutura base

```bash
terraform init
terraform plan   # revise o que será criado antes de aplicar
terraform apply  # digite "yes" para confirmar
```

Isso cria: VPC, subnets, RDS, ECR, cluster ECS, ALB, Secrets Manager e as IAM roles.

⏱️ Leva entre 10-15 minutos (RDS é o recurso mais demorado).

## Passo 3 — Build e push da imagem Docker do backend

```bash
# Autentica o Docker no ECR
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin <ID_DA_CONTA>.dkr.ecr.us-east-1.amazonaws.com

# Build da imagem
docker build -f docker/Dockerfile.backend -t leadflow-api .

# Tag e push
docker tag leadflow-api:latest <ID_DA_CONTA>.dkr.ecr.us-east-1.amazonaws.com/leadflow-api:latest
docker push <ID_DA_CONTA>.dkr.ecr.us-east-1.amazonaws.com/leadflow-api:latest
```

## Passo 4 — Rodar as migrations do Prisma

As migrations rodam uma vez, conectando ao RDS através de um túnel temporário (bastion) ou de uma task ECS one-off:

```bash
aws ecs run-task \
  --cluster leadflow-cluster \
  --task-definition leadflow-migrate \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[<subnet-privada>],securityGroups=[<sg-ecs>]}"
```

## Passo 5 — Deploy do frontend (Next.js) no S3 + CloudFront

```bash
cd ../../frontend
npm run build && npm run export   # gera pasta /out

aws s3 sync out/ s3://leadflow-frontend-bucket --delete

aws cloudfront create-invalidation \
  --distribution-id <ID_DISTRIBUICAO> \
  --paths "/*"
```

## Passo 6 — Atualizar o serviço ECS (rolling deploy)

```bash
aws ecs update-service \
  --cluster leadflow-cluster \
  --service leadflow-api-service \
  --force-new-deployment
```

## Passo 7 — Validar

```bash
# Testa o health check da API
curl https://api.leadflow.com/health

# Verifica os logs em tempo real
aws logs tail /ecs/leadflow-api --follow
```

## Automatizando tudo (CI/CD)

Os passos 3, 4 e 6 são automatizados pelo workflow em [`.github/workflows/deploy.yml`](../.github/workflows/deploy.yml) — a cada `git push` na branch `main`, o pipeline builda, testa e faz o deploy sozinho.

## Destruindo o ambiente (evitar custos)

Como este é um projeto de estudo, **sempre destrua os recursos depois de testar**:

```bash
cd infra/terraform
terraform destroy
```

⚠️ Isso apaga o banco de dados também — tire snapshot antes se quiser preservar dados.

➡️ Próximo: [05 - Segurança](05-seguranca.md)
