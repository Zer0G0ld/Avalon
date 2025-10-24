# Avalon Linux - Guia de Instalação e Estrutura

---

## Documentação Detalhada

> Acesse para mais detalhes sobre a instalação, arquitetura e desenvolvimento.

| Documento                               | Descrição                                                              |
| --------------------------------------- | ---------------------------------------------------------------------- |
| [overview.md](docs/overview.md)         | Visão geral do Avalon Linux e objetivos do projeto                     |
| [architecture.md](docs/architecture.md) | Estrutura interna do sistema, módulos e organização do Zero            |
| [setup.md](docs/setup.md)               | Guia de configuração inicial do ambiente para desenvolvimento e testes |
| [todo.md](docs/todo.md)                 | Lista de tarefas e melhorias planejadas                                |
| [zero.md](docs/zero.md)                 | Documentação específica do Zero Package Manager, comandos e uso        |

---
## Índice

1. [Preparação inicial](#1-preparação-inicial)
2. [Verificar internet](#2-verificar-internet)
3. [Ajustar teclado](#3-ajustar-teclado)
4. [Listar discos e partições](#4-listar-discos-e-partições)
5. [Particionar disco](#5-particionar-disco-com-cfdisk)
6. [Formatar partições](#6-formatar-as-partições)
7. [Montar partições](#7-montar-partições)
8. [Instalar sistema base](#8-instalar-o-sistema-base)
9. [Gerar fstab](#9-gerar-o-fstab)
10. [Entrar no chroot](#10-entrar-no-sistema-instalado-chroot)
11. [Configurações básicas](#11-configurações-básicas)
12. [Ativar NetworkManager](#12-ativar-networkmanager)
13. [Instalar bootloader systemd-boot](#13-instalar-bootloader-systemd-boot)
14. [Finalizar instalação](#14-finalizar)
15. [Remover ISO da VM](#15-remover-a-iso-da-vm)
16. [Reiniciar VM](#16-reiniciar-a-vm)
17. [O que esperar](#17-o-que-esperar)
18. [Estrutura do Avalon Linux](#18-estrutura-do-avalon-linux)
19. [Estrutura do Zero Package Manager](#19-estrutura-do-zero-package-manager)
20. [Scripts CLI do Zero](#20-scripts-cli-do-zero)
21. [Backup do Zero](#21-backup-do-zero)
22. [Observações importantes](#22-observações-importantes)

---

## 1. Preparação inicial

* Certifique-se de que a VM está com a ISO do Arch Linux montada no drive óptico.
* No VirtualBox, configure a VM para dar boot pelo disco virtual (HD) **após** a ISO.
* Inicie a VM, verá o menu do Arch Linux (GRUB):

  * Escolha a opção padrão **Arch Linux install medium (x86_64, BIOS)** para iniciar o ambiente live.

---

## 2. Verificar internet

```bash
ping archlinux.org
```

Ctrl+C para parar. Se responder, está OK.

---

## 3. Ajustar teclado (ABNT2):

```bash
loadkeys br-abnt2
```

---

## 4. Listar discos e partições

```bash
lsblk
```

---

## 5. Particionar disco com cfdisk

```bash
cfdisk /dev/sda
```

* GPT
* Partições:

  * /dev/sda1 → 512 MB, EFI System
  * /dev/sda2 → resto, Linux filesystem

---

## 6. Formatar as partições

```bash
mkfs.fat -F32 /dev/sda1
mkfs.ext4 /dev/sda2
```

---

## 7. Montar partições

```bash
mount /dev/sda2 /mnt
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot
```

---

## 8. Instalar sistema base

```bash
pacstrap -K /mnt base linux linux-firmware vim nano networkmanager
```

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

### a) Fuso horário

```bash
ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
hwclock --systohc
```

### b) Locales

```bash
nano /etc/locale.gen
```

Descomente:

```bash
pt_BR.UTF-8 UTF-8
```

```bash
locale-gen
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

Criar arquivo de entrada:

```bash
cat > /boot/loader/entries/arch.conf << EOF
title   Avalon Linux
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options root=/dev/sda2 rw
EOF
```

Loader config:

```bash
echo "default arch.conf" > /boot/loader/loader.conf
```

---

## 14. Finalizar

```bash
exit
umount -R /mnt
```

---

## 15. Remover ISO da VM

Remova a ISO do drive óptico antes de reiniciar.

---

## 16. Reiniciar VM

```bash
reboot
```

---

## 17. O que esperar

* Arch Linux inicia direto no terminal.
* Login: `root` e senha definida.

---

## 18. Estrutura do Avalon Linux

```
Avalon/
├── docs/
├── scripts/
├── src/
├── grub-test/
├── zips/
├── LICENSE
└── README.md
```

---

## 19. Estrutura do Zero Package Manager

```bash
/usr/local/lib/zero/
├── __init__.py
├── core.py
├── install.py
├── remove.py
├── update.py
├── search.py
├── info.py
└── cli.py
```

Banco de dados e cache:

```bash
/var/lib/zero/
└── installed.db

/var/cache/zero/
```

Configuração de repositórios:

```bash
/etc/zero/repos.json
```

---

## 20. Scripts CLI do Zero

```bash
/usr/local/bin/zero
```

| Comando          | Descrição                           |
| ---------------- | ----------------------------------- |
| install <pacote> | Instala um pacote                   |
| remove <pacote>  | Remove registro do pacote           |
| list             | Lista pacotes instalados            |
| update [pacote]  | Atualiza todos ou pacote específico |
| search <termo>   | Busca pacotes nos repositórios      |
| info <pacote>    | Mostra informações de um pacote     |

---

## 21. Backup do Zero

```bash
mkdir ~/avalon-zero-backup
cp -r /usr/local/lib/zero ~/avalon-zero-backup/zero-src
cp /usr/local/bin/zero ~/avalon-zero-backup/
cp -r /var/lib/zero ~/avalon-zero-backup/zero-db
cp -r /var/cache/zero ~/avalon-zero-backup/zero-cache
cp /etc/zero/repos.json ~/avalon-zero-backup/
cd ~
tar -czvf avalon-zero-backup.tar.gz avalon-zero-backup/
```

---

## 22. Observações importantes

* Zero é modular, fácil de evoluir e manter.
* Backup inclui **código, DB, cache e configuração de repositórios**.
* Estrutura do Avalon Linux separa claramente **documentação, scripts, recursos visuais e backup**.
