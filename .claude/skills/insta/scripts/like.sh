#!/bin/bash
# Curtir um post no Instagram
#
# Uso:
#   bash like.sh <url_ou_codigo_do_post>
#
# Exemplos:
#   bash like.sh /p/ABC123/
#   bash like.sh https://www.instagram.com/p/ABC123/

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/_helpers.sh"

POST="${1:?Uso: bash like.sh <url_ou_codigo_do_post>}"

# Normalizar URL
if ! echo "$POST" | grep -q "instagram.com"; then
  POST="https://www.instagram.com${POST}"
fi

info "Curtindo post: $POST"

insta_goto "$POST"
sleep 2

SNAP=$(insta_snapshot)
LIKE_REF=$(get_button_ref "Like" "$SNAP")

if [ -z "$LIKE_REF" ]; then
  # Pode já estar curtido (botão muda pra "Unlike")
  if cat "$SNAP" | grep -q 'button "Unlike"'; then
    ok "Post já estava curtido"
    exit 0
  fi
  fail "Botão de like não encontrado"
  exit 1
fi

insta_click "$LIKE_REF" > /dev/null
ok "Post curtido"
