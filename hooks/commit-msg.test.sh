#!/bin/sh
# Testes do hook commit-msg: cada caso diz se a mensagem passa (ok) ou é recusada (erro).
# Uso: sh hooks/commit-msg.test.sh

hook="$(dirname "$0")/commit-msg"
tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT
failures=0

check() {
  expected=$1
  printf '%b' "$2" > "$tmp"
  if sh "$hook" "$tmp" 2>/dev/null; then got=ok; else got=erro; fi
  if [ "$got" = "$expected" ]; then
    printf 'ok    %s\n' "$2"
  else
    printf 'FALHA esperado %s, veio %s: %s\n' "$expected" "$got" "$2"
    failures=$((failures + 1))
  fi
}

long_header="feat: $(printf 'a%.0s' $(seq 1 95))"
long_line=$(printf 'b%.0s' $(seq 1 101))
accented_100="feat: $(printf 'ç%.0s' $(seq 1 94))"

check ok   'feat: adiciona remarcação pelo link'
check ok   'fix(reserva): reprocessa a intenção com falha'
check ok   'feat(api)!: exige a unidade na reserva\n\nBREAKING CHANGE: chamadas sem a unidade são recusadas'
check ok   'chore: teste\n\nCorpo explicando o motivo.\n\nCo-authored-by: Pam <noreply@agentes.chat>'
check ok   'docs: explica o hook\n# Please enter the commit message for your changes.\n# Lines starting with # will be ignored.'
check ok   'ci: valida o título do PR\n\nVeja https://www.conventionalcommits.org/en/v1.0.0/#specification-com-um-link-bem-longo-que-passa-de-cem'
check ok   'refactor: troca API antiga por nova'
check ok   'test: cobre 404'
check ok   "$accented_100"
check ok   'Merge branch '"'"'main'"'"' into feat/x'
check ok   'Merge pull request #42 from inga-c/feat/x'
check ok   'Revert "feat: adiciona remarcação"'
check ok   'fixup! feat: adiciona remarcação'
check ok   ''

check erro 'Adiciona coisa'
check erro 'Padroniza commits'
check erro 'feat adiciona remarcação'
check erro 'feat:adiciona remarcação'
check erro 'Feat: adiciona remarcação'
check erro 'feature: adiciona remarcação'
check erro 'feat: '
check erro 'feat: Adiciona remarcação'
check erro 'feat: Ícone novo'
check erro 'feat: ADICIONA REMARCAÇÃO'
check erro 'feat: adiciona remarcação.'
check erro ' feat: adiciona remarcação'
check erro "$long_header"
check erro "feat: $(printf 'ç%.0s' $(seq 1 95))"
check erro "fix: corrige\n\n$long_line"

if [ "$failures" -gt 0 ]; then
  printf '\n%s caso(s) falharam\n' "$failures"
  exit 1
fi
printf '\ntodos os casos passaram\n'
