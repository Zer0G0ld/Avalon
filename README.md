# Passo a passo atualizado para instalação base do Arch Linux (Avalon)

---

## 1. Preparação inicial

* Certifique-se de que a VM está com a ISO do Arch Linux montada no drive óptico.
* No VirtualBox, configure a VM para dar boot pelo disco virtual (HD) **após** a ISO.
* Inicie a VM, você verá o menu do Arch Linux (GRUB):

  * Escolha a opção padrão **Arch Linux install medium (x86\_64, BIOS)** para iniciar o ambiente live.

---

## 2. Verificar internet

No prompt `root@archiso ~ #`:

```bash
ping archlinux.org
```

Se responder, está OK. Ctrl+C para parar.

---

## 3. Ajustar teclado (se usar ABNT2):

```bash
loadkeys br-abnt2
```

---

## 4. Listar discos e partições

```bash
lsblk
```

Exemplo de saída:

```
NAME   MAJ:MIN RM SIZE RO TYPE MOUNTPOINTS
sda      8:0    0  40G  0 disk
```

---

## 5. Particionar o disco com cfdisk (modo visual)

```bash
cfdisk /dev/sda
```

* Escolha o esquema **GPT**.
* Crie duas partições:

  * **/dev/sda1** → 512 MB, tipo `EFI System`
  * **/dev/sda2** → resto do espaço, tipo `Linux filesystem`
* Salve e saia.

---

## 6. Formatar as partições

```bash
mkfs.fat -F32 /dev/sda1        # Partição EFI (FAT32)
mkfs.ext4 /dev/sda2            # Partição raiz (ext4)
```

---

## 7. Montar partições

```bash
mount /dev/sda2 /mnt
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot
```

---

## 8. Instalar o sistema base

```bash
pacstrap -K /mnt base linux linux-firmware vim nano networkmanager
```

> *Aqui pode demorar um pouco.*

---

## 9. Gerar o fstab

```bash
genfstab -U /mnt >> /mnt/etc/fstab
```

---

## 10. Entrar no sistema instalado (chroot)

```bash
arch-chroot /mnt
```

---

## 11. Configurações básicas

### a) Definir fuso horário

```bash
ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
hwclock --systohc
```

### b) Locales

Edite para ativar pt\_BR.UTF-8:

```bash
nano /etc/locale.gen
```

Descomente:

```
pt_BR.UTF-8 UTF-8
```

Salve e execute:

```bash
locale-gen
```

Crie arquivo `/etc/locale.conf`:

```bash
echo "LANG=pt_BR.UTF-8" > /etc/locale.conf
```

### c) Hostname

```bash
echo "avalon" > /etc/hostname
```

### d) Configurar hosts

```bash
cat > /etc/hosts << EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   avalon.localdomain avalon
EOF
```

### e) Definir senha do root

```bash
passwd
```

---

## 12. Ativar NetworkManager

```bash
systemctl enable NetworkManager
```

---

## 13. Instalar bootloader systemd-boot

```bash
bootctl install
```

Criar arquivo de entrada para boot:

```bash
cat > /boot/loader/entries/arch.conf << EOF
title   Avalon Linux
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options root=/dev/sda2 rw
EOF
```

Criar arquivo loader.conf

```bash
echo "default arch.conf" > /boot/loader/loader.conf
```

---

## 14. Finalizar

Sair do chroot e desmontar:

```bash
exit
umount -R /mnt
```

---

## 15. Remover a ISO da VM no VirtualBox

* Antes de reiniciar, no VirtualBox, remova a ISO do drive óptico da VM para evitar bootar a instalação novamente.

---

## 16. Reiniciar a VM

```bash
reboot
```

---

## 17. O que esperar

Se tudo foi feito corretamente:

* O Arch Linux irá iniciar direto no terminal, você verá o prompt de login.
* Login com `root` e a senha que definiu.
* A partir daqui, pode começar a instalar e configurar o Hyprland e a interface gráfica.

---

### Observação

Se o boot não acontecer e continuar entrando no instalador:

* Verifique se a ISO realmente foi removida do drive óptico.
* Verifique a ordem de boot da VM: disco rígido deve vir antes do drive óptico.

