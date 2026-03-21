#!/bin/bash
# Editar bio do perfil Instagram
#
# Uso:
#   bash bio.sh <novo_texto_da_bio>
#
# O agente DEVE pedir confirmação antes de chamar este script.

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/_helpers.sh"

BIO_TEXT="${1:?Uso: bash bio.sh <novo_texto_da_bio>}"

info "Editando bio..."

insta_goto "https://www.instagram.com/accounts/edit/"
sleep 2

SNAP=$(insta_snapshot)
BIO_REF=$(cat "$SNAP" | grep "textbox\|textarea" | grep -i "bio" | head -1 | sed -n 's/.*ref=\([^]]*\).*/\1/p')
if [ -z "$BIO_REF" ]; then
  # Fallback: pegar qualquer textarea grande
  BIO_REF=$(cat "$SNAP" | grep "textarea" | head -1 | sed -n 's/.*ref=\([^]]*\).*/\1/p')
fi

if [ -z "$BIO_REF" ]; then
  fail "Campo da bio não encontrado"
  exit 1
fi

insta_fill "$BIO_REF" "$BIO_TEXT" > /dev/null
sleep 1

# Salvar
SNAP=$(insta_snapshot)
SUBMIT_REF=$(cat "$SNAP" | grep -i "Submit\|Enviar\|Save\|Salvar" | grep "button" | head -1 | sed -n 's/.*ref=\([^]]*\).*/\1/p')
if [ -n "$SUBMIT_REF" ]; then
  insta_click "$SUBMIT_REF" > /dev/null
  ok "Bio atualizada!"
else
  fail "Botão de salvar não encontrado"
  exit 1
fi
