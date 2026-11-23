# Contribuindo

Este é o texto padrão de contribuição da IngaCode. Ele vale para todo repositório da organização `inga-c` que não tem um `CONTRIBUTING.md` próprio. O repositório que tiver o seu copia daqui a seção de commits e ajusta só o idioma e os exemplos.

## Mensagens de commit

Todo commit, de pessoa ou de agente, e todo título de PR seguem o [Conventional Commits 1.0.0](https://www.conventionalcommits.org/en/v1.0.0/#specification). O idioma da descrição é um só em cada repositório.

```
<tipo>(<escopo opcional>): <descrição>

[corpo opcional]

[rodapé(s) opcional(is)]
```

Tipos aceitos: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore` e `revert`.

- A descrição começa com letra minúscula, no imperativo, sem ponto final, e o cabeçalho tem até 100 caracteres.
- Quebra de compatibilidade: `!` depois do tipo ou do escopo (`feat(reserva)!: ...`) ou um rodapé `BREAKING CHANGE: <o que quebra>`.
- Corpo e rodapé ficam separados do cabeçalho por uma linha em branco, com linhas de até 100 caracteres (linhas com URL podem passar).

Exemplos:

```
feat(reserva): permite remarcar pelo link
fix(sincronizacao): reprocessa evento com falha uma única vez
docs: explica a convenção de commits no CONTRIBUTING
feat(api)!: exige o identificador da unidade na reserva

BREAKING CHANGE: chamadas sem o identificador da unidade passam a ser recusadas
```

### Como é verificado

- Localmente: o hook `commit-msg` recusa a mensagem fora do padrão antes de o commit existir. Nunca use `--no-verify`.
- No PR: o workflow `Conventional Commits` roda os checks `conventional-commits / commitlint` (todos os commits do PR) e `conventional-commits / pr-title` (o título do PR, que vira a mensagem no squash). Os dois são obrigatórios para fazer merge na `main`.

### Template de commit

O `commit.template` traz o formato e os tipos como lembrete no editor. Para usá-lo em todos os seus repositórios:

```bash
curl -fsSL https://raw.githubusercontent.com/inga-c/.github/v1/commit.template -o ~/.gitmessage
git config --global commit.template ~/.gitmessage
```

## Branches

- Feature nova: `feat/<nome-da-feat>`.
- Correção: `fix/<nome>`.
- Manutenção, configuração e ferramentas: `chore/<nome>`.

Nada vai para a `main` sem PR aprovado.
