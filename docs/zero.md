# Zero Package Manager - Documentação

Zero é o gerenciador de pacotes do Avalon Linux, desenvolvido em Python.

## Comandos principais

- `zero install <pacote>` → Instala um pacote
- `zero remove <pacote>` → Remove um pacote
- `zero list` → Lista pacotes instalados
- `zero update [pacote]` → Atualiza um pacote ou todos
- `zero search <termo>` → Busca pacotes em repositórios
- `zero info <pacote>` → Mostra informações de um pacote

## Estrutura de diretórios

- `/usr/local/lib/zero/` → Código fonte
- `/var/lib/zero/` → Banco de dados de pacotes
- `/etc/zero/` → Configurações e repositórios
- `/var/cache/zero/` → Pacotes baixados temporariamente

## Configuração de Repositórios

Arquivo: `/etc/zero/repos.json`

Exemplo:

```json
{
    "avalon-official": "http://localhost:8080/",
    "archlinux": "https://mirror.rackspace.com/archlinux/core/os/x86_64/"
}
````

> Nota: O Zero ainda está em desenvolvimento e não substitui pacotes críticos do sistema.
