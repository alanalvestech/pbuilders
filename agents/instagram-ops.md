# Instagram Ops — Playbook de Automação

Guia operacional para gerenciar a conta @pbuilders.ai via `playwright-cli`.

## Setup

### Pré-requisitos
- `npm install -g @playwright/cli@latest`
- Arquivo `.env` com `INSTAGRAM_USERNAME` e `INSTAGRAM_PASSWORD`

### Primeira vez (login manual)
```bash
# Abre browser visível pra login manual
playwright-cli -s=insta open --persistent --headed https://www.instagram.com/

# Usuário faz login manualmente na janela que abriu
# Sessão fica salva em ~/.cache/ms-playwright/daemon/
```

### Sessões seguintes (headless)
```bash
# Abre em background, já logado
playwright-cli -s=insta open --persistent https://www.instagram.com/
```

### Verificar se está logado
```bash
playwright-cli -s=insta goto https://www.instagram.com/
playwright-cli -s=insta snapshot
# Se aparecer "Log in" ou "Sign up" no snapshot → não está logado
# Se aparecer nav com "Home", "Reels", "Messages" → logado
```

### Fechar browser
```bash
playwright-cli -s=insta close
```

---

## Ações

### 1. Seguir uma conta

```bash
# 1. Navegar pro perfil
playwright-cli -s=insta goto https://www.instagram.com/USUARIO/

# 2. Tirar snapshot pra encontrar o botão
playwright-cli -s=insta snapshot
# Procurar no YAML: "Follow" ou "Seguir" → anotar o ref (ex: ref=e82)

# 3. Clicar no botão
playwright-cli -s=insta click REF_DO_BOTAO

# 4. Verificar se seguiu (snapshot de novo)
playwright-cli -s=insta snapshot
# Se aparecer "Following" ou "Seguindo" → sucesso
```

**Rate limiting:** Esperar 3-5 segundos entre cada follow pra não ser bloqueado.

```bash
# Exemplo: seguir múltiplas contas com delay
for user in apgames_pb pbxpoficial phpeste crud.pb; do
  playwright-cli -s=insta goto "https://www.instagram.com/$user/"
  sleep 2
  playwright-cli -s=insta snapshot > /tmp/snap.yml
  REF=$(grep -i "follow" /tmp/snap.yml | grep "generic\|button" | grep -v "following\|followers" | head -1 | grep -oP 'ref=\K[^\]]+')
  if [ -n "$REF" ]; then
    playwright-cli -s=insta click "$REF"
    echo "✓ Seguiu @$user"
  fi
  sleep 3
done
```

### 2. Deixar de seguir

```bash
# 1. Navegar pro perfil
playwright-cli -s=insta goto https://www.instagram.com/USUARIO/

# 2. Snapshot → encontrar botão "Following" ou "Seguindo"
playwright-cli -s=insta snapshot

# 3. Clicar no botão "Following/Seguindo"
playwright-cli -s=insta click REF_DO_BOTAO

# 4. Vai abrir modal de confirmação → snapshot pra achar "Unfollow"
playwright-cli -s=insta snapshot
# Procurar "Unfollow" ou "Deixar de seguir"

# 5. Clicar em "Unfollow"
playwright-cli -s=insta click REF_UNFOLLOW
```

### 3. Publicar um post (foto)

```bash
# 1. Clicar no botão "Criar" / "New post" na nav
playwright-cli -s=insta goto https://www.instagram.com/
playwright-cli -s=insta snapshot
# Encontrar ref do botão "Create" ou "Criar"
playwright-cli -s=insta click REF_CRIAR

# 2. Upload da imagem
playwright-cli -s=insta snapshot
# Encontrar input de file ou botão "Select from computer"
playwright-cli -s=insta upload /caminho/para/imagem.jpg

# 3. Avançar pelas etapas (crop, filtros, caption)
playwright-cli -s=insta snapshot
# Encontrar "Next" ou "Avançar"
playwright-cli -s=insta click REF_NEXT

# 4. Repetir Next até chegar na caption
playwright-cli -s=insta snapshot
playwright-cli -s=insta click REF_NEXT

# 5. Escrever caption
playwright-cli -s=insta snapshot
# Encontrar textarea da caption
playwright-cli -s=insta fill REF_CAPTION "Texto do post aqui"

# 6. Publicar
playwright-cli -s=insta snapshot
# Encontrar "Share" ou "Compartilhar"
playwright-cli -s=insta click REF_SHARE
```

### 4. Responder comentário

```bash
# 1. Navegar pro post
playwright-cli -s=insta goto https://www.instagram.com/p/CODIGO_DO_POST/

# 2. Snapshot → encontrar os comentários
playwright-cli -s=insta snapshot

# 3. Clicar em "Reply" / "Responder" no comentário desejado
playwright-cli -s=insta click REF_RESPONDER

# 4. Digitar resposta
playwright-cli -s=insta fill REF_INPUT "Resposta aqui"

# 5. Enviar (Enter ou botão Post)
playwright-cli -s=insta snapshot
playwright-cli -s=insta click REF_POST
# ou
playwright-cli -s=insta eval "document.querySelector('form').submit()"
```

### 5. Enviar DM

```bash
# 1. Ir pra inbox
playwright-cli -s=insta goto https://www.instagram.com/direct/inbox/

# 2. Nova mensagem
playwright-cli -s=insta snapshot
# Encontrar botão de nova mensagem (ícone de lápis/compose)
playwright-cli -s=insta click REF_NOVA_MSG

# 3. Buscar usuário
playwright-cli -s=insta snapshot
playwright-cli -s=insta fill REF_SEARCH "username"

# 4. Selecionar usuário dos resultados
playwright-cli -s=insta snapshot
playwright-cli -s=insta click REF_USUARIO

# 5. Confirmar chat
playwright-cli -s=insta snapshot
playwright-cli -s=insta click REF_CHAT  # "Chat" ou "Next"

# 6. Escrever e enviar mensagem
playwright-cli -s=insta snapshot
playwright-cli -s=insta fill REF_MSG_INPUT "Mensagem aqui"
playwright-cli -s=insta snapshot
playwright-cli -s=insta click REF_SEND  # ou pressionar Enter
```

### 6. Editar bio

```bash
# 1. Ir pra edição de perfil
playwright-cli -s=insta goto https://www.instagram.com/accounts/edit/

# 2. Snapshot → encontrar textarea da bio
playwright-cli -s=insta snapshot

# 3. Limpar e preencher
playwright-cli -s=insta fill REF_BIO "Nova bio aqui"

# 4. Salvar
playwright-cli -s=insta snapshot
# Encontrar "Submit" / "Enviar"
playwright-cli -s=insta click REF_SUBMIT
```

### 7. Ver notificações

```bash
playwright-cli -s=insta goto https://www.instagram.com/
playwright-cli -s=insta snapshot
# Clicar no ícone de coração/notificações
playwright-cli -s=insta click REF_NOTIFICACOES
playwright-cli -s=insta snapshot
# Ler conteúdo das notificações no YAML
```

### 8. Curtir um post

```bash
# No feed ou numa página de post
playwright-cli -s=insta snapshot
# Encontrar botão de like (ícone coração) → ref
playwright-cli -s=insta click REF_LIKE
```

### 9. Interagir com stories

**Regras de ouro:**
- SEMPRE curtir antes de comentar
- Máximo 3 replies por usuário (evitar spam)
- Ler screenshots/alt-text pra entender contexto antes de responder

#### Fase 1 — Coletar dados dos stories
```bash
# Script automatizado que percorre todos os stories e gera JSON + screenshots
bash scripts/insta-stories.sh USUARIO [max_stories]
# Output: JSON em /tmp/insta-stories-PID/ com alt-text, tipo, screenshots
```

#### Fase 2 — Analisar e interagir

```bash
# 1. Abrir stories do usuário
playwright-cli -s=insta goto https://www.instagram.com/stories/USUARIO/

# 2. Aceitar prompt "View as pbuilders.ai?" (aparece na primeira vez)
playwright-cli -s=insta snapshot
# Procurar ref de "View story" e clicar
playwright-cli -s=insta click REF_VIEW_STORY

# 3. Navegar pelos stories (Next/Previous)
playwright-cli -s=insta snapshot
# Encontrar "Next" ou "Previous"
playwright-cli -s=insta click REF_NEXT

# 4. Identificar conteúdo via alt-text das imagens
# No snapshot YAML, procurar:
#   img "Photo by USER on DATE. May be an image of..."
#   img "May be a screenshot of..."
# Esses textos descrevem o conteúdo visual

# 5. Para stories de vídeo sem alt-text, tirar screenshot:
playwright-cli -s=insta screenshot
# Arquivo salvo em .playwright-cli/page-*.png

# 6. Curtir (SEMPRE antes de comentar)
playwright-cli -s=insta snapshot
LIKE_REF=$(grep 'button "Like"' SNAP | head -1 | sed -n 's/.*ref=\([^]]*\).*/\1/p')
playwright-cli -s=insta click $LIKE_REF

# 7. Responder
playwright-cli -s=insta snapshot
REPLY_REF=$(grep "textbox" SNAP | head -1 | sed -n 's/.*ref=\([^]]*\).*/\1/p')
playwright-cli -s=insta fill $REPLY_REF "mensagem"
playwright-cli -s=insta snapshot
SEND_REF=$(grep 'button "Send"' SNAP | head -1 | sed -n 's/.*ref=\([^]]*\).*/\1/p')
playwright-cli -s=insta click $SEND_REF
# Instagram volta pro feed automaticamente após enviar
```

#### Gravação de tela (pra vídeos)
```bash
# Gravar tela enquanto stories passam (sem áudio)
playwright-cli -s=insta video-start
# ... navegar pelos stories ...
playwright-cli -s=insta video-stop
# Arquivo: .playwright-cli/video-*.webm

# Extrair frames-chave com ffmpeg
ffmpeg -y -i .playwright-cli/video-*.webm -vf "fps=1/3" /tmp/frame_%02d.png
# Ler cada frame como imagem pra entender contexto visual
```

#### Problemas comuns
- **Refs ficam stale rápido** — stories avançam automaticamente. Sempre tirar snapshot novo antes de cada ação.
- **Vídeos usam blob URL** — não dá pra baixar direto. Usar screenshot ou gravação de tela.
- **"View as pbuilders.ai?"** — aparece toda vez que abre stories de outra conta. Clicar "View story".
- **Story avança ao interagir** — se clicar Like e story avançar, os refs antigos ficam inválidos. Tirar novo snapshot.
- **URL direta de story** — `https://www.instagram.com/stories/USUARIO/STORY_ID/` funciona mas sempre começa do primeiro story se ID expirou.

---

## Padrão de uso

Todo comando segue o mesmo ciclo:

```
goto → snapshot → identificar ref → ação (click/fill) → snapshot pra verificar
```

O snapshot é um YAML leve (texto puro, não screenshot). Ele retorna a árvore de elementos da página com refs que podem ser usados nos comandos de ação.

## Tratamento de erros

### "subtree intercepts pointer events"
Instagram tem overlays/popups que bloqueiam cliques. Soluções:
1. Fechar o popup primeiro (procurar "Not Now", "Close", "X" no snapshot)
2. Scrollar a página: `playwright-cli -s=insta eval "window.scrollBy(0, 300)"`
3. Usar `eval` pra esconder overlay: `playwright-cli -s=insta eval "document.querySelector('[role=dialog]').remove()"`

### "element not found"
O Instagram carrega elementos dinamicamente. Soluções:
1. Esperar: `sleep 2` antes do snapshot
2. Scrollar pra carregar mais: `playwright-cli -s=insta eval "window.scrollBy(0, 500)"`
3. Recarregar: `playwright-cli -s=insta reload`

### Bloqueio por rate limit
- Max 20 follows por hora
- Max 100 follows por dia
- Esperar 3-5 segundos entre cada ação
- Se bloqueado, parar por 24h

### Sessão expirou
```bash
# Fechar e reabrir com login
playwright-cli -s=insta close
playwright-cli -s=insta open --persistent --headed https://www.instagram.com/
# Logar manualmente de novo
```

---

## Segurança

- NUNCA commitar `.env` ou credenciais
- NUNCA usar `--headless` antes de ter sessão salva
- NUNCA ultrapassar rate limits do Instagram
- Sessões ficam em `~/.cache/ms-playwright/daemon/` (local, não vai pro git)
- `.playwright-cli/` está no `.gitignore`
