# Avalon Linux - Arquitetura do Sistema

## Estrutura do Zero Package Manager

O Zero foi desenvolvido em Python, com módulos separados para cada funcionalidade:

- `core.py` → Funções base e utilitários
- `install.py` → Instalação de pacotes
- `remove.py` → Remoção de pacotes
- `update.py` → Atualização de pacotes
- `search.py` → Busca em repositórios
- `info.py` → Informações sobre pacotes
- `cli.py` → Interface de linha de comando

### Banco de Dados

Localização: `/var/lib/zero/installed.db`

```sql
CREATE TABLE packages (
    name TEXT PRIMARY KEY,
    version TEXT,
    repo TEXT,
    installed_at DATETIME
);
````

### Repositórios

Configuração: `/etc/zero/repos.json`

Exemplo:

```json
{
    "avalon-official": "http://localhost:8080/",
    "archlinux": "https://mirror.rackspace.com/archlinux/core/os/x86_64/"
}
```
