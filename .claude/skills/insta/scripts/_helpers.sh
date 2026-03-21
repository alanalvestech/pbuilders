#!/bin/bash
# Funções compartilhadas para scripts de automação Instagram
# Uso: source "$(dirname "$0")/_helpers.sh"

SESSION="insta"
CLI="playwright-cli -s=$SESSION"

# ── Snapshot ──────────────────────────────────────────────

# Tira snapshot e retorna o caminho do arquivo YAML
insta_snapshot() {
  $CLI snapshot 2>&1 | head -1 > /dev/null
  ls -t .playwright-cli/*.yml 2>/dev/null | head -1
}

# Retorna a URL atual da página
insta_page_url() {
  $CLI snapshot 2>&1 | grep "Page URL" | head -1 | sed 's/.*: //'
}

# ── Extração de refs ──────────────────────────────────────

# Extrai ref de um elemento pelo texto (grep no snapshot)
# Uso: get_ref "button \"Follow\"" "$SNAP"
get_ref() {
  local PATTERN="$1"
  local SNAP="$2"
  cat "$SNAP" | grep "$PATTERN" | head -1 | sed -n 's/.*ref=\([^]]*\).*/\1/p'
}

# Extrai ref de botão por nome
# Uso: get_button_ref "Follow" "$SNAP"
get_button_ref() {
  local NAME="$1"
  local SNAP="$2"
  cat "$SNAP" | grep "button \"$NAME\"" | head -1 | sed -n 's/.*ref=\([^]]*\).*/\1/p'
}

# Extrai ref de textbox por nome
# Uso: get_textbox_ref "Message" "$SNAP"
get_textbox_ref() {
  local NAME="$1"
  local SNAP="$2"
  cat "$SNAP" | grep "textbox.*$NAME" | head -1 | sed -n 's/.*ref=\([^]]*\).*/\1/p'
}

# ── Navegação ─────────────────────────────────────────────

insta_goto() {
  $CLI goto "$1" 2>&1 | head -1
}

insta_click() {
  $CLI click "$1" 2>&1 | head -3
}

insta_fill() {
  $CLI fill "$1" "$2" 2>&1 | head -3
}

insta_screenshot() {
  $CLI screenshot 2>&1 | head -1
  ls -t .playwright-cli/*.png 2>/dev/null | head -1
}

# ── Popups ────────────────────────────────────────────────

# Fecha popups comuns do Instagram (Not Now, Close, etc)
dismiss_popups() {
  local SNAP=$(insta_snapshot)
  [ -z "$SNAP" ] && return

  # "Not Now" (notifications, save login, etc)
  local REF=$(get_button_ref "Not Now" "$SNAP")
  if [ -n "$REF" ]; then
    insta_click "$REF" > /dev/null
    sleep 1
  fi

  # "Close" genérico
  REF=$(get_button_ref "Close" "$SNAP")
  if [ -n "$REF" ]; then
    insta_click "$REF" > /dev/null
    sleep 1
  fi
}

# ── Verificação de sessão ─────────────────────────────────

# Verifica se está logado. Retorna 0 se logado, 1 se não.
is_logged_in() {
  local SNAP=$(insta_snapshot)
  [ -z "$SNAP" ] && return 1
  cat "$SNAP" | grep -qi "Home\|Reels\|Messages\|Página inicial" && return 0
  return 1
}

# Garante que tem sessão ativa. Se não, tenta abrir.
ensure_session() {
  $CLI snapshot 2>&1 | head -1 > /dev/null
  if [ $? -ne 0 ]; then
    echo "📱 Abrindo sessão..."
    $CLI open --persistent 2>&1 | head -1
    insta_goto "https://www.instagram.com/"
    sleep 2
  fi
}

# ── Rate limiting ─────────────────────────────────────────

# Espera entre ações pra evitar bloqueio
rate_limit_wait() {
  local SECONDS="${1:-3}"
  sleep "$SECONDS"
}

# ── Output ────────────────────────────────────────────────

ok()   { echo "✓ $*"; }
fail() { echo "✗ $*"; }
warn() { echo "⚠ $*"; }
info() { echo "→ $*"; }
