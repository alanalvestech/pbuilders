#!/bin/bash
# Curtir e responder um story específico no Instagram
#
# Uso:
#   bash story-reply.sh <usuario> <alt_text_pattern> <mensagem>
#
# Fluxo:
#   1. Abre stories do usuário
#   2. Avança até encontrar story com alt-text matching o pattern
#   3. Curte (SEMPRE primeiro)
#   4. Responde com a mensagem
#
# Regras:
#   - SEMPRE curtir antes de comentar
#   - Máximo 3 replies por sessão (controlado pelo agente, não aqui)
#   - Este script faz 1 reply por execução

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/_helpers.sh"

USER="${1:?Uso: bash story-reply.sh <usuario> <alt_text_pattern> <mensagem>}"
USER=$(echo "$USER" | sed 's/^@//')
PATTERN="${2:?Informe o pattern do alt-text pra encontrar o story}"
shift 2
MESSAGE="$*"
[ -z "$MESSAGE" ] && { fail "Mensagem vazia"; exit 1; }

info "Buscando story de @$USER com pattern: $PATTERN"

# 1. Abrir stories
insta_goto "https://www.instagram.com/stories/$USER/"
sleep 2

# 2. Aceitar "View story"
SNAP=$(insta_snapshot)
VIEW_REF=$(get_button_ref "View story" "$SNAP")
[ -n "$VIEW_REF" ] && { insta_click "$VIEW_REF" > /dev/null; sleep 1; }

# 3. Avançar até encontrar o story certo
FOUND=false
for i in $(seq 1 20); do
  SNAP=$(insta_snapshot)
  [ -z "$SNAP" ] && break

  PAGE_URL=$(insta_page_url)
  if ! echo "$PAGE_URL" | grep -q "stories"; then
    break
  fi

  # Verificar alt-text
  ALT_TEXT=$(cat "$SNAP" | grep "img.*May be\|img.*Photo by" | head -1)
  if echo "$ALT_TEXT" | grep -qi "$PATTERN"; then
    FOUND=true
    info "Story encontrado (#$i)"
    break
  fi

  # Avançar
  NEXT_REF=$(cat "$SNAP" | grep -i "button.*Next" | head -1 | sed -n 's/.*ref=\([^]]*\).*/\1/p')
  [ -z "$NEXT_REF" ] && break
  insta_click "$NEXT_REF" > /dev/null
  sleep 0.3
done

if [ "$FOUND" != true ]; then
  fail "Story com pattern '$PATTERN' não encontrado"
  exit 1
fi

# 4. CURTIR primeiro
SNAP=$(insta_snapshot)
LIKE_REF=$(get_button_ref "Like" "$SNAP")
if [ -n "$LIKE_REF" ]; then
  insta_click "$LIKE_REF" > /dev/null
  ok "Story curtido"
  sleep 0.5
fi

# 5. RESPONDER
SNAP=$(insta_snapshot)
REPLY_REF=$(cat "$SNAP" | grep "textbox" | head -1 | sed -n 's/.*ref=\([^]]*\).*/\1/p')
if [ -z "$REPLY_REF" ]; then
  # Textbox pode ter sumido após like — tentar reabrir
  insta_goto "https://www.instagram.com/stories/$USER/"
  sleep 2
  SNAP=$(insta_snapshot)
  VIEW_REF=$(get_button_ref "View story" "$SNAP")
  [ -n "$VIEW_REF" ] && { insta_click "$VIEW_REF" > /dev/null; sleep 1; }

  # Avançar até o story novamente
  for i in $(seq 1 20); do
    SNAP=$(insta_snapshot)
    ALT_TEXT=$(cat "$SNAP" | grep "img.*May be\|img.*Photo by" | head -1)
    if echo "$ALT_TEXT" | grep -qi "$PATTERN"; then
      break
    fi
    NEXT_REF=$(cat "$SNAP" | grep -i "button.*Next" | head -1 | sed -n 's/.*ref=\([^]]*\).*/\1/p')
    [ -z "$NEXT_REF" ] && break
    insta_click "$NEXT_REF" > /dev/null
    sleep 0.3
  done

  SNAP=$(insta_snapshot)
  REPLY_REF=$(cat "$SNAP" | grep "textbox" | head -1 | sed -n 's/.*ref=\([^]]*\).*/\1/p')
fi

if [ -z "$REPLY_REF" ]; then
  fail "Campo de resposta não encontrado"
  exit 1
fi

insta_fill "$REPLY_REF" "$MESSAGE" > /dev/null
sleep 0.5

# 6. Enviar
SNAP=$(insta_snapshot)
SEND_REF=$(get_button_ref "Send" "$SNAP")
if [ -n "$SEND_REF" ]; then
  insta_click "$SEND_REF" > /dev/null
  ok "Reply enviado para story de @$USER"
else
  fail "Botão Send não encontrado"
  exit 1
fi
