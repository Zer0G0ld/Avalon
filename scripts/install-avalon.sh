#!/bin/bash
set -euo pipefail

DISCO="/dev/sda"
EFI_SIZE="512MiB"
ROOT_SIZE="20GiB"
SWAP_SIZE="2GiB"
HOSTNAME="avalon"
LOCALE="pt_BR.UTF-8"
USUARIO="avalon"
SENHA="archroot"

echo "[1/13] 🌐 Verificando conexão com a internet..."
ping -c 3 archlinux.org >/dev/null || { echo "❌ Sem conexão!"; exit 1; }

echo "[2/13] ⌨️ Ajustando layout de teclado para ABNT2..."
loadkeys br-abnt2 || true

echo "[3/13] 🧠 Verificando se sistema é UEFI..."
if [ -d /sys/firmware/efi ]; then
  MODO_BOOT="uefi"
  echo "✅ Sistema iniciado em modo UEFI"
else
  MODO_BOOT="bios"
  echo "⚠️ Sistema iniciado em modo BIOS"
fi

echo "[4/13] 💽 Particionando o disco ${DISCO}..."
parted --script "$DISCO" \
  mklabel gpt \
  mkpart ESP fat32 1MiB $EFI_SIZE \
  set 1 boot on \
  mkpart primary ext4 $EFI_SIZE -$SWAP_SIZE \
  mkpart primary linux-swap -$SWAP_SIZE 100%

echo "[5/13] 🧼 Formatando partições..."
mkfs.fat -F32 "${DISCO}1"
mkfs.ext4 "${DISCO}2"
mkswap "${DISCO}3"

echo "[6/13] 📂 Montando partições..."
mount "${DISCO}2" /mnt
mkdir -p /mnt/boot/efi
mount "${DISCO}1" /mnt/boot/efi
swapon "${DISCO}3"

echo "[7/13] 📦 Instalando sistema base..."
pacstrap -K /mnt base base-devel linux linux-firmware vim nano sudo networkmanager grub efibootmgr dosfstools mtools os-prober

echo "[8/13] 📝 Gerando fstab..."
genfstab -U /mnt >> /mnt/etc/fstab

echo "[9/13] 🏠 Entrando no chroot..."
arch-chroot /mnt /bin/bash <<EOF
set -e

echo "[10/13] 🌎 Configurando timezone e localedef..."
ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
hwclock --systohc
sed -i "s/^#${LOCALE}/${LOCALE}/" /etc/locale.gen
locale-gen
echo "LANG=${LOCALE}" > /etc/locale.conf

echo "[11/13] 🖥️ Configurando rede e usuário..."
echo "${HOSTNAME}" > /etc/hostname
cat > /etc/hosts << HOSTS
127.0.0.1   localhost
::1         localhost
127.0.1.1   ${HOSTNAME}.localdomain ${HOSTNAME}
HOSTS

echo "root:${SENHA}" | chpasswd
useradd -mG wheel ${USUARIO}
echo "${USUARIO}:${SENHA}" | chpasswd
sed -i 's/^# %wheel/%wheel/' /etc/sudoers

echo "[12/13] ⚙️ Instalando bootloader (${MODO_BOOT})..."
if [ "${MODO_BOOT}" == "uefi" ]; then
  grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB --recheck
else
  grub-install --target=i386-pc ${DISCO}
fi

# Opcional: ativar detecção de outros sistemas
sed -i 's/^#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/' /etc/default/grub || true

grub-mkconfig -o /boot/grub/grub.cfg

echo "[13/13] 🚀 Habilitando serviços de rede..."
systemctl enable NetworkManager
EOF

echo "🧹 Desmontando partições e finalizando instalação..."
umount -R /mnt
swapoff "${DISCO}3"

echo "✅ Instalação do Avalon concluída com sucesso!"
echo "🔁 Remova a ISO do drive e reinicie com: reboot"
