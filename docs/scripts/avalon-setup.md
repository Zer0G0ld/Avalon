## 1️⃣ Cabeçalho e inicialização

```bash
#!/usr/bin/env bash
# ============================================
# AVALON OS SETUP SCRIPT
# Autor: Zer0
# Descrição: Cria, reinstala ou remove o Avalon OS baseado em Arch dentro de /opt/avalon
# ============================================
set -e
```

* Define Bash como interpretador.
* `set -e` faz o script **parar se qualquer comando falhar**.
* Comentários descrevem finalidade, autor e local de instalação.

---

## 2️⃣ Variáveis principais

```bash
TARGET="/opt/avalon"
HOSTNAME="avalon"
USER="avalon"
PKGS="base linux linux-firmware vim nano networkmanager sudo hyprland"
```

* `TARGET`: diretório onde o Avalon OS será instalado.
* `HOSTNAME`: nome do host dentro do chroot.
* `USER`: usuário padrão criado.
* `PKGS`: pacotes base do Arch Linux a serem instalados (inclui Hyprland).

---

## 3️⃣ Interface de usuário

```bash
clear
echo "=== Avalon OS Setup ==="
echo "1) Instalar/Reinstalar Avalon"
echo "2) Desinstalar Avalon"
read -p "Escolha uma opção [1-2]: " OP
```

* Limpa a tela.
* Mostra menu de opções.
* Recebe entrada do usuário (`1` para instalar/reinstalar, `2` para remover).

---

## 4️⃣ Condicional principal

```bash
case "$OP" in
  1)
```

* Se o usuário escolheu **instalar/reinstalar**.

---

### 4a️⃣ Limpeza de instalação anterior

```bash
if [ -d "$TARGET" ]; then
  sudo umount -Rlf "$TARGET" 2>/dev/null || true
  sudo rm -rf "$TARGET"
fi
```

* Verifica se `/opt/avalon` existe.
* Se existir:

  * Desmonta recursivamente (`umount -Rlf`).
  * Remove o diretório completamente (`rm -rf`).

---

### 4b️⃣ Criação do diretório

```bash
sudo mkdir -p "$TARGET"
```

* Cria `/opt/avalon` vazio para instalação.

---

### 4c️⃣ Instalação do Arch base

```bash
sudo pacstrap -c -M "$TARGET" $PKGS
```

* Usa `pacstrap` para instalar **Arch Linux básico** no diretório `/opt/avalon`.
* `-c`: limpa cache antes de instalar.
* `-M`: não usa chroot temporário, instala diretamente.

---

### 4d️⃣ Copia arquivos de configuração essenciais

```bash
sudo cp /etc/resolv.conf "$TARGET/etc/"
sudo cp /etc/pacman.conf "$TARGET/etc/"
sudo mkdir -p "$TARGET/etc/pacman.d"
sudo cp /etc/pacman.d/mirrorlist "$TARGET/etc/pacman.d/"
```

* Copia arquivos de rede e pacman para garantir que o sistema interno tenha internet e mirrors corretos.

---

### 4e️⃣ Montagem de pseudo-sistemas para chroot

```bash
for d in dev proc sys run; do
  sudo mount --bind /$d "$TARGET/$d"
done
sudo mount -t devpts devpts "$TARGET/dev/pts"
```

* Monta `dev`, `proc`, `sys`, `run` do host no chroot para que comandos do Arch funcionem corretamente.
* Monta `devpts` para terminais dentro do chroot.

---

### 4f️⃣ Configuração interna via chroot

```bash
sudo arch-chroot "$TARGET" /bin/bash << 'EOF'
```

* Entra no chroot de `/opt/avalon` para configurar o sistema recém-instalado.

#### Dentro do chroot:

1. **Hostname e usuário**

```bash
echo "avalon" > /etc/hostname
useradd -m -G wheel -s /bin/bash avalon
echo "avalon:avalon" | chpasswd
```

* Define hostname como `avalon`.
* Cria usuário `avalon` no grupo `wheel` com shell Bash.
* Define senha `avalon` para root e usuário.

2. **Permitir sudo para wheel**

```bash
echo "%wheel ALL=(ALL) ALL" > /etc/sudoers.d/wheel
```

* Usuários do grupo `wheel` podem usar sudo sem restrições.

3. **Arquivo de identificação do Avalon**

```bash
echo "Avalon Linux 1.0 (based on Arch)" > /etc/avalon-release
```

* Cria arquivo indicando que este sistema é Avalon OS.

4. **Instala o script de gerenciamento `zero`**

```bash
cat << 'EOL' > /usr/local/bin/zero
...
EOL
chmod +x /usr/local/bin/zero
```

* Cria `/usr/local/bin/zero` com funções:

  * `zero info`: mostra versão do Avalon.
  * `zero update`: atualiza pacotes via `pacman -Syu`.
* Dá permissão de execução.

5. **Habilitar rede**

```bash
systemctl enable NetworkManager
```

* Configura NetworkManager para iniciar automaticamente.

---

### 4g️⃣ Desmontagem de pseudo-sistemas

```bash
for d in dev/pts dev proc sys run; do
  sudo umount -lf "$TARGET/$d" 2>/dev/null || true
done
```

* Desmonta todos os pseudo-sistemas montados para chroot.

---

### 4h️⃣ Mensagem final de instalação

```bash
echo "[*] Avalon instalado com sucesso!"
echo "Para acessar:"
echo "sudo arch-chroot $TARGET"
echo "ou"
echo "sudo systemd-nspawn -D $TARGET"
```

* Informa que a instalação foi concluída.
* Mostra como entrar no Avalon OS via chroot ou container (`systemd-nspawn`).

---

## 5️⃣ Desinstalação do Avalon OS

```bash
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
```

* Se o usuário escolheu `2`:

  * Desmonta `/opt/avalon` se estiver montado.
  * Remove completamente o diretório.
  * Mensagem de sucesso ou de inexistência do sistema.

---

## 6️⃣ Opção inválida

```bash
*)
  echo "[!] Opção inválida."
  exit 1
;;
```

* Caso o usuário digite algo diferente de `1` ou `2`, o script termina com erro.

---

## ✅ Resumo Geral

Este script realiza **três funções principais**:

1. **Instalar ou reinstalar Avalon OS**:

   * Limpa instalação anterior.
   * Instala Arch Linux básico em `/opt/avalon`.
   * Configura hostname, usuário, sudo, rede.
   * Cria arquivo de identificação e gerenciador `zero`.
   * Permite entrar no sistema via chroot ou systemd-nspawn.

2. **Desinstalar Avalon OS**:

   * Remove `/opt/avalon` completamente, incluindo sistemas montados.

3. **Interface simples de escolha**:

   * Menu interativo com validação mínima da escolha.
