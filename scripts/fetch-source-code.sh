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
