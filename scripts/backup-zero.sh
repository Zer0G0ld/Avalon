#!/bin/bash

# Configurações
DEST="$HOME/zero-backup"
FULL_DEST="$HOME/zero-backup-full"

echo "🌀 Backup do Zero - iniciando..."

# Backup light (para GitHub)
echo "📦 Criando backup leve (código + configs)..."
rm -rf "$DEST"
mkdir -p "$DEST/etc/zero"
cp /usr/local/bin/zero "$DEST/"
cp -r /usr/local/lib/zero "$DEST/"
cp -r /etc/zero/repos.json "$DEST/etc/zero/"

cd $HOME
tar -czvf zero-backup.tar.gz zero-backup/
echo "✅ Backup leve gerado: zero-backup.tar.gz"

# Backup full (código + configs + bancos + cache)
echo "📦 Criando backup completo (código + configs + bancos + cache)..."
rm -rf "$FULL_DEST"
mkdir -p "$FULL_DEST/usr/local/bin"
mkdir -p "$FULL_DEST/usr/local/lib"
mkdir -p "$FULL_DEST/etc"
mkdir -p "$FULL_DEST/var/lib/zero"
mkdir -p "$FULL_DEST/var/cache/zero"

# Copiar tudo
cp /usr/local/bin/zero "$FULL_DEST/usr/local/bin/"
cp -r /usr/local/lib/zero "$FULL_DEST/usr/local/lib/"
cp -r /etc/zero "$FULL_DEST/etc/"
cp -r /var/lib/zero/* "$FULL_DEST/var/lib/zero/"
cp -r /var/cache/zero/* "$FULL_DEST/var/cache/zero/"

tar -czvf zero-backup-full.tar.gz zero-backup-full/
echo "✅ Backup completo gerado: zero-backup-full.tar.gz"

echo "🌀 Backup concluído!"
