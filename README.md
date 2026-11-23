# .github

Repositório de padrões e convenções da IngaCode. Hoje ele guarda a convenção de commits ([Conventional Commits 1.0.0](https://www.conventionalcommits.org/en/v1.0.0/#specification)), usada por todos os repositórios da organização `inga-c`.

| Arquivo | Para quê |
|---|---|
| `.github/workflows/commitlint.yml` | Workflow reutilizável que valida os commits e o título do PR |
| `commitlint/commitlint.config.js` | Configuração base do commitlint (`@commitlint/config-conventional`), usada pelo workflow |
| `hooks/commit-msg` | Hook local em shell, sem Node, que recusa a mensagem fora do padrão |
| `commit.template` | Template de mensagem para o editor do git |
| `CONTRIBUTING.md` | Texto padrão de contribuição; vale para os repositórios sem um próprio |

As versões saem por tag (`v1`, `v1.1.0`...). Os repositórios usam sempre a tag maior (`@v1`), que é movida a cada versão compatível.

## Como adotar num repositório

### 1. CI

Crie `.github/workflows/conventional-commits.yml`:

```yaml
name: Conventional Commits

on:
  pull_request:
    types: [opened, edited, synchronize, reopened]

jobs:
  conventional-commits:
    uses: inga-c/.github/.github/workflows/commitlint.yml@v1
```

O nome do job (`conventional-commits`) precisa ser esse, para os checks se chamarem `conventional-commits / commitlint` e `conventional-commits / pr-title` em todos os repositórios. São esses dois que a proteção da `main` exige. O repositório não precisa de Node nem de configuração do commitlint.

### 2. Hook local

Repositório com husky (Node):

```bash
curl -fsSL https://raw.githubusercontent.com/inga-c/.github/v1/hooks/commit-msg -o .husky/commit-msg
```

Repositório sem Node (Flutter, por exemplo): salve o hook em `.githooks/commit-msg` e aponte o git para essa pasta. O `core.hooksPath` vale por clone, então documente o comando no README do repositório.

```bash
mkdir -p .githooks
curl -fsSL https://raw.githubusercontent.com/inga-c/.github/v1/hooks/commit-msg -o .githooks/commit-msg
chmod +x .githooks/commit-msg
git config core.hooksPath .githooks
```

Nos dois casos, adicione ao `.gitattributes` uma linha para o hook manter fim de linha LF no Windows (`.husky/* text eol=lf` ou `.githooks/* text eol=lf`).

### 3. CONTRIBUTING

Sem `CONTRIBUTING.md` próprio, o repositório já mostra o deste. Com um próprio, copie a seção "Mensagens de commit" do `CONTRIBUTING.md` daqui.

## Desenvolvimento

- Testes do hook: `sh hooks/commit-msg.test.sh`.
- Versão do commitlint: em `commitlint/package.json`, com o `package-lock.json` atualizado por `npm install --prefix commitlint`.
- O CI deste repositório roda o workflow reutilizável da própria branch e os testes do hook.
