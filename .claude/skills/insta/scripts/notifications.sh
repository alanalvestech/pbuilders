#!/bin/bash
# Ler notificações do Instagram
#
# Uso:
#   bash notifications.sh [max_items]
#
# Retorna as notificações recentes em formato legível.

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/_helpers.sh"

MAX_ITEMS="${1:-20}"

info "Lendo notificações..."

insta_goto "https://www.instagram.com/"
sleep 2

dismiss_popups

# Clicar no ícone de notificações
SNAP=$(insta_snapshot)
NOTIF_REF=$(cat "$SNAP" | grep -i "Notifications\|Notificações" | grep "link\|button" | head -1 | sed -n 's/.*ref=\([^]]*\).*/\1/p')

if [ -z "$NOTIF_REF" ]; then
  fail "Ícone de notificações não encontrado"
  exit 1
fi

insta_click "$NOTIF_REF" > /dev/null
sleep 2

# Ler conteúdo
SNAP=$(insta_snapshot)
echo "=== NOTIFICAÇÕES ==="
cat "$SNAP" | grep -iE "liked|commented|started following|mentioned|tagged" | head -"$MAX_ITEMS" | while read -r line; do
  echo "  $line"
done
