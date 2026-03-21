#!/bin/bash
# Publicar post no Instagram
#
# Uso:
#   bash post.sh <caminho_imagem> [caption]
#
# O agente DEVE pedir confirmação antes de chamar este script.

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/_helpers.sh"

IMAGE="${1:?Uso: bash post.sh <caminho_imagem> [caption]}"
shift
CAPTION="$*"

[ ! -f "$IMAGE" ] && { fail "Arquivo não encontrado: $IMAGE"; exit 1; }

info "Publicando post..."

# 1. Ir pra home e clicar em Create
insta_goto "https://www.instagram.com/"
sleep 2

SNAP=$(insta_snapshot)
CREATE_REF=$(cat "$SNAP" | grep -i "New post\|Create\|Criar" | grep "link\|button" | head -1 | sed -n 's/.*ref=\([^]]*\).*/\1/p')
if [ -z "$CREATE_REF" ]; then
  fail "Botão Create/New post não encontrado"
  exit 1
fi

insta_click "$CREATE_REF" > /dev/null
sleep 2

# 2. Upload da imagem
$CLI upload "$IMAGE" 2>&1 | head -1
sleep 3

# 3. Avançar etapas (Next)
for step in 1 2; do
  SNAP=$(insta_snapshot)
  NEXT_REF=$(get_button_ref "Next" "$SNAP")
  if [ -n "$NEXT_REF" ]; then
    insta_click "$NEXT_REF" > /dev/null
    sleep 2
  fi
done

# 4. Preencher caption
if [ -n "$CAPTION" ]; then
  SNAP=$(insta_snapshot)
  CAPTION_REF=$(cat "$SNAP" | grep "textbox\|textarea" | head -1 | sed -n 's/.*ref=\([^]]*\).*/\1/p')
  if [ -n "$CAPTION_REF" ]; then
    insta_fill "$CAPTION_REF" "$CAPTION" > /dev/null
  fi
fi

# 5. Compartilhar
SNAP=$(insta_snapshot)
SHARE_REF=$(get_button_ref "Share" "$SNAP")
if [ -z "$SHARE_REF" ]; then
  SHARE_REF=$(cat "$SNAP" | grep -i "Compartilhar\|Share" | grep "button" | head -1 | sed -n 's/.*ref=\([^]]*\).*/\1/p')
fi

if [ -n "$SHARE_REF" ]; then
  insta_click "$SHARE_REF" > /dev/null
  sleep 5
  ok "Post publicado!"
else
  fail "Botão Share não encontrado"
  exit 1
fi
