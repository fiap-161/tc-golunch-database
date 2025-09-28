# 🎲 Repositório de Infra do Banco de Dados AWS RDS PostgreSQL via Terraform CI/CD

## 🔄 Fluxo de Trabalho (CI/CD)

Para garantir que a infraestrutura seja criada/atualizada corretamente via **GitHub Actions**, siga os passos abaixo:

1. Atualizar Secrets da Organização
  Antes de rodar o pipeline, verifique se as **secrets da organização** estão configuradas em:
  [Configurações de Secrets](https://github.com/fiap-161/tc-golunch-infra/settings/secrets/actions)

  As secrets necessárias são:
  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`
  - `AWS_SESSION_TOKEN`

➡️ Essas credenciais são utilizadas pelo Terraform para autenticar na AWS.

  - `DATABASE_USER`
  - `DATABASE_PASSWORD`

➡️ Já estão configurados, mas podem ser alterados caso assim deseje.


2. Criar uma Branch a partir da `main`, dar push nas alterações
3. Abrir um Pull Request.


## Infra do Banco de Dados AWS - RDS - PostgreSQL
O projeto provisiona, via Terraform, uma instância do Amazon RDS PostgreSQL configurada para ser utilizada pela aplicação Go.

- Engine: PostgreSQL 16.3 (um dos bancos relacionais mais robustos e populares no mercado, open source e altamente confiável).
- Instância: db.t3.micro — a menor classe disponível, com 2 vCPUs virtuais e até 1 GB de memória.
- Armazenamento: 20 GB em SSD (General Purpose).
- Database inicial: criado com o nome `golunchDB`, já pronto para receber as tabelas da aplicação.
- Segurança: o usuário e senha do banco são parametrizados por variáveis do Terraform e injetados a partir de GitHub Secrets, evitando exposição de credenciais no código.
- URL: a URL do banco fica disponível via AWS Secrets com o nome `golunch/db-url`

### ⚙️ Pipeline CI/CD (GitHub Actions).

O repositório contém um pipeline configurado no **GitHub Actions** que executa as seguintes etapas:

1. **Validação** dos arquivos Terraform (`terraform fmt`, `terraform validate`, `terraform plan`).
2. **Provisionamento/Atualização** da infraestrutura na AWS (`terraform apply`).
3. **Criação de Backend** via script `create_backend.sh` -> backend utilizado para guardar o tf.state da infra.
4. **Deleção Secrets** via script `secret_deletion.sh` -> avitar problemas quando as secrets forem criadas novamente.
5. **Controle de versão**: qualquer mudança na infra passa pelo fluxo de *Pull Request* e é aplicada somente após revisão e aprovação.
