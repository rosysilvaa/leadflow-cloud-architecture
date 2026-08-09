# ☁️ LeadFlow Cloud Architecture

> Projeto de estudo: arquitetura de deploy do **LeadFlow** (SaaS de automação comercial/SDR) na **AWS**, documentando decisões de arquitetura, infraestrutura como código e pipeline de CI/CD.

[![AWS](https://img.shields.io/badge/AWS-Cloud-orange?logo=amazon-aws)](https://aws.amazon.com)
[![Terraform](https://img.shields.io/badge/IaC-Terraform-purple?logo=terraform)](https://www.terraform.io)
[![NestJS](https://img.shields.io/badge/Backend-NestJS-red?logo=nestjs)](https://nestjs.com)
[![Next.js](https://img.shields.io/badge/Frontend-Next.js-black?logo=next.js)](https://nextjs.org)
[![License](https://img.shields.io/badge/license-MIT-green)](./LICENSE)

---

## 🎯 Sobre este projeto

Este repositório documenta, passo a passo, como uma aplicação **full stack real** (o [LeadFlow](https://github.com/rosysilvaa), meu SaaS de automação comercial) pode ser levada da minha máquina local até uma infraestrutura de nuvem **escalável, segura e com custo controlado** na AWS.

O objetivo não é só "subir a aplicação" — é registrar o **raciocínio por trás de cada escolha de arquitetura**, para consolidar meu aprendizado em cloud e servir de referência/portfólio.

**Stack da aplicação:**
- Backend: NestJS + Prisma + PostgreSQL + JWT
- Frontend: Next.js + TypeScript
- Infraestrutura: AWS (ECS Fargate, RDS, S3, CloudFront, ALB, VPC)
- IaC: Terraform
- CI/CD: GitHub Actions

---

## 🗺️ Arquitetura (visão geral)

```mermaid
flowchart TB
    subgraph Internet
        User[👤 Usuário]
    end

    subgraph AWS["AWS Cloud - Região us-east-1"]
        subgraph Edge["Camada de Borda"]
            CF[CloudFront CDN]
            S3[S3 - Frontend Next.js estático/SSR]
        end

        subgraph VPC["VPC 10.0.0.0/16"]
            subgraph Public["Subnets Públicas"]
                ALB[Application Load Balancer]
                NAT[NAT Gateway]
            end

            subgraph Private["Subnets Privadas"]
                ECS[ECS Fargate<br/>API NestJS - LeadFlow]
                RDS[(RDS PostgreSQL<br/>Multi-AZ)]
            end
        end

        SM[Secrets Manager]
        CW[CloudWatch Logs/Alarmes]
        ECR[ECR - Registro de imagens Docker]
    end

    User -->|HTTPS| CF
    CF --> S3
    User -->|api.leadflow.com| ALB
    ALB --> ECS
    ECS --> RDS
    ECS -.credenciais.-> SM
    ECS -.logs/métricas.-> CW
    ECS -.pull image.-> ECR
    Private -.saída internet.-> NAT
```

📌 Diagrama completo e detalhado (com IAM, security groups e fluxo de CI/CD) em [`docs/02-arquitetura.md`](docs/02-arquitetura.md).

---

## 📚 Documentação

| Documento | Conteúdo |
|---|---|
| [01 - Visão Geral](docs/01-visao-geral.md) | Contexto do projeto, objetivos e requisitos |
| [02 - Arquitetura](docs/02-arquitetura.md) | Diagramas detalhados, componentes e fluxo de dados |
| [03 - Serviços AWS](docs/03-servicos-aws.md) | Cada serviço usado, por que foi escolhido e alternativas |
| [04 - Guia de Deploy](docs/04-guia-deploy.md) | Passo a passo prático para reproduzir o deploy |
| [05 - Segurança](docs/05-seguranca.md) | IAM, security groups, secrets, criptografia |
| [06 - Custos](docs/06-custos.md) | Estimativa de custo mensal por serviço |

---

## 🧱 Estrutura do repositório

```
leadflow-cloud-architecture/
├── docs/                      # Documentação detalhada (o coração do projeto)
├── infra/terraform/           # Infraestrutura como código (Terraform)
├── docker/                    # Dockerfiles do backend e frontend
├── .github/workflows/         # Pipeline de CI/CD (GitHub Actions)
├── .env.example
└── README.md
```

---

## 🚀 Como usar este projeto

Este repositório é **educacional** — ele mostra a arquitetura e o código de infraestrutura, mas não conecta a uma conta AWS automaticamente. Para reproduzir:

1. Leia [`docs/01-visao-geral.md`](docs/01-visao-geral.md) para entender o contexto
2. Configure suas credenciais AWS (`aws configure`)
3. Siga o [`docs/04-guia-deploy.md`](docs/04-guia-deploy.md) passo a passo
4. Ajuste variáveis em `infra/terraform/variables.tf` para seu ambiente

```bash
cd infra/terraform
terraform init
terraform plan
terraform apply
```

---

## 🧠 Principais aprendizados registrados

- Diferença entre **subnets públicas e privadas** e por que o banco de dados nunca deve ficar exposto à internet
- Como o **ECS Fargate** elimina a necessidade de gerenciar servidores (serverless containers)
- Uso do **Secrets Manager** para nunca versionar credenciais no código
- Como o **CloudFront + S3** reduz latência entregando o frontend via CDN
- Estruturação de um pipeline de **CI/CD** que builda, testa e faz deploy automaticamente

---

## 👩‍💻 Autora

**Roseane da Silva** — Desenvolvedora Full Stack, mentora e palestrante em IA
🔗 [@rose.mentoring](https://instagram.com/rose.mentoring) · [GitHub](https://github.com/rosysilvaa)

---

## 📄 Licença

Este projeto está sob a licença MIT — veja [LICENSE](LICENSE) para detalhes.
