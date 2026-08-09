# 05 · Segurança

## Princípios aplicados

### 1. Menor privilégio (Least Privilege)
Cada componente tem exatamente as permissões que precisa, nem mais:

| Recurso | Role IAM | Permissões |
|---|---|---|
| Task ECS (execução) | `leadflow-ecs-execution-role` | Pull de imagem no ECR, escrever logs no CloudWatch, ler segredos específicos no Secrets Manager |
| Task ECS (aplicação) | `leadflow-ecs-task-role` | Apenas o necessário para a API funcionar (ex: se precisar enviar e-mail via SES, só essa permissão) |
| Pipeline CI/CD | `leadflow-cicd-role` | Push no ECR, update no ECS service — nada além disso |

### 2. Isolamento de rede (Defense in Depth)

```
Internet
   │
   ▼
[ALB] ── Subnet Pública ── Security Group: permite 443 de qualquer IP
   │
   ▼
[ECS Tasks] ── Subnet Privada ── Security Group: permite 3000 apenas do SG do ALB
   │
   ▼
[RDS] ── Subnet Privada ── Security Group: permite 5432 apenas do SG das tasks ECS
```

O banco de dados **nunca** tem um Security Group que aceite conexões da internet — mesmo que alguém descubra o endpoint do RDS, a conexão é recusada na camada de rede.

### 3. Segredos nunca em código

- Senha do banco: gerada automaticamente pelo Terraform e armazenada no Secrets Manager
- JWT Secret: gerado e armazenado no Secrets Manager
- As tasks ECS leem os segredos em runtime via variável de ambiente injetada pelo próprio ECS (`secrets` no task definition), nunca hardcoded

### 4. Criptografia

| Dado | Em trânsito | Em repouso |
|---|---|---|
| Tráfego usuário → CloudFront/ALB | TLS 1.2+ (certificado ACM) | — |
| Tráfego ALB → ECS | HTTP interno (dentro da VPC, rede isolada) | — |
| RDS PostgreSQL | SSL habilitado nas conexões | Criptografia em repouso via KMS |
| Secrets Manager | TLS | Criptografia via KMS |

### 5. Auditoria

- **CloudTrail** habilitado para registrar todas as chamadas de API feitas na conta (quem criou/alterou/deletou o quê)
- **VPC Flow Logs** opcionalmente habilitados para inspecionar tráfego de rede suspeito

## Checklist de segurança usado neste projeto

- [x] RDS sem IP público (`publicly_accessible = false`)
- [x] Security Groups restritivos (regra de entrada específica, não `0.0.0.0/0` em portas de banco)
- [x] Segredos no Secrets Manager, nunca em `.env` commitado
- [x] HTTPS obrigatório (redirect de HTTP → HTTPS no ALB)
- [x] IAM roles com permissões mínimas por recurso
- [x] Backups automáticos do RDS habilitados
- [x] `.gitignore` cobrindo `.env`, `terraform.tfvars`, `*.tfstate`

## O que ainda evoluiria em um cenário de produção real

- WAF (Web Application Firewall) na frente do CloudFront/ALB
- Rotação automática de credenciais do banco (Secrets Manager suporta nativamente)
- AWS GuardDuty para detecção de ameaças
- Autenticação MFA obrigatória para todos os usuários IAM humanos

➡️ Próximo: [06 - Custos](06-custos.md)
