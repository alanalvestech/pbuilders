#!/bin/bash
# Seguir ou deixar de seguir contas no Instagram
#
# Uso:
#   bash follow.sh follow usuario1 usuario2 ...
#   bash follow.sh unfollow usuario1 usuario2 ...
#   bash follow.sh check usuario     — verifica se já segue
#
# Rate limit: espera 3-5s entre cada ação

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/_helpers.sh"

ACTION="${1:?Uso: bash follow.sh [follow|unfollow|check] usuario1 usuario2 ...}"
shift

[ $# -eq 0 ] && { fail "Nenhum usuário especificado"; exit 1; }

for RAW_USER in "$@"; do
  # Limpar @ do início se tiver
  USER=$(echo "$RAW_USER" | sed 's/^@//')

  info "Processando @$USER..."

  insta_goto "https://www.instagram.com/$USER/"
  sleep 2

  SNAP=$(insta_snapshot)

  # Verificar se perfil existe
  PAGE_URL=$(insta_page_url)
  if echo "$PAGE_URL" | grep -qi "not-found\|404"; then
    fail "@$USER — perfil não encontrado"
    continue
  fi

  case "$ACTION" in
    follow)
      # Verificar estado atual
      if cat "$SNAP" | grep -q 'button "Following'; then
        ok "@$USER — já segue"
        continue
      fi

      FOLLOW_REF=$(get_button_ref "Follow" "$SNAP")
      if [ -n "$FOLLOW_REF" ]; then
        insta_click "$FOLLOW_REF" > /dev/null
        sleep 1
        # Verificar
        SNAP=$(insta_snapshot)
        if cat "$SNAP" | grep -q 'button "Following'; then
          ok "@$USER — seguido"
        else
          warn "@$USER — clicou Follow mas não confirmou"
        fi
      else
        fail "@$USER — botão Follow não encontrado"
      fi
      ;;

    unfollow)
      FOLLOWING_REF=$(cat "$SNAP" | grep 'button "Following' | head -1 | sed -n 's/.*ref=\([^]]*\).*/\1/p')
      if [ -z "$FOLLOWING_REF" ]; then
        ok "@$USER — não seguia"
        continue
      fi

      # Clicar em Following → abre menu
      insta_click "$FOLLOWING_REF" > /dev/null
      sleep 1

      # Clicar em Unfollow no menu
      SNAP=$(insta_snapshot)
      UNFOLLOW_REF=$(get_button_ref "Unfollow" "$SNAP")
      if [ -n "$UNFOLLOW_REF" ]; then
        insta_click "$UNFOLLOW_REF" > /dev/null
        ok "@$USER — deixou de seguir"
      else
        fail "@$USER — botão Unfollow não encontrado no menu"
      fi
      ;;

    check)
      if cat "$SNAP" | grep -q 'button "Following'; then
        ok "@$USER — segue"
      else
        info "@$USER — não segue"
      fi

      # Mostrar info básica
      FOLLOWERS=$(cat "$SNAP" | grep "followers" | head -1 | sed -n 's/.*generic \[ref=[^]]*\]: "\{0,1\}\([^"]*\)"\{0,1\}/\1/p')
      NAME=$(cat "$SNAP" | grep -A1 "heading.*$USER" | tail -1 | sed -n 's/.*generic \[ref=[^]]*\]: \(.*\)/\1/p')
      [ -n "$NAME" ] && echo "  Nome: $NAME"
      [ -n "$FOLLOWERS" ] && echo "  Followers: $FOLLOWERS"
      ;;

    *)
      fail "Ação desconhecida: $ACTION"
      echo "Uso: bash follow.sh [follow|unfollow|check] usuario1 ..."
      exit 1
      ;;
  esac

  rate_limit_wait 3
done
