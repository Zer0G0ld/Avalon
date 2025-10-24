#!/usr/bin/env bash
# ============================================
# AVALON OS SETUP SCRIPT
# Autor: Zer0
# Descrição: Cria, reinstala ou remove o Avalon OS baseado em Arch dentro de /opt/avalon
# ============================================

set -e

TARGET="/opt/avalon"
HOSTNAME="avalon"
USER="avalon"
PKGS="base linux linux-firmware vim nano networkmanager sudo hyprland"
clear
echo "=== Avalon OS Setup ==="
echo "1) Instalar/Reinstalar Avalon"
echo "2) Desinstalar Avalon"
read -p "Escolha uma opção [1-2]: " OP

case "$OP" in
  1)
    echo "[*] Instalando/Reinstalando Avalon..."

    # --- LIMPAR Avalon antigo ---
    if [ -d "$TARGET" ]; then
      echo "[*] Diretório $TARGET já existe. Limpando..."
      sudo umount -Rlf "$TARGET" 2>/dev/null || true
      sudo rm -rf "$TARGET"
    fi

    # --- CRIAR diretório ---
    sudo mkdir -p "$TARGET"

    # --- PACSTRAP ---
    echo "[*] Instalando Arch Linux básico no Avalon..."
    sudo pacstrap -c -M "$TARGET" $PKGS

    # --- Copiar configs essenciais ---
    sudo cp /etc/resolv.conf "$TARGET/etc/"
    sudo cp /etc/pacman.conf "$TARGET/etc/"
    sudo mkdir -p "$TARGET/etc/pacman.d"
    sudo cp /etc/pacman.d/mirrorlist "$TARGET/etc/pacman.d/"

    # --- Montagem de sistemas essenciais ---
    for d in dev proc sys run; do
      sudo mount --bind /$d "$TARGET/$d"
    done
    sudo mount -t devpts devpts "$TARGET/dev/pts"

    # --- Configuração interna ---
    sudo arch-chroot "$TARGET" /bin/bash << 'EOF'
set -e
echo "[*] Configurando Avalon interno..."

# Hostname e usuário
echo "avalon" > /etc/hostname
useradd -m -G wheel -s /bin/bash avalon
echo "avalon:avalon" | chpasswd

# Permitir sudo
echo "%wheel ALL=(ALL) ALL" > /etc/sudoers.d/wheel

# Sistema de identificação Avalon
echo "Avalon Linux 1.0 (based on Arch)" > /etc/avalon-release

# Script de gerenciamento 'zero'
cat << 'EOL' > /usr/local/bin/zero
#!/usr/bin/env bash
case "$1" in
  info)
    cat /etc/avalon-release
    ;;
  update)
    echo "Atualizando Avalon..."
    pacman -Syu --noconfirm
    ;;
  *)
    echo "Zero - Gerenciador do Avalon"
    echo "Uso: zero [info|update]"
    ;;
esac
EOL
chmod +x /usr/local/bin/zero

# Habilitar rede
systemctl enable NetworkManager

echo "[*] Configuração interna concluída."
EOF

    # --- Desmontar ---
    for d in dev/pts dev proc sys run; do
      sudo umount -lf "$TARGET/$d" 2>/dev/null || true
    done

    echo "[*] Avalon instalado com sucesso!"
    echo "Para acessar:"
    echo "sudo arch-chroot $TARGET"
    echo "ou"
    echo "sudo systemd-nspawn -D $TARGET"
    ;;
    
  2)
    echo "[*] Desinstalando Avalon..."
    if [ -d "$TARGET" ]; then
      sudo umount -Rlf "$TARGET" 2>/dev/null || true
      sudo rm -rf "$TARGET"
      echo "[*] Avalon desinstalado com sucesso."
    else
      echo "[*] Nenhum Avalon encontrado para remover."
    fi
    ;;
    
  *)
    echo "[!] Opção inválida."
    exit 1
    ;;
esac