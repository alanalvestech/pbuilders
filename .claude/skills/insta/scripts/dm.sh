#!/bin/bash
# Enviar DM no Instagram
#
# Uso:
#   bash dm.sh <usuario> <mensagem>
#
# Abre o perfil do usuário, clica em Message, preenche e envia.
# NÃO pede confirmação — o agente deve pedir antes de chamar.

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/_helpers.sh"

USER="${1:?Uso: bash dm.sh <usuario> <mensagem>}"
USER=$(echo "$USER" | sed 's/^@//')
shift
MESSAGE="$*"
[ -z "$MESSAGE" ] && { fail "Mensagem vazia"; exit 1; }

info "Enviando DM para @$USER..."

# 1. Ir pro perfil
insta_goto "https://www.instagram.com/$USER/"
sleep 2

# 2. Clicar em Message
SNAP=$(insta_snapshot)
MSG_REF=$(get_button_ref "Message" "$SNAP")
if [ -z "$MSG_REF" ]; then
  fail "Botão Message não encontrado no perfil de @$USER"
  exit 1
fi

insta_click "$MSG_REF" > /dev/null
sleep 2

# 3. Encontrar campo de texto
SNAP=$(insta_snapshot)
TEXTBOX_REF=$(get_textbox_ref "Message" "$SNAP")
if [ -z "$TEXTBOX_REF" ]; then
  fail "Campo de mensagem não encontrado"
  exit 1
fi

# 4. Preencher mensagem
insta_fill "$TEXTBOX_REF" "$MESSAGE" > /dev/null
sleep 0.5

# 5. Enviar
SNAP=$(insta_snapshot)
SEND_REF=$(get_button_ref "Send" "$SNAP")
if [ -z "$SEND_REF" ]; then
  fail "Botão Send não encontrado"
  exit 1
fi

insta_click "$SEND_REF" > /dev/null
sleep 1

# 6. Verificar e logar
SNAP=$(insta_snapshot)
if cat "$SNAP" | grep -q "You sent"; then
  ok "DM enviada para @$USER"
  # Logar conversa
  bash "$SCRIPT_DIR/log.sh" conversation "$USER" sent dm "$MESSAGE"
else
  warn "DM pode não ter sido enviada — verificar manualmente"
fi
