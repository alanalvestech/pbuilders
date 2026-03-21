#!/bin/bash
# Interação com stories do Instagram via playwright-cli
# Uso: bash scripts/insta-stories.sh <usuario> [max_replies]
#
# Fluxo:
#   1. Abre stories do usuário
#   2. Aceita prompt "View as pbuilders.ai?"
#   3. Percorre todos os stories extraindo conteúdo (alt-text + screenshots)
#   4. Retorna análise dos stories em JSON pra o agente decidir quais comentar
#
# O agente (Claude) usa o output pra decidir quais stories curtir/responder.
# Este script NÃO responde automaticamente — apenas coleta dados.

set -e

USER="${1:?Uso: bash scripts/insta-stories.sh <usuario> [max_stories]}"
MAX_STORIES="${2:-20}"
OUTPUT_DIR="/tmp/insta-stories-$$"
mkdir -p "$OUTPUT_DIR"

echo "📱 Coletando stories de @$USER..."

# 1. Navegar pros stories
playwright-cli -s=insta goto "https://www.instagram.com/stories/$USER/" 2>&1 | head -1

sleep 2

# 2. Aceitar prompt "View as pbuilders.ai?" se aparecer
SNAP_FILE=$(playwright-cli -s=insta snapshot 2>&1 | grep "Snapshot" | tail -1 | sed 's/.*(\(.*\))/\1/')
if [ -z "$SNAP_FILE" ]; then
  echo '{"error": "snapshot_failed", "stories": []}'
  exit 1
fi

VIEW_REF=$(cat "$SNAP_FILE" | grep "View story" | head -1 | sed -n 's/.*ref=\([^]]*\).*/\1/p')
if [ -n "$VIEW_REF" ]; then
  playwright-cli -s=insta click "$VIEW_REF" 2>&1 | head -1
  sleep 1
fi

# 3. Verificar se tem stories
SNAP_FILE=$(playwright-cli -s=insta snapshot 2>&1 | grep "Snapshot" | tail -1 | sed 's/.*(\(.*\))/\1/')
PAGE_URL=$(playwright-cli -s=insta snapshot 2>&1 | grep "Page URL" | head -1 | sed 's/.*: //')

if ! echo "$PAGE_URL" | grep -q "stories"; then
  echo '{"error": "no_stories", "stories": []}'
  exit 0
fi

# 4. Percorrer stories coletando dados
echo '{"user": "'"$USER"'", "stories": [' > "$OUTPUT_DIR/result.json"
STORY_NUM=0
FIRST=true

while [ $STORY_NUM -lt $MAX_STORIES ]; do
  STORY_NUM=$((STORY_NUM + 1))

  SNAP_FILE=$(playwright-cli -s=insta snapshot 2>&1 | grep "Snapshot" | tail -1 | sed 's/.*(\(.*\))/\1/')
  [ -z "$SNAP_FILE" ] && break

  # Extrair dados do story
  TIME=$(cat "$SNAP_FILE" | grep "time " | head -1 | sed -n 's/.*: \(.*\)/\1/p')
  PAGE_URL=$(playwright-cli -s=insta snapshot 2>&1 | grep "Page URL" | head -1 | sed 's/.*: //')

  # Verificar se saiu dos stories
  if ! echo "$PAGE_URL" | grep -q "stories"; then
    break
  fi

  # Extrair alt-text da imagem (descrição do conteúdo)
  ALT_TEXT=$(cat "$SNAP_FILE" | grep 'img "Photo by\|img "May be' | head -1 | sed -n "s/.*img \"\(.*\)\" \[ref.*/\1/p" | sed 's/"/\\"/g')

  # Verificar se é vídeo ou imagem
  HAS_VIDEO=$(cat "$SNAP_FILE" | grep -c 'Video player' || true)
  HAS_REEL=$(cat "$SNAP_FILE" | grep -c 'Watch full reel' || true)
  HAS_MUSIC=$(cat "$SNAP_FILE" | grep -iE "generic.*·" | head -1 | sed -n 's/.*generic \[ref=[^]]*\]: \(.*\)/\1/p' | sed 's/"/\\"/g')

  # Tipo de conteúdo
  TYPE="image"
  [ "$HAS_VIDEO" -gt 0 ] && TYPE="video"
  [ "$HAS_REEL" -gt 0 ] && TYPE="reel"

  # Tirar screenshot
  SCREENSHOT="$OUTPUT_DIR/story_${STORY_NUM}.png"
  playwright-cli -s=insta screenshot 2>&1 | head -1
  SCREENSHOT_FILE=$(ls -t .playwright-cli/*.png | head -1)
  cp "$SCREENSHOT_FILE" "$SCREENSHOT" 2>/dev/null || true

  # Extrair refs de interação
  LIKE_REF=$(cat "$SNAP_FILE" | grep 'button "Like"' | head -1 | sed -n 's/.*ref=\([^]]*\).*/\1/p')
  REPLY_REF=$(cat "$SNAP_FILE" | grep "textbox" | head -1 | sed -n 's/.*ref=\([^]]*\).*/\1/p')

  # Extrair story ID da URL
  STORY_ID=$(echo "$PAGE_URL" | grep -oE '[0-9]{10,}' | tail -1)

  # Adicionar ao JSON
  [ "$FIRST" = true ] && FIRST=false || echo ',' >> "$OUTPUT_DIR/result.json"
  cat >> "$OUTPUT_DIR/result.json" <<ENTRY
  {
    "num": $STORY_NUM,
    "time": "$TIME",
    "type": "$TYPE",
    "alt_text": "$ALT_TEXT",
    "music": "$HAS_MUSIC",
    "story_id": "$STORY_ID",
    "screenshot": "$SCREENSHOT",
    "url": "$PAGE_URL"
  }
ENTRY

  # Avançar pro próximo
  SNAP_FILE=$(playwright-cli -s=insta snapshot 2>&1 | grep "Snapshot" | tail -1 | sed 's/.*(\(.*\))/\1/')
  [ -z "$SNAP_FILE" ] && break
  NEXT_REF=$(cat "$SNAP_FILE" | grep -i "Next" | head -1 | sed -n 's/.*ref=\([^]]*\).*/\1/p')

  if [ -z "$NEXT_REF" ]; then
    break  # Último story
  fi

  playwright-cli -s=insta click "$NEXT_REF" 2>&1 | head -1
  sleep 0.5
done

echo ']}'  >> "$OUTPUT_DIR/result.json"

echo "✓ $STORY_NUM stories coletados em $OUTPUT_DIR/"
echo "---JSON---"
cat "$OUTPUT_DIR/result.json"
