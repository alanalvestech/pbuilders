#!/bin/bash
# Analisar perfil de um usuário no Instagram
#
# Uso:
#   bash profile.sh <usuario>
#
# Retorna: nome, bio, followers, following, posts count, highlights,
#          alt-text dos posts, e screenshot do perfil.

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/_helpers.sh"

USER="${1:?Uso: bash profile.sh <usuario>}"
USER=$(echo "$USER" | sed 's/^@//')

info "Analisando perfil de @$USER..."

insta_goto "https://www.instagram.com/$USER/"
sleep 2

dismiss_popups

SNAP=$(insta_snapshot)

# Screenshot do perfil
SCREENSHOT=$(insta_screenshot)
cp "$SCREENSHOT" "/tmp/profile_${USER}.png" 2>/dev/null || true

# Dados básicos
echo "=== PERFIL @$USER ==="

# Nome
NAME=$(cat "$SNAP" | grep -A1 "heading.*$USER" | grep "generic" | head -1 | sed -n 's/.*generic \[ref=[^]]*\]: \(.*\)/\1/p')
[ -n "$NAME" ] && echo "Nome: $NAME"

# Followers / Following
FOLLOWERS=$(cat "$SNAP" | grep "followers" | grep "link" | head -1 | sed -n 's/.*"\([0-9.,KkMm]*\) followers".*/\1/p')
FOLLOWING=$(cat "$SNAP" | grep "following" | grep "link" | head -1 | sed -n 's/.*"\([0-9.,KkMm]*\) following".*/\1/p')
POSTS=$(cat "$SNAP" | grep "posts" | head -1 | sed -n 's/.*"\([0-9.,]*\)"/\1/p')
echo "Posts: ${POSTS:-?} | Followers: ${FOLLOWERS:-?} | Following: ${FOLLOWING:-?}"

# Status (segue ou não)
if cat "$SNAP" | grep -q 'button "Following'; then
  echo "Status: Seguindo"
else
  echo "Status: Não segue"
fi

# Highlights
echo ""
echo "=== HIGHLIGHTS ==="
cat "$SNAP" | grep "highlight story picture" | grep -oP 'picture \K[^"]*' | while read -r HL; do
  echo "  - $HL"
done

# Posts (alt-text)
echo ""
echo "=== POSTS ==="
cat "$SNAP" | grep "Photo by\|Video by" | grep "link\|img" | sed -n 's/.*"\(Photo by.*\|Video by.*\)" \[ref.*/  - \1/p' | head -10

echo ""
echo "Screenshot: /tmp/profile_${USER}.png"
