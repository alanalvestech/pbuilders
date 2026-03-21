#!/bin/bash
# Sistema de log/CRM para interações no Instagram
#
# Registra toda interação da @pbuilders.ai com outros perfis.
# Mantém histórico de conversas, follows e comportamento.
#
# Uso:
#   bash log.sh conversation <usuario> <direction> <type> <message>
#   bash log.sh follow <usuario> [source] [notes]
#   bash log.sh unfollow <usuario>
#   bash log.sh visit <usuario> <story|profile|chat>
#   bash log.sh profile <usuario> <campo> <valor>
#   bash log.sh read <usuario>
#   bash log.sh list-following
#   bash log.sh list-conversations
#   bash log.sh search <termo>
#
# Diretórios:
#   data/conversations/   — CSV por pessoa (histórico de DMs e replies)
#   data/profiles/         — MD por pessoa (análise + comportamento)
#   data/following.csv     — Lista de quem segue + últimas visitas

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DATA_DIR="$SCRIPT_DIR/../data"
CONVERSATIONS_DIR="$DATA_DIR/conversations"
PROFILES_DIR="$DATA_DIR/profiles"
FOLLOWING_CSV="$DATA_DIR/following.csv"

mkdir -p "$CONVERSATIONS_DIR" "$PROFILES_DIR"

# Inicializar CSV se não existe
[ ! -f "$FOLLOWING_CSV" ] && echo "username,followed_at,source,last_story_visit,last_profile_visit,last_chat_visit,notes" > "$FOLLOWING_CSV"

NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
TODAY=$(date -u +"%Y-%m-%d")

# ── Sanitizar texto pra CSV ──────────────────────────────

csv_escape() {
  echo "$1" | sed 's/"/""/g' | tr '\n' ' '
}

# ── Atualizar coluna no following.csv ─────────────────────

update_following_column() {
  local USER="$1"
  local COL_NUM="$2"   # 4=last_story, 5=last_profile, 6=last_chat
  local VALUE="$3"

  if ! grep -q "^$USER," "$FOLLOWING_CSV" 2>/dev/null; then
    return 1
  fi

  local TEMP=$(mktemp)
  awk -F',' -v user="$USER" -v col="$COL_NUM" -v val="$VALUE" '
    BEGIN { OFS="," }
    $1 == user { $col = val }
    { print }
  ' "$FOLLOWING_CSV" > "$TEMP"
  mv "$TEMP" "$FOLLOWING_CSV"
}

# ── CONVERSATION — registrar mensagem ────────────────────

log_conversation() {
  local USER="$1"
  local DIRECTION="$2"  # sent | received
  local TYPE="$3"       # dm | story_reply | story_like | comment | like
  local MESSAGE="$4"

  local CSV="$CONVERSATIONS_DIR/${USER}.csv"
  [ ! -f "$CSV" ] && echo "timestamp,direction,type,message" > "$CSV"

  local ESCAPED_MSG=$(csv_escape "$MESSAGE")
  echo "$NOW,$DIRECTION,$TYPE,\"$ESCAPED_MSG\"" >> "$CSV"

  # Atualizar última visita de chat se for DM
  if [ "$TYPE" = "dm" ]; then
    update_following_column "$USER" 6 "$NOW" 2>/dev/null || true
  fi

  # Atualizar última visita de story se for story_reply/story_like
  if [ "$TYPE" = "story_reply" ] || [ "$TYPE" = "story_like" ]; then
    update_following_column "$USER" 4 "$NOW" 2>/dev/null || true
  fi

  echo "✓ Conversa registrada: @$USER [$DIRECTION/$TYPE]"
}

# ── FOLLOW — registrar follow ────────────────────────────

log_follow() {
  local USER="$1"
  local SOURCE="${2:-manual}"  # manual | auto | reciprocal
  local NOTES="${3:-}"

  # Verificar se já existe
  if grep -q "^$USER," "$FOLLOWING_CSV" 2>/dev/null; then
    echo "→ @$USER já está na lista de following"
    return
  fi

  echo "$USER,$NOW,$SOURCE,,,,${NOTES}" >> "$FOLLOWING_CSV"
  echo "✓ Follow registrado: @$USER (source: $SOURCE)"
}

# ── UNFOLLOW — registrar unfollow ────────────────────────

log_unfollow() {
  local USER="$1"

  if grep -q "^$USER," "$FOLLOWING_CSV" 2>/dev/null; then
    local TEMP=$(mktemp)
    grep -v "^$USER," "$FOLLOWING_CSV" > "$TEMP"
    mv "$TEMP" "$FOLLOWING_CSV"
  fi

  echo "✓ Unfollow registrado: @$USER"
}

# ── VISIT — registrar visita a story/perfil/chat ─────────

log_visit() {
  local USER="$1"
  local TYPE="$2"  # story | profile | chat

  case "$TYPE" in
    story|stories)
      update_following_column "$USER" 4 "$NOW"
      echo "✓ Visita a stories de @$USER registrada"
      ;;
    profile)
      update_following_column "$USER" 5 "$NOW"
      echo "✓ Visita ao perfil de @$USER registrada"
      ;;
    chat|dm)
      update_following_column "$USER" 6 "$NOW"
      echo "✓ Visita ao chat de @$USER registrada"
      ;;
    *)
      echo "✗ Tipo de visita desconhecido: $TYPE (use: story, profile, chat)"
      exit 1
      ;;
  esac
}

# ── PROFILE — salvar/atualizar dados do perfil ───────────

log_profile() {
  local USER="$1"
  local FIELD="$2"
  local VALUE="$3"

  local MD="$PROFILES_DIR/${USER}.md"

  # Criar arquivo se não existe
  if [ ! -f "$MD" ]; then
    cat > "$MD" <<TEMPLATE
# @$USER

## Info
- **Nome:**
- **Bio:**
- **Followers:**
- **Following:**
- **Posts:**
- **Localização:**
- **Profissão:**
- **Stack/Área:**

## Primeira interação
- **Data:** $TODAY
- **Como conheceu:**

## Comportamento observado
<!-- Padrões de posts, horários, temas recorrentes -->

## Notas
<!-- Observações livres sobre a pessoa -->

## Relevância pra PBuilders
<!-- Por que essa pessoa importa pra comunidade -->

TEMPLATE
    echo "✓ Perfil criado: $MD"
  fi

  # Atualizar campo específico se passado
  if [ -n "$FIELD" ] && [ -n "$VALUE" ]; then
    if grep -q "^\- \*\*${FIELD}:\*\*" "$MD"; then
      sed -i '' "s|^\- \*\*${FIELD}:\*\*.*|\- \*\*${FIELD}:\*\* ${VALUE}|" "$MD"
      echo "✓ Perfil @$USER atualizado: $FIELD = $VALUE"
    else
      echo "- **${FIELD}:** ${VALUE}" >> "$MD"
      echo "✓ Perfil @$USER: campo '$FIELD' adicionado"
    fi
  fi
}

# ── READ — ler dados de um usuário ───────────────────────

read_user() {
  local USER="$1"

  echo "=== @$USER ==="

  # Perfil
  local MD="$PROFILES_DIR/${USER}.md"
  if [ -f "$MD" ]; then
    echo ""
    echo "--- PERFIL ---"
    cat "$MD"
  fi

  # Conversas
  local CSV="$CONVERSATIONS_DIR/${USER}.csv"
  if [ -f "$CSV" ]; then
    echo ""
    echo "--- CONVERSAS ---"
    cat "$CSV"
  fi

  # Following status
  if grep -q "^$USER," "$FOLLOWING_CSV" 2>/dev/null; then
    echo ""
    echo "--- STATUS: Seguindo ---"
    grep "^$USER," "$FOLLOWING_CSV"
  fi
}

# ── LIST — listar ────────────────────────────────────────

list_following() {
  echo "=== FOLLOWING ==="
  if [ -f "$FOLLOWING_CSV" ]; then
    cat "$FOLLOWING_CSV"
  fi
  echo ""
  echo "Total: $(tail -n +2 "$FOLLOWING_CSV" 2>/dev/null | wc -l | tr -d ' ') contas"
}

list_conversations() {
  echo "=== CONVERSAS ==="
  for csv in "$CONVERSATIONS_DIR"/*.csv; do
    [ ! -f "$csv" ] && continue
    local USER=$(basename "$csv" .csv)
    local COUNT=$(tail -n +2 "$csv" | wc -l | tr -d ' ')
    local LAST=$(tail -1 "$csv" | cut -d',' -f1)
    echo "  @$USER — $COUNT mensagens (última: $LAST)"
  done
}

# ── SEARCH — buscar em tudo ──────────────────────────────

search_all() {
  local TERM="$1"
  echo "=== Buscando: $TERM ==="

  echo ""
  echo "--- Conversas ---"
  grep -ril "$TERM" "$CONVERSATIONS_DIR/" 2>/dev/null | while read -r f; do
    echo "  $(basename "$f" .csv):"
    grep -i "$TERM" "$f" | head -5
  done

  echo ""
  echo "--- Perfis ---"
  grep -ril "$TERM" "$PROFILES_DIR/" 2>/dev/null | while read -r f; do
    echo "  $(basename "$f" .md):"
    grep -i "$TERM" "$f" | head -5
  done
}

# ── Main ─────────────────────────────────────────────────

CMD="${1:?Uso: bash log.sh <conversation|follow|unfollow|visit|profile|read|list-following|list-conversations|search> [args]}"
shift

case "$CMD" in
  conversation|conv|msg)
    log_conversation "$@"
    ;;
  follow)
    log_follow "$@"
    ;;
  unfollow)
    log_unfollow "$@"
    ;;
  visit)
    log_visit "$@"
    ;;
  profile)
    log_profile "$@"
    ;;
  read)
    read_user "$@"
    ;;
  list-following|following)
    list_following
    ;;
  list-conversations|conversations)
    list_conversations
    ;;
  search)
    search_all "$@"
    ;;
  *)
    echo "Comando desconhecido: $CMD"
    echo "Uso: bash log.sh <conversation|follow|unfollow|visit|profile|read|list-following|list-conversations|search> [args]"
    exit 1
    ;;
esac
