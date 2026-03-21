#!/bin/bash
# Login no Instagram via playwright-cli + Keychain (Touch ID)
#
# Uso: bash login.sh
#
# Fluxo:
#   1. Abre browser persistente
#   2. Verifica se já está logado
#   3. Se não, recupera credenciais do Keychain (Touch ID)
#   4. Preenche login e envia
#   5. Trata popups (Save login, Notifications)
#
# SEGURANÇA:
#   - Credenciais nunca aparecem no output (2>/dev/null nos fills)
#   - Variáveis são limpas (unset) imediatamente após uso

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/_helpers.sh"

# 1. Garantir sessão
ensure_session

# 2. Verificar se já logado
insta_goto "https://www.instagram.com/"
sleep 2

if is_logged_in; then
  ok "Já está logado!"
  exit 0
fi

# 3. Recuperar credenciais
info "Recuperando credenciais do Keychain (Touch ID necessário)..."

USERNAME=$("$SCRIPT_DIR/keychain.sh" get-user)
if [ -z "$USERNAME" ]; then
  fail "Credenciais não encontradas. Execute primeiro:"
  echo "  bash $SCRIPT_DIR/keychain.sh save"
  exit 1
fi

PASSWORD=$("$SCRIPT_DIR/keychain.sh" get-pass)
if [ -z "$PASSWORD" ]; then
  fail "Senha não encontrada no Keychain."
  exit 1
fi

ok "Credenciais obtidas para @$USERNAME"

# 4. Navegar pra página de login
info "Fazendo login..."
insta_goto "https://www.instagram.com/accounts/login/"
sleep 2

# 5. Preencher campos
SNAP=$(insta_snapshot)

USERNAME_REF=$(cat "$SNAP" | grep -i "username\|usuário\|phone\|email" | grep "textbox\|input" | head -1 | sed -n 's/.*ref=\([^]]*\).*/\1/p' || true)
if [ -n "$USERNAME_REF" ]; then
  $CLI fill "$USERNAME_REF" "$USERNAME" 2>/dev/null
else
  fail "Campo de username não encontrado"
  unset USERNAME PASSWORD
  exit 1
fi

sleep 1
SNAP=$(insta_snapshot)

PASSWORD_REF=$(cat "$SNAP" | grep -i "password\|senha" | grep "textbox\|input" | head -1 | sed -n 's/.*ref=\([^]]*\).*/\1/p' || true)
if [ -n "$PASSWORD_REF" ]; then
  $CLI fill "$PASSWORD_REF" "$PASSWORD" 2>/dev/null
else
  fail "Campo de password não encontrado"
  unset USERNAME PASSWORD
  exit 1
fi

# Limpar variáveis sensíveis imediatamente
unset USERNAME PASSWORD

sleep 1

# 6. Clicar em Log In
SNAP=$(insta_snapshot)
LOGIN_REF=$(cat "$SNAP" | grep -i "log in\|entrar\|iniciar" | grep "button" | head -1 | sed -n 's/.*ref=\([^]]*\).*/\1/p' || true)
if [ -n "$LOGIN_REF" ]; then
  insta_click "$LOGIN_REF" > /dev/null
else
  fail "Botão de login não encontrado"
  exit 1
fi

sleep 5

# 7. Tratar popups
dismiss_popups

# 8. Verificar sucesso
if is_logged_in; then
  ok "Login realizado com sucesso!"
else
  warn "Login pode ter falhado (verificar 2FA ou challenge)"
  echo "  Se pediu verificação, abra com --headed pra resolver manualmente"
fi
