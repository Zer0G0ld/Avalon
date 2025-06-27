#!/bin/bash
set -euo pipefail

DISCO="/dev/sda"
EFI_SIZE="512M"
HOSTNAME="avalon"
LOCALE="pt_BR.UTF-8"

echo "==> Verificando internet..."
ping -c 3 archlinux.org

echo "==> Ajustando teclado para ABNT2"
loadkeys br-abnt2 || echo "Falha ao ajustar teclado, continue..."

echo "==> Particionando disco $DISCO com cfdisk (automático)..."

# Aqui particiona usando parted para script (mais seguro que cfdisk interativo)
parted --script "$DISCO" \
  mklabel gpt \
  mkpart primary fat32 1MiB $EFI_SIZE \
  set 1 boot on \
  mkpart primary ext4 $EFI_SIZE 100%

echo "==> Formatando partições..."
mkfs.fat -F32 "${DISCO}1"
mkfs.ext4 "${DISCO}2"

echo "==> Montando partições..."
mount "${DISCO}2" /mnt
mkdir -p /mnt/boot
mount "${DISCO}1" /mnt/boot

echo "==> Instalando sistema base..."
pacstrap -K /mnt base linux linux-firmware vim nano networkmanager

echo "==> Gerando fstab..."
genfstab -U /mnt >> /mnt/etc/fstab

echo "==> Entrando no chroot para configurar o sistema..."
arch-chroot /mnt /bin/bash <<EOF

set -e

echo "==> Definindo timezone..."
ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
hwclock --systohc

echo "==> Configurando locale..."
sed -i 's/^#${LOCALE}/${LOCALE}/' /etc/locale.gen
locale-gen
echo "LANG=${LOCALE}" > /etc/locale.conf

echo "==> Configurando hostname..."
echo "${HOSTNAME}" > /etc/hostname

echo "==> Configurando hosts..."
cat > /etc/hosts << HOSTS
127.0.0.1   localhost
::1         localhost
127.0.1.1   ${HOSTNAME}.localdomain ${HOSTNAME}
HOSTS

echo "==> Definindo senha root (padrão: archroot)..."
echo -e "archroot\narchroot" | passwd

echo "==> Habilitando NetworkManager..."
systemctl enable NetworkManager

echo "==> Instalando systemd-boot..."
bootctl install

echo "==> Criando arquivo de boot..."
cat > /boot/loader/entries/arch.conf << ENTRY
title   Avalon Linux
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options root=${DISCO}2 rw
ENTRY

echo "default arch.conf" > /boot/loader/loader.conf

EOF

echo "==> Desmontando partições..."
umount -R /mnt

echo "==> Instalação concluída! Remova a ISO da VM e reinicie."
