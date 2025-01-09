#!/bin/bash

# Validação de dependências
if ! command -v curl &> /dev/null; then
  echo "Erro: curl não encontrado. Instale-o para continuar." >&2
  exit 1
fi

# Configuração
VAULT_ADDR=https://dti-vault.domain.com
VAULT_TOKEN=${VAULT_ROOT_TOKEN:-""}

if [ -z "$VAULT_TOKEN" ]; then
  echo "Erro: Token do Vault (VAULT_ROOT_TOKEN) não definido." >&2
  exit 1
fi

# Criar e configurar segredos para MinIO
curl -X POST -H "X-Vault-Token: $VAULT_TOKEN" \
    -d '{"data": {"access-key": "<MINIO_ACCESS_KEY>", "secret-key": "<MINIO_SECRET_KEY>"}}' \
    $VAULT_ADDR/v1/secret/data/minio-credentials || {
      echo "Erro ao configurar segredos no Vault." >&2
      exit 1
    }

echo "Segredos configurados no Vault com sucesso."