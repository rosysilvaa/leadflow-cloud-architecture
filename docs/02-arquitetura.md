# 02 · Arquitetura Detalhada

## Diagrama completo

```mermaid
flowchart TB
    User[👤 Usuário]

    subgraph AWS["AWS - us-east-1"]
        direction TB

        subgraph Edge["Camada de Borda"]
            Route53[Route 53 - DNS]
            CF[CloudFront CDN]
            ACM[ACM - Certificado SSL/TLS]
        end

        S3F[S3 Bucket<br/>Frontend Next.js]

        subgraph VPC["VPC 10.0.0.0/16"]
            IGW[Internet Gateway]

            subgraph AZ1["AZ us-east-1a"]
                PubSub1[Subnet Pública 10.0.1.0/24]
                PrivSub1[Subnet Privada 10.0.11.0/24]
            end

            subgraph AZ2["AZ us-east-1b"]
                PubSub2[Subnet Pública 10.0.2.0/24]
                PrivSub2[Subnet Privada 10.0.12.0/24]
            end

            ALB[Application Load Balancer]
            NAT1[NAT Gateway]

            subgraph ECSCluster["ECS Cluster - Fargate"]
                Task1[Task NestJS #1]
                Task2[Task NestJS #2]
            end

            RDS[(RDS PostgreSQL<br/>Subnet Privada)]
        end

        SM[Secrets Manager<br/>DB credentials, JWT secret]
        ECR[ECR<br/>Imagem Docker da API]
        CW[CloudWatch<br/>Logs + Alarmes]
        IAM[IAM Roles<br/>Task Execution Role]
    end

    User -->|1. DNS lookup| Route53
    Route53 --> CF
    User -->|HTTPS| CF
    CF -->|conteúdo estático/SSR| S3F
    CF -.certificado.-> ACM

    User -->|api.leadflow.com HTTPS| ALB
    IGW --> PubSub1 & PubSub2
    ALB --> PubSub1 & PubSub2
    ALB --> Task1 & Task2
    Task1 & Task2 --> PrivSub1 & PrivSub2
    Task1 & Task2 --> RDS
    Task1 & Task2 -.lê segredos.-> SM
    Task1 & Task2 -.logs.-> CW
    Task1 & Task2 -.assume.-> IAM
    ECSCluster -.pull image.-> ECR
    PrivSub1 & PrivSub2 -.saída p/ internet\ncatch de dependências.-> NAT1
    NAT1 --> IGW
```

## Componentes e responsabilidades

### 1. Frontend (S3 + CloudFront)
O Next.js é buildado como estático (`next export`) ou SSR leve e servido via **S3 + CloudFront**. O CloudFront funciona como CDN, cacheando conteúdo nas edge locations mais próximas do usuário e reduzindo latência.

### 2. Backend (ECS Fargate)
A API NestJS roda em containers gerenciados pelo **ECS Fargate** — não precisamos provisionar ou gerenciar servidores EC2. O Fargate cobra pelo consumo real de CPU/memória das tasks.

- Mínimo de 2 tasks (uma por Availability Zone) para alta disponibilidade
- Auto scaling configurado por uso de CPU (>70% → escala horizontalmente)

### 3. Load Balancer (ALB)
O **Application Load Balancer** distribui requisições entre as tasks do ECS, faz health checks (`/health`) e é o único ponto de entrada HTTPS para a API.

### 4. Banco de dados (RDS PostgreSQL)
Fica em **subnet privada**, sem IP público. Só aceita conexões vindas do Security Group das tasks ECS. Backups automáticos diários, snapshot antes de qualquer alteração estrutural.

### 5. Rede (VPC)
- **Subnets públicas**: ALB e NAT Gateway
- **Subnets privadas**: ECS Tasks e RDS — nunca acessíveis diretamente da internet
- **NAT Gateway**: permite que as tasks privadas façam requisições de saída (ex: chamar APIs externas) sem expor portas de entrada

### 6. Secrets Manager
Credenciais do banco, JWT secret e outras chaves sensíveis **nunca ficam no código ou em variáveis de ambiente do Dockerfile** — são injetadas em runtime pelo ECS a partir do Secrets Manager.

### 7. Observabilidade (CloudWatch)
Logs de aplicação, métricas de CPU/memória das tasks e alarmes (ex: taxa de erro 5xx > 5%) centralizados no CloudWatch.

## Fluxo de uma requisição

1. Usuário acessa `app.leadflow.com` → Route 53 resolve → CloudFront entrega o frontend (cache ou origin S3)
2. Frontend faz chamada `fetch()` para `api.leadflow.com`
3. Requisição chega ao ALB via HTTPS (certificado do ACM)
4. ALB roteia para uma task saudável do ECS
5. Task NestJS processa, consulta/grava no RDS PostgreSQL
6. Resposta retorna pelo mesmo caminho

## Fluxo de deploy (CI/CD)

```mermaid
sequenceDiagram
    participant Dev as Roseane (git push)
    participant GH as GitHub Actions
    participant ECR as Amazon ECR
    participant ECS as ECS Fargate

    Dev->>GH: push na branch main
    GH->>GH: roda testes + lint
    GH->>GH: build da imagem Docker
    GH->>ECR: docker push
    GH->>ECS: update-service --force-new-deployment
    ECS->>ECS: rolling deploy (zero downtime)
```

➡️ Próximo: [03 - Serviços AWS](03-servicos-aws.md)
