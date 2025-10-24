#!/bin/bash
# Setup ou correção da estrutura do Zero Package Manager
# Autor: Zer0

INSTANCE="default"

echo "🌀 Verificando/Configurando Zero Package Manager..."

# Função para criar arquivo vazio se não existir
touch_if_missing() {
    local file="$1"
    if [[ ! -f "$file" ]]; then
        echo "Criando arquivo $file"
        touch "$file"
    fi
}

# Criar diretórios principais
mkdir -p /usr/local/bin
mkdir -p /usr/local/lib/zero
mkdir -p /etc/zero
mkdir -p "/var/lib/zero/$INSTANCE"
mkdir -p "/var/cache/zero/$INSTANCE"

# Criar scripts essenciais se não existirem
touch_if_missing /usr/local/lib/zero/__init__.py
touch_if_missing /usr/local/lib/zero/core.py
touch_if_missing /usr/local/lib/zero/cli.py
touch_if_missing /usr/local/lib/zero/install.py
touch_if_missing /usr/local/lib/zero/remove.py
touch_if_missing /usr/local/lib/zero/update.py
touch_if_missing /usr/local/lib/zero/search.py
touch_if_missing /usr/local/lib/zero/info.py

# Criar arquivo repos.json se não existir
if [[ ! -f /etc/zero/repos.json ]]; then
    echo "Criando /etc/zero/repos.json com repositórios padrão..."
    cat > /etc/zero/repos.json << EOF
{
    "avalon-official": "http://localhost:8080/",
    "archlinux": "https://mirror.rackspace.com/archlinux/core/os/x86_64/"
}
EOF
fi

# Criar binário principal se não existir
if [[ ! -f /usr/local/bin/zero ]]; then
    echo "Criando /usr/local/bin/zero de exemplo..."
    cat > /usr/local/bin/zero << 'EOF'
#!/usr/bin/env python3
print("🌀 Zero Package Manager v0.2a (placeholder)")
EOF
    chmod +x /usr/local/bin/zero
fi

# Criar DB inicial se não existir
DB_FILE="/var/lib/zero/$INSTANCE/installed.db"
if [[ ! -f "$DB_FILE" ]]; then
    echo "Criando banco de dados inicial em $DB_FILE"
    python3 - <<PYTHON
import sqlite3
conn = sqlite3.connect("$DB_FILE")
c = conn.cursor()
c.execute("""
CREATE TABLE IF NOT EXISTS packages (
    name TEXT PRIMARY KEY,
    version TEXT,
    repo TEXT,
    installed_at TEXT
);
""")
conn.commit()
conn.close()
PYTHON
fi

echo "✅ Estrutura do Zero verificada e corrigida!"
