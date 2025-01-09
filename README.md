# PGD-Petrvs com Kubernetes

Implementação de uma pipeline de CI/CD utilizando GitLab CE e Kubernetes em uma stack on-premises, usando o [PGD Petrvs MGI](https://github.com/gestaogovbr/pgd-petrvs-publico/releases/tag/2.3.3) como aplicação de referência. O projeto inclui integrações com Harbor, SonarQube, MinIO e Vault.

---

## **1. Estrutura do Repositório**

```
pgd-petrvs/
├── README.md
├── .gitlab-ci.yml                   # Pipeline CI/CD
├── k8s/                             # Configurações Kubernetes
│   ├── production/
│   │   └── deployment-production.yaml
│   └── staging/
│       └── deployment-staging.yaml
├── scripts/                         # Scripts auxiliares
│   ├── configure-vault.sh           # Integração com Vault
│   ├── fetch-source-code.sh         # Clone do código fonte.
│   └── minio-upload.sh
└── src/                             # Código-fonte da aplicação
```

---

## **2. Configuração do Ambiente**

1. **Kubernetes**

   - Certifique-se de que o cluster Kubernetes está operacional e configurado corretamente no `kubeconfig.yaml`.
   - Adicione o `kubeconfig.yaml` como variável protegida no GitLab:
     ```bash
     kubectl config view --raw > kubeconfig.yaml
     ```
     No GitLab: **Settings > CI/CD > Variables > KUBECONFIG**.

2. **Harbor**

   - Configure as credenciais do Harbor no GitLab:
     - `HARBOR_USERNAME`: Nome de usuário do Harbor.
     - `HARBOR_PASSWORD`: Senha do Harbor.

3. **MinIO**

   - Configure as credenciais do MinIO no GitLab:
     - `MINIO_ACCESS_KEY`: Chave de acesso do MinIO.
     - `MINIO_SECRET_KEY`: Chave secreta do MinIO.

4. **Vault**

   - Configure o token do Vault:
     - `VAULT_ROOT_TOKEN`: Token de root para interação inicial com o Vault.

---

## **3. Fluxo CI/CD**

![Visão Geral do Fluxo CI/CD](https://docs.gitlab.com/ee/ci/img/get_started_cicd_v16_11.png)

### **Etapas do Pipeline**

1. **Build**:

   - Constrói as imagens Docker para staging e produção.
   - Envia as imagens para o registro do Harbor.

2. **Quality**:

   - Executa análise de qualidade do código com SonarQube.

3. **Secure**:

   - Realiza escaneamento de vulnerabilidades nas imagens Docker.

4. **Deploy**:

   - Aplica os manifests Kubernetes para staging e produção.

5. **Monitor**:

   - Integração com ferramentas de monitoramento como Prometheus ou Grafana.

---

## **4. Scripts Auxiliares**

### **4.1. fetch-source-code.sh**

Obter o código-fonte do repositório GitHub da aplicação conforme tag especificada.
Ele move o código-fonte para o diretório `src/` na estrutura do projeto.

```bash
#!/bin/bash

# Configurações
REPO_URL="https://github.com/gestaogovbr/pgd-petrvs-publico.git"
TAG="2.3.3"
DEST_DIR="pgd-petrvs/src"

# Clonar o repositório
echo "Clonando o repositório..."
git clone $REPO_URL temp_repo
cd temp_repo || exit

# Checkout da tag
echo "Obtendo o código-fonte da tag $TAG..."
git checkout tags/$TAG -b release-$TAG

# Mover o código-fonte
echo "Movendo o código-fonte para $DEST_DIR..."
mkdir -p ../$DEST_DIR
cp -r . ../$DEST_DIR

# Limpeza
cd ..
rm -rf temp_repo

echo "Código-fonte movido com sucesso para $DEST_DIR."
```

---

## **5. Pipeline CI/CD**

1. **Build para Staging**:
   ```yaml
   build-staging:
     stage: build
     image: docker:20.10
     services:
       - docker:20.10-dind
     script:
       - docker build -t "$IMAGE_NAME-staging:$CI_COMMIT_SHORT_SHA" -f src/resources/docker/dev/Dockerfile-php .
       - docker push "$IMAGE_NAME-staging:$CI_COMMIT_SHORT_SHA"
       - docker push "$IMAGE_NAME-staging:latest"
   ```

2. **Build para Produção**:
   ```yaml
   build-production:
     stage: build
     image: docker:20.10
     services:
       - docker:20.10-dind
     script:
       - docker build -t "$IMAGE_NAME-production:$CI_COMMIT_SHORT_SHA" -f src/resources/docker/producao/Dockerfile-php .
       - docker push "$IMAGE_NAME-production:$CI_COMMIT_SHORT_SHA"
       - docker push "$IMAGE_NAME-production:latest"
   ```

### **Uso no Kubernetes**

Os manifests Kubernetes utilizam as imagens criadas:
- Staging: `$IMAGE_NAME-staging:$CI_COMMIT_SHORT_SHA`
- Produção: `$IMAGE_NAME-production:$CI_COMMIT_SHORT_SHA`

Usar os arquivos `deployment-staging.yaml` e `deployment-production.yaml` configurados para as imagens.

---

## **6. Referências**
- [Documentação do GitLab CI/CD](https://docs.gitlab.com/ee/ci/)
- [Componentes do GitLab CI/CD](https://docs.gitlab.com/ee/ci/components/index.html)
- Consulte [documentação oficial relacionada](https://docs.gitlab.com/ee/user/clusters/agent/ci_cd_workflow.html) para referências adicionais.
- [Github PGD Petrvs e canais do MGI](https://github.com/gestaogovbr/pgd-petrvs-publico)