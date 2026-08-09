# 03 · Serviços AWS Utilizados

Para cada serviço: **o que faz**, **por que foi escolhido** e **qual a alternativa mais simples** (para efeito de comparação/estudo).

## Compute — Amazon ECS (Fargate)

**O que é:** orquestrador de containers. Fargate é o modo "serverless" do ECS — você não gerencia instâncias EC2, só define CPU/memória da task.

**Por que:** o backend NestJS já é containerizado (Dockerfile). Fargate elimina o trabalho de patch de SO, escalonamento manual de servidores.

**Alternativas consideradas:**
| Opção | Prós | Contras |
|---|---|---|
| **EC2 puro** | Mais controle, pode ser mais barato em escala grande | Precisa gerenciar patches, escalonamento manual |
| **EKS (Kubernetes)** | Padrão de mercado, portável | Overhead de complexidade desnecessário para 1 serviço |
| **Elastic Beanstalk** | Muito simples de configurar | Menos controle sobre a infraestrutura, "caixa preta" |
| **AWS Lambda** | Zero servidor, paga por execução | NestJS como API REST tradicional não se beneficia tanto do modelo de function-per-request; cold starts |

✅ **Fargate foi escolhido** por equilibrar simplicidade operacional com controle sobre a arquitetura de rede.

## Banco de dados — Amazon RDS (PostgreSQL)

**O que é:** banco de dados relacional totalmente gerenciado.

**Por que:** LeadFlow já usa PostgreSQL via Prisma. RDS cuida de backups, patches de segurança, failover (com Multi-AZ).

**Alternativas:**
- **PostgreSQL em EC2**: mais barato, mas você vira o DBA (backups, patches, HA manuais)
- **Aurora Serverless v2**: escala automaticamente para zero/picos, ótimo para tráfego imprevisível, porém mais caro em uso constante
- **Supabase/Neon (fora da AWS)**: mais rápido de configurar, mas sai da rede privada da VPC, exigindo mais cuidado com segurança de conexão

✅ **RDS PostgreSQL** padrão (não Aurora) por ser previsível em custo para uma fase inicial.

## Rede — Amazon VPC

**O que é:** rede virtual isolada onde todos os recursos vivem.

**Por que:** é o requisito mínimo para qualquer arquitetura séria na AWS — permite separar recursos públicos (ALB) de privados (banco, containers).

**Conceito chave estudado:** *subnets privadas não significam "sem internet"* — elas significam "sem IP público direto". A saída para internet (ex: chamar uma API externa a partir do backend) acontece via **NAT Gateway**.

## Load Balancing — Application Load Balancer (ALB)

**Por que:** faz roteamento por camada 7 (HTTP), health checks e é pré-requisito para o ECS Service fazer rolling deployments sem downtime.

**Alternativa:** Network Load Balancer (camada 4) — mais performático, mas sem os recursos de roteamento HTTP que o ALB oferece.

## CDN e Frontend — CloudFront + S3

**Por que:** Next.js exportado como estático se beneficia diretamente de um CDN. CloudFront tem +400 edge locations globalmente, reduzindo latência para usuários no Brasil e fora dele.

**Alternativa mais simples:** Vercel (é literalmente feito para Next.js, zero configuração). Ficou de fora aqui porque o objetivo do repositório é estudar a AWS de ponta a ponta — mas é a recomendação real para produção rápida.

## Segredos — AWS Secrets Manager

**Por que:** nunca commitar credenciais. O Secrets Manager também permite **rotação automática** de senhas do banco.

**Alternativa mais barata:** AWS Systems Manager Parameter Store (gratuito, mas sem rotação automática nativa) — boa opção para reduzir custo em projetos pequenos.

## Registro de imagens — Amazon ECR

**O que é:** registro privado de imagens Docker, equivalente ao Docker Hub, mas integrado nativamente ao ECS/IAM.

## Observabilidade — CloudWatch

Logs centralizados de cada task ECS + métricas de CPU/memória + alarmes configuráveis (ex: notificar se taxa de erro subir).

## IAM — Identity and Access Management

Cada recurso (task ECS, pipeline de CI/CD) tem uma **role** com permissões mínimas necessárias (princípio do menor privilégio) — detalhado em [05 - Segurança](05-seguranca.md).

---

## Tabela-resumo

| Camada | Serviço AWS | Alternativa simples |
|---|---|---|
| Compute | ECS Fargate | Elastic Beanstalk |
| Banco de dados | RDS PostgreSQL | PostgreSQL em EC2 |
| Frontend/CDN | S3 + CloudFront | Vercel |
| Rede | VPC (subnets pub/priv) | Default VPC (não recomendado) |
| Load Balancer | ALB | NLB |
| Segredos | Secrets Manager | Parameter Store |
| Imagens Docker | ECR | Docker Hub |
| Logs/Métricas | CloudWatch | — |

➡️ Próximo: [04 - Guia de Deploy](04-guia-deploy.md)
