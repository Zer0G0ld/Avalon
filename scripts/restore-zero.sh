#!/bin/bash
# Restore/Install do Zero Package Manager
# Autor: Zer0

ARCHIVE="$1"

if [[ -z "$ARCHIVE" ]]; then
    echo "Uso: sudo ./restore-zero.sh zero-backup-full.tar.gz"
    exit 1
fi

if [[ $EUID -ne 0 ]]; then
    echo "Você precisa rodar como root."
    exit 1
fi

echo "🌀 Restaurando Zero a partir de $ARCHIVE..."

# Criar diretórios necessários
mkdir -p /usr/local/bin
mkdir -p /usr/local/lib
mkdir -p /etc
mkdir -p /var/lib/zero
mkdir -p /var/cache/zero

# Descompactar o backup completo
tar -xzvf "$ARCHIVE" -C /

echo "✅ Arquivos copiados."

# Garantir permissões
chmod +x /usr/local/bin/zero
chown -R root:root /usr/local/lib/zero /usr/local/bin/zero /etc/zero
chmod -R 755 /usr/local/lib/zero

# Criar diretórios de cache e DB para instâncias existentes
if [[ -d /var/lib/zero ]]; then
    for instance in /var/lib/zero/*; do
        base=$(basename "$instance")
        mkdir -p "/var/cache/zero/$base"
    done
fi

echo "✅ Diretórios de cache/DB criados."
echo "🌀 Zero Package Manager restaurado com sucesso!"
