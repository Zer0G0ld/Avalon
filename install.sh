#!/usr/bin/env bash
set -e

# Destino da instalação
DEST="/opt/avalon"

# URL base do GitHub (substitua 'usuario' e 'avalon')
BASE_URL="https://github.com/Zer0G0ld/Avalon/archive/refs/tags/v1.0.0.tar.gz"
PACKAGE="avalon.tar.gz"

echo "Criando diretório de instalação: $DEST"
sudo mkdir -p "$DEST"

echo "Baixando Avalon Genesis..."
curl -L "$BASE_URL/$PACKAGE" -o "/tmp/$PACKAGE"

echo "Extraindo pacote..."
sudo tar -xzf "/tmp/$PACKAGE" -C "$DEST" --strip-components=1

echo "Limpeza..."
rm "/tmp/$PACKAGE"

echo "Avalon Genesis instalado em $DEST ✅"
