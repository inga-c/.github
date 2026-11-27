# .github

Repositório de padrões e convenções da IngaCode. Hoje ele guarda a convenção de commits ([Conventional Commits 1.0.0](https://www.conventionalcommits.org/en/v1.0.0/#specification)), usada por todos os repositórios da organização `inga-c`, e o workflow de versão e CHANGELOG pelo release-please.

| Arquivo | Para quê |
|---|---|
| `.github/workflows/commitlint.yml` | Workflow reutilizável que valida os commits e o título do PR |
| `.github/workflows/release-please.yml` | Workflow reutilizável que abre o PR de release e cria a tag, a GitHub Release e o CHANGELOG |
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

## Releases com release-please

O workflow `.github/workflows/release-please.yml` roda o [release-please](https://github.com/googleapis/release-please-action) a cada push na `main`. Ele lê os Conventional Commits desde a última release e mantém aberto um PR de release (`chore(main): release X.Y.Z`) com a próxima versão e o `CHANGELOG.md`. Quando esse PR entra, ele cria a tag `vX.Y.Z` e a GitHub Release.

### Como adotar

Na raiz do repositório:

- `release-please-config.json`, com o `release-type` (`node`, `simple`...) e, na adoção, um `bootstrap-sha` para ignorar o histórico anterior ao padrão.
- `.release-please-manifest.json`, com a versão atual (`{ ".": "0.0.1" }`).
- `.github/workflows/release-please.yml`:

```yaml
name: Release Please

on:
  push:
    branches: [main]

permissions:
  contents: write
  issues: write
  pull-requests: write

jobs:
  release-please:
    uses: inga-c/.github/.github/workflows/release-please.yml@v1
    secrets:
      app-id: ${{ secrets.RELEASE_APP_ID }}
      private-key: ${{ secrets.RELEASE_APP_PRIVATE_KEY }}
```

As permissões têm de estar no workflow que chama: o reutilizável não pode pedir mais do que recebe.

### Token: GitHub App ou GITHUB_TOKEN

- Com os secrets `app-id` (App ID ou Client ID) e `private-key` de um GitHub App da organização, o workflow gera um token de instalação com `actions/create-github-app-token`. O App precisa estar instalado no repositório com permissão de escrita em Contents, Issues e Pull requests.
- Sem eles, usa o `GITHUB_TOKEN`. Funciona, mas o que ele cria não dispara outros workflows: **o PR de release não roda os checks obrigatórios (`conventional-commits / commitlint` e `conventional-commits / pr-title`)** e fica bloqueado pela proteção da `main` até alguém disparar os checks (fechar e reabrir o PR, por exemplo) ou um admin fazer o merge. A tag e a Release também não disparam workflows de `push: tags` ou `release`.
- Nos dois casos, o repositório (ou a organização) precisa da opção **Settings › Actions › General › Allow GitHub Actions to create and approve pull requests** ligada.

### Outputs

| Output | Valor |
|---|---|
| `release_created` | `'true'` quando a execução criou a release (o PR de release acabou de entrar) |
| `tag_name` | Tag criada, como `v0.1.0` |
| `version` | Versão criada, como `0.1.0` |

Um job de deploy no mesmo workflow usa assim:

```yaml
  deploy:
    needs: release-please
    if: needs.release-please.outputs.release_created == 'true'
    runs-on: ubuntu-latest
    steps:
      - run: echo "Publicando ${{ needs.release-please.outputs.tag_name }}"
```

### Forçar uma versão

Para sair numa versão específica (a 1.0.0, por exemplo), use um commit com o rodapé `Release-As: 1.0.0`:

```bash
git commit --allow-empty -m "chore: lança a 1.0.0" -m "Release-As: 1.0.0"
```

## Desenvolvimento

- Testes do hook: `sh hooks/commit-msg.test.sh`.
- Versão do commitlint: em `commitlint/package.json`, com o `package-lock.json` atualizado por `npm install --prefix commitlint`.
- O CI deste repositório roda o workflow reutilizável da própria branch e os testes do hook.
