#!/bin/bash

# Validação de dependências
if ! command -v mc &> /dev/null; then
  echo "Erro: cliente MinIO (mc) não encontrado. Instalando..."
  wget https://dl.min.io/client/mc/release/linux-amd64/mc -O /usr/local/bin/mc
  chmod +x /usr/local/bin/mc
fi

# Configuração
MINIO_URL=https://s3-api.domain.com
ACCESS_KEY=${MINIO_ACCESS_KEY:-""}
SECRET_KEY=${MINIO_SECRET_KEY:-""}

if [ -z "$ACCESS_KEY" ] || [ -z "$SECRET_KEY" ]; then
  echo "Erro: Credenciais do MinIO (ACCESS_KEY ou SECRET_KEY) não definidas." >&2
  exit 1
fi

# Configura o cliente MinIO
mc alias set minio $MINIO_URL $ACCESS_KEY $SECRET_KEY || {
  echo "Erro ao configurar o cliente MinIO." >&2
  exit 1
}

# Upload de artefatos
ARTIFACT_PATH="/path/to/artifacts.zip"
mc cp $ARTIFACT_PATH minio/bucket-name/ || {
  echo "Erro ao fazer upload dos artefatos para o MinIO." >&2
  exit 1
}

echo "Upload concluído com sucesso."