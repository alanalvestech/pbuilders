#!/bin/bash
# Login automático no Instagram via playwright-cli
# Lê credenciais do Keychain (pede Touch ID)
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "🔐 Recuperando credenciais do Keychain (Touch ID necessário)..."

USERNAME=$("$SCRIPT_DIR/insta-keychain.sh" get-user)
if [ -z "$USERNAME" ]; then
  echo "✗ Credenciais não encontradas. Execute primeiro:"
  echo "  bash scripts/insta-keychain.sh save"
  exit 1
fi

PASSWORD=$("$SCRIPT_DIR/insta-keychain.sh" get-pass)
if [ -z "$PASSWORD" ]; then
  echo "✗ Senha não encontrada no Keychain."
  exit 1
fi

echo "✓ Credenciais obtidas para @$USERNAME"

# Fechar sessão anterior se existir
playwright-cli -s=insta close 2>/dev/null || true

# Abrir browser persistente
echo "📱 Abrindo browser..."
playwright-cli -s=insta open --persistent

# Navegar pro Instagram
playwright-cli -s=insta goto https://www.instagram.com/

# Verificar se já está logado
SNAPSHOT=$(playwright-cli -s=insta snapshot 2>&1)
if echo "$SNAPSHOT" | grep -qi "Home\|Página inicial\|Reels"; then
  echo "✓ Já está logado!"
  # Limpar variáveis sensíveis
  unset USERNAME PASSWORD
  exit 0
fi

# Preencher login
echo "🔑 Fazendo login..."
playwright-cli -s=insta goto https://www.instagram.com/accounts/login/
sleep 2
playwright-cli -s=insta snapshot > /dev/null 2>&1

# Encontrar e preencher campos
USERNAME_REF=$(playwright-cli -s=insta snapshot 2>&1 | grep -i "username\|usuário\|phone\|email" | grep "textbox\|input" | head -1 | sed -n 's/.*ref=\([^]]*\).*/\1/p' || true)
if [ -n "$USERNAME_REF" ]; then
  playwright-cli -s=insta fill "$USERNAME_REF" "$USERNAME" 2>/dev/null
else
  echo "✗ Campo de username não encontrado"
  unset USERNAME PASSWORD
  exit 1
fi

sleep 1

PASSWORD_REF=$(playwright-cli -s=insta snapshot 2>&1 | grep -i "password\|senha" | grep "textbox\|input" | head -1 | sed -n 's/.*ref=\([^]]*\).*/\1/p' || true)
if [ -n "$PASSWORD_REF" ]; then
  playwright-cli -s=insta fill "$PASSWORD_REF" "$PASSWORD" 2>/dev/null
else
  echo "✗ Campo de password não encontrado"
  unset USERNAME PASSWORD
  exit 1
fi

# Limpar variáveis sensíveis imediatamente
unset USERNAME PASSWORD

sleep 1

# Clicar em Log In
LOGIN_REF=$(playwright-cli -s=insta snapshot 2>&1 | grep -i "log in\|entrar\|iniciar" | grep "button" | head -1 | sed -n 's/.*ref=\([^]]*\).*/\1/p' || true)
if [ -n "$LOGIN_REF" ]; then
  playwright-cli -s=insta click "$LOGIN_REF"
else
  echo "✗ Botão de login não encontrado"
  exit 1
fi

sleep 5

# Verificar se logou
SNAPSHOT=$(playwright-cli -s=insta snapshot 2>&1)
if echo "$SNAPSHOT" | grep -qi "Home\|Página inicial\|Reels"; then
  echo "✓ Login realizado com sucesso!"
else
  echo "⚠ Login pode ter falhado (verificar 2FA ou challenge)"
  echo "  Se pediu verificação, abra com --headed pra resolver manualmente"
fi
