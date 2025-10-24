# Documentação do Script `setup-zero.sh`

## Objetivo

O `setup-zero.sh` é um **script de bootstrap** para o **Zero Package Manager**, responsável por:

1. Criar toda a estrutura de diretórios necessária.
2. Garantir que os arquivos essenciais do Zero existam.
3. Criar o banco de dados inicial.
4. Criar o arquivo de repositórios padrão (`repos.json`).
5. Preparar o binário principal (`/usr/local/bin/zero`) como placeholder, garantindo que a CLI funcione.

O script pode ser executado no **Avalon** ou em qualquer instalação Arch Linux que vá usar o Zero.

---

## Estrutura que o script garante

```
/usr/local/bin/zero         # binário principal chamando a CLI
/usr/local/lib/zero/
├── __init__.py
├── core.py
├── install.py
├── remove.py
├── update.py
├── search.py
├── info.py
└── cli.py
/etc/zero/
└── repos.json             # repositórios
/var/lib/zero/<instancia>/installed.db
/var/cache/zero/<instancia>/
```

> `<instancia>` é por padrão `"default"` mas pode ser alterado para suportar múltiplas instâncias do Zero.

---

## Funcionalidades do script

### 1. Criação de diretórios

O script cria os seguintes diretórios, caso não existam:

* `/usr/local/bin` → local do binário `zero`.
* `/usr/local/lib/zero` → código Python do Zero.
* `/etc/zero` → arquivos de configuração.
* `/var/lib/zero/<instancia>` → banco de dados de pacotes instalados.
* `/var/cache/zero/<instancia>` → cache dos pacotes baixados.

---

### 2. Criação de arquivos essenciais

Para cada módulo Python essencial do Zero, o script verifica se existe e cria um arquivo vazio se não existir:

* `__init__.py`
* `core.py`
* `install.py`
* `remove.py`
* `update.py`
* `search.py`
* `info.py`
* `cli.py`

Isso garante que você já pode importar qualquer módulo sem erro.

---

### 3. Arquivo de repositórios

Se `/etc/zero/repos.json` não existir, o script cria com conteúdo padrão:

```json
{
    "avalon-official": "http://localhost:8080/",
    "archlinux": "https://mirror.rackspace.com/archlinux/core/os/x86_64/"
}
```

Esse arquivo define de onde o Zero vai baixar os pacotes.

---

### 4. Binário principal (`/usr/local/bin/zero`)

Se o binário não existir, o script cria um **placeholder simples**:

```python
#!/usr/bin/env python3
print("🌀 Zero Package Manager v0.2a (placeholder)")
```

* Permite que você rode `zero` sem erro.
* Deve ser substituído pelo seu código Python final da CLI.

---

### 5. Banco de dados inicial

O script cria `installed.db` na instância especificada:

* Tabela `packages` com colunas:

  * `name` → nome do pacote
  * `version` → versão instalada
  * `repo` → repositório de origem
  * `installed_at` → timestamp da instalação

Exemplo de criação em Python:

```python
c.execute("""
CREATE TABLE IF NOT EXISTS packages (
    name TEXT PRIMARY KEY,
    version TEXT,
    repo TEXT,
    installed_at TEXT
);
""")
```

---

## Como usar

1. Torne o script executável:

```bash
sudo chmod +x setup-zero.sh
```

2. Execute como root:

```bash
sudo ./setup-zero.sh
```

3. Saída esperada:

```
🌀 Verificando/Configurando Zero Package Manager...
Criando arquivo /usr/local/lib/zero/__init__.py
Criando arquivo /usr/local/lib/zero/core.py
...
✅ Estrutura do Zero verificada e corrigida!
```

---

## Observações

* Sempre rode como **root**, pois precisa criar arquivos em `/usr/local`, `/etc` e `/var`.
* O script não sobrescreve arquivos existentes; apenas cria os que faltam.
* Você pode alterar a variável `INSTANCE` dentro do script para criar múltiplas instâncias do Zero.
* Depois de rodar, você já pode começar a implementar a lógica dos módulos Python (`install.py`, `remove.py`, etc.).
