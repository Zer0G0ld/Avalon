# Avalon OS Setup Script - Documentação

**Autor:** Zer0
**Descrição:** Script para instalar, reinstalar ou remover o Avalon OS (baseado em Arch Linux) dentro de `/opt/avalon`.

---

## Índice

1. [Introdução](#introdução)
2. [Variáveis principais](#variáveis-principais)
3. [Menu de opções](#menu-de-opções)
4. [Instalação / Reinstalação](#instalação--reinstalação)

   * [Limpeza de instalação anterior](#limpeza-de-instalação-anterior)
   * [Criação do diretório](#criação-do-diretório)
   * [Instalação do Arch base](#instalação-do-arch-base)
   * [Cópia de arquivos de configuração](#cópia-de-arquivos-de-configuração)
   * [Montagem de pseudo-sistemas](#montagem-de-pseudo-sistemas)
   * [Configuração interna via chroot](#configuração-interna-via-chroot)
   * [Desmontagem de pseudo-sistemas](#desmontagem-de-pseudo-sistemas)
   * [Mensagem final](#mensagem-final)
5. [Desinstalação](#desinstalação)
6. [Tratamento de opções inválidas](#tratamento-de-opções-inválidas)
7. [Resumo geral](#resumo-geral)

---

## Introdução

Este script tem como objetivo facilitar a instalação, reinstalação ou remoção do **Avalon OS**, uma distribuição baseada em Arch Linux, isolada dentro de `/opt/avalon`. Ele é útil para criar um ambiente Linux separado sem interferir no sistema principal.

O script realiza:

* Instalação do Arch Linux básico no diretório `/opt/avalon`.
* Configuração de hostname, usuário, sudo e rede.
* Criação de script de gerenciamento interno (`zero`).
* Permite remoção completa do Avalon OS.

---

## Variáveis principais

```bash
TARGET="/opt/avalon"
HOSTNAME="avalon"
USER="avalon"
PKGS="base linux linux-firmware vim nano networkmanager sudo hyprland"
```

* `TARGET`: diretório de instalação do Avalon OS.
* `HOSTNAME`: nome do host dentro do Avalon.
* `USER`: usuário padrão criado no sistema.
* `PKGS`: pacotes essenciais a serem instalados, incluindo Hyprland.

---

## Menu de opções

O script apresenta um menu interativo:

```bash
1) Instalar/Reinstalar Avalon
2) Desinstalar Avalon
```

O usuário escolhe entre instalar/reinstalar (`1`) ou remover (`2`) o Avalon OS.

---

## Instalação / Reinstalação

Se o usuário escolhe a opção `1`:

### Limpeza de instalação anterior

```bash
if [ -d "$TARGET" ]; then
  sudo umount -Rlf "$TARGET" 2>/dev/null || true
  sudo rm -rf "$TARGET"
fi
```

* Verifica se `/opt/avalon` existe.
* Desmonta qualquer sistema ativo dentro do diretório.
* Remove o diretório antigo para iniciar uma instalação limpa.

### Criação do diretório

```bash
sudo mkdir -p "$TARGET"
```

* Cria `/opt/avalon` vazio para instalar o sistema.

### Instalação do Arch base

```bash
sudo pacstrap -c -M "$TARGET" $PKGS
```

* Instala Arch Linux básico e pacotes essenciais no diretório `/opt/avalon`.
* `-c`: limpa cache antes da instalação.
* `-M`: instala diretamente sem criar chroot temporário.

### Cópia de arquivos de configuração

```bash
sudo cp /etc/resolv.conf "$TARGET/etc/"
sudo cp /etc/pacman.conf "$TARGET/etc/"
sudo mkdir -p "$TARGET/etc/pacman.d"
sudo cp /etc/pacman.d/mirrorlist "$TARGET/etc/pacman.d/"
```

* Copia arquivos de configuração essenciais de rede e pacman para que o sistema interno funcione corretamente.

### Montagem de pseudo-sistemas

```bash
for d in dev proc sys run; do
  sudo mount --bind /$d "$TARGET/$d"
done
sudo mount -t devpts devpts "$TARGET/dev/pts"
```

* Monta pseudo-sistemas essenciais do host (`/dev`, `/proc`, `/sys`, `/run`) dentro do chroot.
* Permite que comandos internos do Arch funcionem corretamente.

### Configuração interna via chroot

```bash
sudo arch-chroot "$TARGET" /bin/bash << 'EOF'
```

Dentro do chroot, o script faz:

1. **Hostname e usuário**

```bash
echo "avalon" > /etc/hostname
useradd -m -G wheel -s /bin/bash avalon
echo "avalon:avalon" | chpasswd
```

* Define hostname como `avalon`.
* Cria usuário `avalon` no grupo `wheel` com shell Bash.
* Define senha `avalon` para root e usuário.

2. **Permissão de sudo**

```bash
echo "%wheel ALL=(ALL) ALL" > /etc/sudoers.d/wheel
```

* Usuários do grupo `wheel` podem usar sudo sem restrições.

3. **Identificação do sistema Avalon**

```bash
echo "Avalon Linux 1.0 (based on Arch)" > /etc/avalon-release
```

* Arquivo indicando que este sistema é Avalon OS.

4. **Script de gerenciamento interno `zero`**

```bash
cat << 'EOL' > /usr/local/bin/zero
...
EOL
chmod +x /usr/local/bin/zero
```

* Cria script `/usr/local/bin/zero` com funções:

  * `zero info`: mostra versão do Avalon.
  * `zero update`: atualiza pacotes (`pacman -Syu`).

5. **Rede**

```bash
systemctl enable NetworkManager
```

* Ativa NetworkManager para inicialização automática.

### Desmontagem de pseudo-sistemas

```bash
for d in dev/pts dev proc sys run; do
  sudo umount -lf "$TARGET/$d" 2>/dev/null || true
done
```

* Desmonta pseudo-sistemas montados para garantir limpeza.

### Mensagem final

```bash
echo "[*] Avalon instalado com sucesso!"
echo "Para acessar:"
echo "sudo arch-chroot $TARGET"
echo "ou"
echo "sudo systemd-nspawn -D $TARGET"
```

* Indica que a instalação foi concluída.
* Mostra formas de acessar o sistema instalado.

---

## Desinstalação

Se o usuário escolhe a opção `2`:

```bash
if [ -d "$TARGET" ]; then
  sudo umount -Rlf "$TARGET" 2>/dev/null || true
  sudo rm -rf "$TARGET"
fi
```

* Desmonta Avalon OS se estiver montado.
* Remove `/opt/avalon` completamente.
* Mostra mensagem de sucesso ou de inexistência do sistema.

---

## Tratamento de opções inválidas

```bash
*)
  echo "[!] Opção inválida."
  exit 1
;;
```

* Caso o usuário digite algo diferente de `1` ou `2`, o script termina com erro.

---

## Resumo geral

O script realiza três funções principais:

1. **Instalação / Reinstalação do Avalon OS**:

   * Limpeza de instalações antigas.
   * Instala Arch Linux básico em `/opt/avalon`.
   * Configura hostname, usuário, sudo, rede e script de gerenciamento `zero`.

2. **Desinstalação do Avalon OS**:

   * Remove `/opt/avalon` completamente.

3. **Interface interativa simples**:

   * Menu de escolha com validação mínima.

---

💡 **Nota:**
O Avalon OS instalado neste script é isolado dentro de `/opt/avalon` e não altera o sistema principal, sendo acessível via `arch-chroot` ou `systemd-nspawn`.
