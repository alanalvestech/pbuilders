#!/bin/bash
# Baixar mídias do Instagram (fotos, vídeos, reels, stories, highlights)
#
# Usa instaloader (github.com/instaloader/instaloader) como backend principal.
# Fallback: playwright-cli pra screenshots quando instaloader não consegue.
#
# Uso:
#   bash media.sh <url_ou_shortcode> [output_dir]
#   bash media.sh stories <usuario> [output_dir]
#   bash media.sh highlights <usuario> [output_dir]
#   bash media.sh profile <usuario> [output_dir]    — baixa todos os posts
#
# Exemplos:
#   bash media.sh https://www.instagram.com/p/ABC123/
#   bash media.sh https://www.instagram.com/reel/ABC123/
#   bash media.sh stories profclaudiolucena /tmp/stories
#   bash media.sh highlights oismaelash
#   bash media.sh profile oismaelash /tmp/posts
#
# Requer:
#   pip install instaloader
#
# Login (primeira vez):
#   instaloader --login=pbuilders.ai
#   (salva sessão em ~/.config/instaloader/)

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Verificar se instaloader tá instalado
if ! command -v instaloader &>/dev/null; then
  echo "✗ instaloader não instalado. Instale com: pip install instaloader"
  exit 1
fi

ACTION="${1:?Uso: bash media.sh <url|stories|highlights|profile> [usuario_ou_dir] [output_dir]}"

# ── Helpers ───────────────────────────────────────────────

login_flag() {
  # Usa sessão salva se existir
  local SESSION_DIR="$HOME/.config/instaloader"
  if ls "$SESSION_DIR"/session-* &>/dev/null 2>&1; then
    local USER=$(ls "$SESSION_DIR"/session-* | head -1 | sed 's/.*session-//')
    echo "--login=$USER"
  else
    echo ""
  fi
}

# ── Stories ────────────────────────────────────────────────

if [ "$ACTION" = "stories" ]; then
  USER="${2:?Uso: bash media.sh stories <usuario> [output_dir]}"
  USER=$(echo "$USER" | sed 's/^@//')
  OUTPUT_DIR="${3:-/tmp/insta-media/$USER/stories}"
  mkdir -p "$OUTPUT_DIR"

  echo "→ Baixando stories de @$USER..."
  instaloader $(login_flag) --stories --no-posts --no-profile-pic \
    --dirname-pattern="$OUTPUT_DIR" \
    --filename-pattern="{date_utc:%Y%m%d_%H%M}_{shortcode}" \
    "$USER" 2>&1 | grep -v "^$"

  echo "✓ Stories salvos em $OUTPUT_DIR/"
  ls -la "$OUTPUT_DIR/" 2>/dev/null
  exit 0
fi

# ── Highlights ────────────────────────────────────────────

if [ "$ACTION" = "highlights" ]; then
  USER="${2:?Uso: bash media.sh highlights <usuario> [output_dir]}"
  USER=$(echo "$USER" | sed 's/^@//')
  OUTPUT_DIR="${3:-/tmp/insta-media/$USER/highlights}"
  mkdir -p "$OUTPUT_DIR"

  echo "→ Baixando highlights de @$USER..."
  instaloader $(login_flag) --highlights --no-posts --no-profile-pic \
    --dirname-pattern="$OUTPUT_DIR/{target}_{typename}" \
    --filename-pattern="{date_utc:%Y%m%d_%H%M}_{shortcode}" \
    "$USER" 2>&1 | grep -v "^$"

  echo "✓ Highlights salvos em $OUTPUT_DIR/"
  ls -la "$OUTPUT_DIR/" 2>/dev/null
  exit 0
fi

# ── Todos os posts de um perfil ───────────────────────────

if [ "$ACTION" = "profile" ]; then
  USER="${2:?Uso: bash media.sh profile <usuario> [output_dir]}"
  USER=$(echo "$USER" | sed 's/^@//')
  OUTPUT_DIR="${3:-/tmp/insta-media/$USER/posts}"
  mkdir -p "$OUTPUT_DIR"

  echo "→ Baixando posts de @$USER..."
  instaloader $(login_flag) --no-profile-pic --no-captions --no-metadata-json \
    --dirname-pattern="$OUTPUT_DIR" \
    --filename-pattern="{date_utc:%Y%m%d_%H%M}_{shortcode}" \
    "$USER" 2>&1 | grep -v "^$"

  echo "✓ Posts salvos em $OUTPUT_DIR/"
  ls -la "$OUTPUT_DIR/" 2>/dev/null
  exit 0
fi

# ── Post/Reel individual (URL ou shortcode) ───────────────

URL="$ACTION"

# Extrair shortcode da URL
if echo "$URL" | grep -q "instagram.com"; then
  SHORTCODE=$(echo "$URL" | grep -oE '/(p|reel|tv)/([^/]+)' | sed 's/.*\///')
else
  SHORTCODE="$URL"
fi

if [ -z "$SHORTCODE" ]; then
  echo "✗ Não conseguiu extrair shortcode de: $URL"
  echo "Uso: bash media.sh <url_do_post> [output_dir]"
  exit 1
fi

OUTPUT_DIR="${2:-/tmp/insta-media}"
mkdir -p "$OUTPUT_DIR"

echo "→ Baixando post $SHORTCODE..."
instaloader $(login_flag) --no-captions --no-metadata-json \
  --dirname-pattern="$OUTPUT_DIR" \
  --filename-pattern="{date_utc:%Y%m%d_%H%M}_{shortcode}" \
  -- "-$SHORTCODE" 2>&1 | grep -v "^$"

echo "✓ Mídia salva em $OUTPUT_DIR/"
ls -la "$OUTPUT_DIR/" 2>/dev/null
