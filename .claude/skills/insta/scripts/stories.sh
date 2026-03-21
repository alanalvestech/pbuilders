#!/bin/bash
# Coletar dados dos stories de um usuário no Instagram
#
# Uso:
#   bash stories.sh <usuario> [max_stories]
#
# Output:
#   - JSON com dados de cada story (alt-text, tipo, tempo, URL)
#   - Screenshots de cada story em /tmp/insta-stories-PID/
#
# O agente (Claude) usa o output pra:
#   1. Ler screenshots e entender o contexto visual
#   2. Selecionar no máximo 3 stories pra interagir
#   3. Curtir + responder usando interact-story.sh
#
# Este script NÃO responde — apenas coleta dados.

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/_helpers.sh"

USER="${1:?Uso: bash stories.sh <usuario> [max_stories]}"
USER=$(echo "$USER" | sed 's/^@//')
MAX_STORIES="${2:-20}"
OUTPUT_DIR="/tmp/insta-stories-$$"
mkdir -p "$OUTPUT_DIR"

info "Coletando stories de @$USER..."

# 1. Navegar pros stories
insta_goto "https://www.instagram.com/stories/$USER/"
sleep 2

# 2. Aceitar prompt "View as pbuilders.ai?"
SNAP=$(insta_snapshot)
if [ -z "$SNAP" ]; then
  echo '{"error": "snapshot_failed", "stories": []}'
  exit 1
fi

VIEW_REF=$(get_button_ref "View story" "$SNAP")
if [ -n "$VIEW_REF" ]; then
  insta_click "$VIEW_REF" > /dev/null
  sleep 1
fi

# 3. Verificar se tem stories
PAGE_URL=$(insta_page_url)
if ! echo "$PAGE_URL" | grep -q "stories"; then
  echo '{"error": "no_stories", "user": "'"$USER"'", "stories": []}'
  exit 0
fi

# 4. Percorrer stories coletando dados
echo '{"user": "'"$USER"'", "output_dir": "'"$OUTPUT_DIR"'", "stories": [' > "$OUTPUT_DIR/result.json"
STORY_NUM=0
FIRST=true

while [ $STORY_NUM -lt $MAX_STORIES ]; do
  STORY_NUM=$((STORY_NUM + 1))

  SNAP=$(insta_snapshot)
  [ -z "$SNAP" ] && break

  # Extrair dados
  TIME=$(cat "$SNAP" | grep "time " | head -1 | sed -n 's/.*: \(.*\)/\1/p')
  PAGE_URL=$(insta_page_url)

  # Verificar se saiu dos stories
  if ! echo "$PAGE_URL" | grep -q "stories"; then
    STORY_NUM=$((STORY_NUM - 1))
    break
  fi

  # Alt-text (descrição automática do Instagram)
  ALT_TEXT=$(cat "$SNAP" | grep 'img "Photo by\|img "May be' | head -1 | sed -n "s/.*img \"\(.*\)\" \[ref.*/\1/p" | sed 's/"/\\"/g')

  # Tipo de conteúdo
  HAS_VIDEO=$(cat "$SNAP" | grep -c 'Video player' || true)
  HAS_REEL=$(cat "$SNAP" | grep -c 'Watch full reel' || true)
  TYPE="image"
  [ "$HAS_VIDEO" -gt 0 ] && TYPE="video"
  [ "$HAS_REEL" -gt 0 ] && TYPE="reel"

  # Música (se tiver)
  MUSIC=$(cat "$SNAP" | grep -iE "generic.*·" | head -1 | sed -n 's/.*generic \[ref=[^]]*\]: \(.*\)/\1/p' | sed 's/"/\\"/g')

  # Screenshot
  SCREENSHOT_FILE=$(insta_screenshot)
  cp "$SCREENSHOT_FILE" "$OUTPUT_DIR/story_${STORY_NUM}.png" 2>/dev/null || true

  # Story ID da URL
  STORY_ID=$(echo "$PAGE_URL" | grep -oE '[0-9]{10,}' | tail -1)

  # JSON
  [ "$FIRST" = true ] && FIRST=false || echo ',' >> "$OUTPUT_DIR/result.json"
  cat >> "$OUTPUT_DIR/result.json" <<ENTRY
  {
    "num": $STORY_NUM,
    "time": "$TIME",
    "type": "$TYPE",
    "alt_text": "$ALT_TEXT",
    "music": "$MUSIC",
    "story_id": "$STORY_ID",
    "screenshot": "$OUTPUT_DIR/story_${STORY_NUM}.png",
    "url": "$PAGE_URL"
  }
ENTRY

  # Avançar
  SNAP=$(insta_snapshot)
  [ -z "$SNAP" ] && break
  NEXT_REF=$(cat "$SNAP" | grep -i "button.*Next" | head -1 | sed -n 's/.*ref=\([^]]*\).*/\1/p')
  [ -z "$NEXT_REF" ] && break

  insta_click "$NEXT_REF" > /dev/null
  sleep 0.5
done

echo ']}'  >> "$OUTPUT_DIR/result.json"

ok "$STORY_NUM stories coletados em $OUTPUT_DIR/"
echo "---JSON---"
cat "$OUTPUT_DIR/result.json"
