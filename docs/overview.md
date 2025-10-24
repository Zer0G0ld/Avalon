# Avalon Linux - Overview

Avalon Linux é um sistema baseado no Arch Linux, com foco em customização, leveza e produtividade, incluindo:

- Sistema base minimalista Arch Linux
- Gerenciador de janelas Hyprland
- Ferramenta própria de gerenciamento de pacotes: **Zero**
- Temas, ícones e personalizações de GRUB
- Scripts de instalação automatizados

## Objetivos do Projeto

1. Criar um ambiente Arch Linux totalmente configurado, pronto para uso.
2. Desenvolver um gerenciador de pacotes próprio (Zero) para facilitar a instalação e atualização de software.
3. Padronizar e documentar o sistema, garantindo fácil manutenção e backups.

## Estrutura Principal

- `/opt/avalon` → Instalação do sistema Avalon
- `/usr/local/lib/zero/` → Código fonte do Zero
- `/var/lib/zero/` → Banco de dados de pacotes instalados
- `/etc/zero/` → Configurações e repositórios do Zero
- `docs/` → Documentação do projeto
- `scripts/` → Scripts de setup e instalação
- `zips/` → Backups do sistema
