### 1️⃣ Cabeçalho e configurações iniciais

```bash
#!/bin/bash
set -euo pipefail
```

* `#!/bin/bash`: Define que o script será executado no Bash.
* `set -euo pipefail`:

  * `-e`: encerra o script se qualquer comando falhar.
  * `-u`: erro se tentar usar variável não definida.
  * `-o pipefail`: se qualquer comando em um pipe falhar, o pipe retorna erro.

```bash
DISCO="/dev/sda"
EFI_SIZE="512MiB"
ROOT_SIZE="20GiB"
SWAP_SIZE="2GiB"
HOSTNAME="avalon"
LOCALE="pt_BR.UTF-8"
USUARIO="avalon"
SENHA="archroot"
```

* Define variáveis de configuração:

  * Disco principal, tamanhos das partições EFI, root e swap.
  * Nome do host, idioma, usuário e senha.

---

### 2️⃣ Verificação de internet

```bash
ping -c 3 archlinux.org >/dev/null || { echo "❌ Sem conexão!"; exit 1; }
```

* Testa conexão com a internet.
* Sai do script se não houver acesso à internet.

---

### 3️⃣ Ajuste de teclado

```bash
loadkeys br-abnt2 || true
```

* Define layout de teclado brasileiro ABNT2.
* `|| true` garante que o script continue mesmo se o comando falhar.

---

### 4️⃣ Verificação de modo de boot

```bash
if [ -d /sys/firmware/efi ]; then
  MODO_BOOT="uefi"
else
  MODO_BOOT="bios"
fi
```

* Detecta se o sistema está iniciado em **UEFI** ou **BIOS**.

---

### 5️⃣ Particionamento do disco

```bash
parted --script "$DISCO" \
  mklabel gpt \
  mkpart ESP fat32 1MiB $EFI_SIZE \
  set 1 boot on \
  mkpart primary ext4 $EFI_SIZE -$SWAP_SIZE \
  mkpart primary linux-swap -$SWAP_SIZE 100%
```

* Cria uma **tabela GPT** no disco.
* Partições:

  1. **EFI** (`fat32`, 512MiB, boot)
  2. **Root** (`ext4`, tamanho definido)
  3. **Swap** (`linux-swap`, 2GiB, no final do disco)

---

### 6️⃣ Formatação das partições

```bash
mkfs.fat -F32 "${DISCO}1"
mkfs.ext4 "${DISCO}2"
mkswap "${DISCO}3"
```

* Formata:

  * Partição 1 como FAT32 (EFI)
  * Partição 2 como EXT4 (root)
  * Partição 3 como swap

---

### 7️⃣ Montagem das partições

```bash
mount "${DISCO}2" /mnt
mkdir -p /mnt/boot/efi
mount "${DISCO}1" /mnt/boot/efi
swapon "${DISCO}3"
```

* Monta a **root** em `/mnt`.
* Monta **EFI** em `/mnt/boot/efi`.
* Ativa **swap**.

---

### 8️⃣ Instalação do sistema base

```bash
pacstrap -K /mnt base base-devel linux linux-firmware vim nano sudo networkmanager grub efibootmgr dosfstools mtools os-prober
```

* Instala pacotes essenciais:

  * `base`, `base-devel`, kernel, firmware.
  * Editores (`vim`, `nano`), `sudo`, `NetworkManager`.
  * Bootloader (`grub`), ferramentas para EFI e discos (`dosfstools`, `mtools`).
  * `os-prober` para detectar outros sistemas.

---

### 9️⃣ Geração do fstab

```bash
genfstab -U /mnt >> /mnt/etc/fstab
```

* Gera `/etc/fstab` com UUIDs das partições para montagem automática.

---

### 🔟 Entrando no chroot

```bash
arch-chroot /mnt /bin/bash <<EOF
```

* Muda o root do sistema para `/mnt` para configurar o novo sistema instalado.

---

### 11️⃣ Configuração de timezone e locale

```bash
ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
hwclock --systohc
sed -i "s/^#${LOCALE}/${LOCALE}/" /etc/locale.gen
locale-gen
echo "LANG=${LOCALE}" > /etc/locale.conf
```

* Define fuso horário (`São Paulo`) e gera o arquivo de horário.
* Habilita locale `pt_BR.UTF-8`.

---

### 12️⃣ Configuração de rede e usuários

```bash
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
```

* Define hostname e arquivo hosts.
* Cria usuário `avalon` com grupo `wheel` (acesso sudo).
* Define senha para root e usuário.
* Habilita sudo para grupo `wheel`.

---

### 13️⃣ Instalação do GRUB

```bash
if [ "${MODO_BOOT}" == "uefi" ]; then
  grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB --recheck
else
  grub-install --target=i386-pc ${DISCO}
fi

sed -i 's/^#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/' /etc/default/grub || true
grub-mkconfig -o /boot/grub/grub.cfg
```

* Instala **GRUB** no modo correto (UEFI ou BIOS).
* Habilita detecção de outros sistemas (`os-prober`).
* Gera configuração do GRUB.

---

### 14️⃣ Ativação do NetworkManager

```bash
systemctl enable NetworkManager
```

* Habilita NetworkManager para iniciar automaticamente.

---

### 15️⃣ Finalizando instalação

```bash
umount -R /mnt
swapoff "${DISCO}3"
```

* Desmonta todas as partições.
* Desativa swap temporária.

```bash
echo "✅ Instalação do Avalon concluída com sucesso!"
echo "🔁 Remova a ISO do drive e reinicie com: reboot"
```

* Mensagem final de sucesso.

---

### ✅ Resumo geral do script

1. Verifica internet e teclado.
2. Detecta modo de boot (UEFI/BIOS).
3. Particiona e formata disco.
4. Monta partições e ativa swap.
5. Instala base do Arch Linux e pacotes essenciais.
6. Configura fstab, timezone, locale, hostname, usuários e sudo.
7. Instala e configura GRUB.
8. Habilita NetworkManager.
9. Desmonta partições e finaliza instalação.
