#!/bin/bash
# Gerenciamento de credenciais Instagram via macOS Keychain
# Requer Touch ID para qualquer operação
#
# Uso:
#   bash keychain.sh save       — Salvar credenciais (interativo)
#   bash keychain.sh get-user   — Recuperar username (Touch ID)
#   bash keychain.sh get-pass   — Recuperar password (Touch ID)
#   bash keychain.sh delete     — Remover credenciais

SERVICE="instagram-pbuilders"
set -e

case "$1" in
  save)
    echo "Salvando credenciais no Keychain (vai pedir Touch ID)..."
    read -p "Username: " USERNAME
    read -s -p "Password: " PASSWORD
    echo ""

    security delete-generic-password -s "$SERVICE-user" 2>/dev/null || true
    security delete-generic-password -s "$SERVICE-pass" 2>/dev/null || true

    security add-generic-password -s "$SERVICE-user" -a "pbuilders" -w "$USERNAME" -T ""
    security add-generic-password -s "$SERVICE-pass" -a "pbuilders" -w "$PASSWORD" -T ""

    echo "✓ Credenciais salvas no Keychain."
    echo "  Touch ID será pedido sempre que alguém tentar acessar."
    ;;

  get-user)
    security find-generic-password -s "$SERVICE-user" -w 2>/dev/null
    ;;

  get-pass)
    security find-generic-password -s "$SERVICE-pass" -w 2>/dev/null
    ;;

  delete)
    echo "Removendo credenciais do Keychain..."
    security delete-generic-password -s "$SERVICE-user" 2>/dev/null || true
    security delete-generic-password -s "$SERVICE-pass" 2>/dev/null || true
    echo "✓ Credenciais removidas."
    ;;

  *)
    echo "Uso:"
    echo "  $0 save     — Salvar credenciais (pede username e password)"
    echo "  $0 get-user — Recuperar username (pede Touch ID)"
    echo "  $0 get-pass — Recuperar password (pede Touch ID)"
    echo "  $0 delete   — Remover credenciais"
    ;;
esac
