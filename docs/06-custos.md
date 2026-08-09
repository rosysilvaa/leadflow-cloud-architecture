# 06 · Estimativa de Custos (mensal, us-east-1)

> Valores aproximados em USD, ago/2026, para tráfego baixo/moderado (fase inicial de um SaaS). Sempre confira a [calculadora oficial da AWS](https://calculator.aws) para valores atualizados.

| Serviço | Configuração | Custo estimado/mês |
|---|---|---|
| ECS Fargate | 2 tasks × 0.5 vCPU / 1GB RAM, 24/7 | ~US$ 30 |
| RDS PostgreSQL | db.t4g.micro, single-AZ, 20GB gp3 | ~US$ 15 |
| Application Load Balancer | 1 ALB, tráfego baixo | ~US$ 18 |
| NAT Gateway | 1 gateway (processamento + hora) | ~US$ 33 |
| S3 (frontend) | poucos GB armazenados | ~US$ 1 |
| CloudFront | até 1TB de transferência (free tier cobre boa parte) | ~US$ 0-5 |
| Secrets Manager | 2-3 segredos | ~US$ 1,20 |
| CloudWatch Logs | volume baixo de logs | ~US$ 2 |
| ECR | armazenamento de imagens | ~US$ 1 |
| **Total estimado** | | **≈ US$ 100-110/mês** |

## Onde está o maior custo — e como reduzir

O **NAT Gateway** (~US$ 33/mês) é, proporcionalmente, o item mais caro para o benefício que entrega numa fase inicial. Alternativas:

1. **NAT Instance** (EC2 pequena fazendo o papel de NAT) — mais barato, mas exige manutenção manual
2. **VPC Endpoints** para serviços AWS específicos (ECR, Secrets Manager, S3) — elimina parte do tráfego que passaria pelo NAT
3. Aceitar o custo do NAT Gateway gerenciado em troca de zero manutenção (opção escolhida neste projeto, por ser mais realista para produção)

## Comparativo: esta arquitetura vs. PaaS

| | AWS (este projeto) | Vercel + Railway |
|---|---|---|
| Custo inicial/mês | ~US$ 100-110 | ~US$ 20-40 |
| Esforço de configuração | Alto (VPC, IAM, Terraform) | Baixo (conectar repositório) |
| Controle sobre infraestrutura | Total | Limitado |
| Valor de aprendizado | Alto — expõe conceitos de cloud "de verdade" | Baixo — abstrai tudo |
| Escala para milhões de usuários | Sim, nativamente | Depende do plano/limites do provedor |

**Conclusão do estudo:** para o LeadFlow em fase de validação de mercado, um PaaS seria financeiramente mais eficiente. A arquitetura AWS documentada aqui se justifica pelo **valor de aprendizado** e por já deixar o caminho pronto para quando o produto precisar de mais controle e escala.

## Dicas para reduzir custo em ambiente de estudo

- Use `terraform destroy` sempre que não estiver testando ativamente
- RDS `db.t4g.micro` está no free tier durante os 12 primeiros meses de uma conta nova
- Configure um **AWS Budget** com alerta em US$ 20 para não ser surpreendida na fatura

---

⬅️ Voltar ao [README principal](../README.md)
