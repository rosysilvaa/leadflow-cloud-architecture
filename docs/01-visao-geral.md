# 01 · Visão Geral

## Contexto

O **LeadFlow** é um SaaS de automação comercial (SDR) construído com NestJS, PostgreSQL, Prisma e Next.js. Ele nasceu como um projeto local de desenvolvimento — o objetivo deste repositório é documentar **como transformar essa aplicação local em um serviço de produção na nuvem**, aplicando boas práticas de arquitetura.

Este projeto foi criado como material de estudo, mas segue o mesmo raciocínio que se aplicaria a um ambiente de produção real de uma startup em estágio inicial.

## Objetivos

- [x] Desenhar uma arquitetura de nuvem **segura** (banco de dados nunca exposto publicamente)
- [x] Escolher serviços **gerenciados** para reduzir esforço operacional (RDS em vez de PostgreSQL auto-gerenciado, ECS Fargate em vez de EC2 puro)
- [x] Manter o **custo previsível** para um projeto em estágio inicial (não usar Kubernetes/EKS, que teria overhead desnecessário aqui)
- [x] Automatizar o deploy com **CI/CD**
- [x] Documentar cada decisão para consolidar aprendizado

## Requisitos não funcionais considerados

| Requisito | Como foi endereçado |
|---|---|
| **Disponibilidade** | ALB com health checks + RDS Multi-AZ (opcional, custo x benefício documentado) |
| **Segurança** | VPC com subnets privadas, Security Groups restritivos, Secrets Manager |
| **Escalabilidade** | ECS Fargate com auto scaling baseado em CPU/memória |
| **Observabilidade** | CloudWatch Logs + Alarmes básicos |
| **Custo** | Serviços serverless/gerenciados, sem NAT Gateway duplicado, free tier onde possível |

## Por que não usar apenas PaaS (Vercel + Railway, por exemplo)?

Esse é um ponto importante do estudo: para o LeadFlow em produção real, uma stack PaaS (Vercel para o frontend + Railway/Render para o backend) seria **mais rápida de configurar e mais barata no início**. Este repositório opta deliberadamente pela AWS "pura" porque o objetivo é **aprender arquitetura de nuvem em profundidade** — entender VPC, subnets, IAM, ECS — conhecimento que não se adquire delegando tudo a um PaaS.

Em `docs/03-servicos-aws.md` cada serviço é comparado com sua alternativa mais simples.

## Escopo deste repositório

✅ Incluído:
- Diagramas de arquitetura
- Código Terraform funcional (infraestrutura como código)
- Dockerfiles para containerizar backend e frontend
- Pipeline de CI/CD com GitHub Actions
- Documentação de segurança e custos

❌ Fora de escopo:
- Código-fonte da aplicação LeadFlow em si (fica no repositório do produto)
- Configuração de domínio/DNS específico
- Testes de carga

## Próximo passo

➡️ [02 - Arquitetura](02-arquitetura.md)
