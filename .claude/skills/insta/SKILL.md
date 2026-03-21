---
name: insta
description: Automação do Instagram @pbuilders.ai — login, seguir, unfollow, postar, DM, curtir, stories. Usar quando o usuário pedir qualquer operação no Instagram.
disable-model-invocation: true
argument-hint: "[login|follow|unfollow|post|dm|like|bio|notifications|stories] [args...]"
allowed-tools: Bash, Read, Grep, Glob
---

# Instagram Ops — Skill de Automação

Conta: **@pbuilders.ai**
Ferramenta: `playwright-cli` com sessão persistente `-s=insta`

## Comandos

### `/insta login`
Faz login no Instagram via Keychain + Touch ID.

1. Verificar se já tem sessão ativa:
```bash
playwright-cli -s=insta goto https://www.instagram.com/ 2>&1
```
2. Fazer snapshot e verificar se aparece "Home" ou "Reels" (= já logado)
3. Se não logado, recuperar credenciais do Keychain (pede Touch ID do usuário):
```bash
INSTA_USER=$(bash scripts/insta-keychain.sh get-user)
INSTA_PASS=$(bash scripts/insta-keychain.sh get-pass)
```
4. Abrir browser persistente se não estiver aberto:
```bash
playwright-cli -s=insta open --persistent
```
5. Navegar pra página de login e preencher:
```bash
playwright-cli -s=insta goto https://www.instagram.com/accounts/login/
sleep 2
playwright-cli -s=insta snapshot  # encontrar refs dos campos
playwright-cli -s=insta fill REF_USER "$INSTA_USER"
playwright-cli -s=insta fill REF_PASS "$INSTA_PASS"
unset INSTA_USER INSTA_PASS  # limpar imediatamente
playwright-cli -s=insta click REF_LOGIN
```
6. Tratar popup "Save login info" → clicar "Not now"
7. Verificar sucesso com snapshot

**SEGURANÇA:**
- NUNCA exibir a senha no output — usar `2>/dev/null` nos comandos fill
- NUNCA logar credenciais — `unset` imediatamente após uso
- O Keychain pede Touch ID — sem biometria, sem acesso

### `/insta follow @usuario` ou `/insta follow usuario1 usuario2 ...`
Segue uma ou mais contas.

Para cada conta:
1. `playwright-cli -s=insta goto https://www.instagram.com/USUARIO/`
2. `sleep 2`
3. Fazer snapshot, encontrar botão com grep:
```bash
SNAP=$(playwright-cli -s=insta snapshot 2>&1 | grep "Snapshot" | tail -1 | sed 's/.*(\(.*\))/\1/')
```
4. Verificar estado:
   - Se `button "Following"` → já segue, pular
   - Se `button "Follow"` → extrair ref e clicar
5. Esperar 3-5 segundos antes da próxima conta (rate limit)

**Validação:** Após seguir, verificar que o botão mudou para "Following".

### `/insta unfollow @usuario`
Deixa de seguir uma conta.

1. Navegar pro perfil
2. Snapshot → encontrar `button "Following"`
3. Clicar no botão Following → abre menu
4. Snapshot → encontrar `button "Unfollow"`
5. Clicar em Unfollow

### `/insta post /caminho/imagem.jpg "caption aqui"`
Publica um post com imagem e legenda.

1. Navegar pra home
2. Clicar no botão "New post"
3. Upload da imagem
4. Avançar etapas (Next)
5. Preencher caption
6. **PEDIR CONFIRMAÇÃO ao usuário antes de clicar Share**

### `/insta dm @usuario "mensagem"`
Envia DM para um usuário.

1. Navegar pra `/direct/inbox/`
2. Clicar no botão de nova mensagem
3. Buscar usuário
4. Selecionar e abrir chat
5. Preencher mensagem
6. **PEDIR CONFIRMAÇÃO ao usuário antes de enviar**

### `/insta like /p/CODIGO`
Curte um post específico.

1. Navegar pro post
2. Snapshot → encontrar botão de like
3. Clicar

### `/insta bio "novo texto da bio"`
Edita a bio do perfil.

1. Navegar pra `/accounts/edit/`
2. Snapshot → encontrar textarea da bio
3. Preencher com novo texto
4. **PEDIR CONFIRMAÇÃO ao usuário antes de salvar**

### `/insta stories @usuario`
Vê, curte e responde stories de um usuário.

**Regras:**
- **SEMPRE curtir (like) antes de comentar** — nunca comentar sem curtir
- **Máximo 3 replies por usuário** — pra não ser spam
- Escolher os stories mais relevantes pra PBuilders (IA, tech, eventos, Paraíba)
- Replies devem demonstrar conhecimento real do conteúdo do story

**Fluxo em 2 fases:**

#### Fase 1 — Coleta (script automatizado)
```bash
bash scripts/insta-stories.sh USUARIO
```
O script:
1. Abre stories e aceita prompt "View as pbuilders.ai?"
2. Percorre todos os stories extraindo: alt-text, tipo (imagem/vídeo/reel), tempo, screenshot
3. Retorna JSON com dados de cada story + screenshots em `/tmp/insta-stories-PID/`

#### Fase 2 — Análise e interação (agente)
1. **Ler screenshots** dos stories pra entender o contexto visual completo
2. **Selecionar no máximo 3** stories mais relevantes pra interagir
3. Para cada story selecionado, navegar pela URL direta:
```bash
playwright-cli -s=insta goto "https://www.instagram.com/stories/USUARIO/"
```
4. Aceitar "View story" se aparecer
5. Avançar até o story alvo (usar loop com grep no alt-text pra localizar)
6. **CURTIR** primeiro:
```bash
# Snapshot → encontrar Like ref → clicar
SNAP=$(ls -t .playwright-cli/*.yml | head -1)
LIKE=$(cat "$SNAP" | grep 'button "Like"' | head -1 | sed -n 's/.*ref=\([^]]*\).*/\1/p')
playwright-cli -s=insta click "$LIKE"
```
7. **RESPONDER** depois:
```bash
# Snapshot → encontrar textbox → fill → send
SNAP=$(ls -t .playwright-cli/*.yml | head -1)
REPLY=$(cat "$SNAP" | grep "textbox" | head -1 | sed -n 's/.*ref=\([^]]*\).*/\1/p')
playwright-cli -s=insta fill "$REPLY" "mensagem aqui"
# Snapshot → Send
SNAP=$(ls -t .playwright-cli/*.yml | head -1)
SEND=$(cat "$SNAP" | grep 'button "Send"' | head -1 | sed -n 's/.*ref=\([^]]*\).*/\1/p')
playwright-cli -s=insta click "$SEND"
```

**Problemas conhecidos e soluções:**
- **Stories avançam automaticamente** — refs ficam stale rápido. Sempre tirar snapshot novo antes de cada ação.
- **Blob URLs** — vídeos usam blob:, não dá pra baixar direto. Usar screenshots pra contexto visual.
- **Sem áudio na gravação** — `video-start/stop` grava só tela. Pra vídeos falados, screenshots + alt-text são a melhor opção.
- **Alt-text no img** — Instagram gera descrições automáticas nas tags `img "Photo by..."` ou `img "May be..."`. Usar como filtro pra encontrar stories por conteúdo.
- **Gravação de tela** — pra capturar stories de vídeo:
```bash
playwright-cli -s=insta video-start
# ... navegar pelos stories ...
playwright-cli -s=insta video-stop
# Extrair frames com ffmpeg:
ffmpeg -y -i .playwright-cli/video-*.webm -vf "fps=1/3" /tmp/story_frame_%02d.png
```

**PEDIR CONFIRMAÇÃO ao usuário** antes de enviar cada reply.

### `/insta notifications`
Lê as notificações recentes.

1. Navegar pra home
2. Clicar no ícone de notificações
3. Snapshot → ler conteúdo

## Padrão de operação

Todo comando segue o ciclo:
```
goto → sleep 2 → snapshot → grep ref → ação → snapshot verificação
```

Para encontrar refs nos snapshots:
```bash
SNAP=$(playwright-cli -s=insta snapshot 2>&1 | grep "Snapshot" | tail -1 | sed 's/.*(\(.*\))/\1/')
grep -i "TERMO" "$SNAP" | head -N
REF=$(grep ... | sed -n 's/.*ref=\([^]]*\).*/\1/p')
```

## Rate Limits

- Max **20 follows por hora**
- Max **100 follows por dia**
- Esperar **3-5 segundos** entre cada ação
- Se bloqueado → parar por 24h

## Tratamento de erros

- **Popup bloqueando:** procurar "Not Now", "Close", "X" no snapshot e fechar
- **Elemento não encontrado:** `sleep 2` + novo snapshot
- **Sessão expirada:** rodar `/insta login` de novo
- **Page Title "Page not found":** conta não existe, pular

## Segurança

- Credenciais ficam no **macOS Keychain** com Touch ID obrigatório
- NUNCA ler `.env` diretamente
- NUNCA exibir senhas no output
- NUNCA ultrapassar rate limits
- Sessões persistentes ficam em `~/Library/Caches/ms-playwright/daemon/`
- `.playwright-cli/` está no `.gitignore`
- Antes de enviar mensagens, postar ou alterar perfil → **sempre pedir confirmação**

## Referências

- Playbook detalhado: [agents/instagram-ops.md](../../../agents/instagram-ops.md)
- Script de login: [scripts/insta-login.sh](../../../scripts/insta-login.sh)
- Script de keychain: [scripts/insta-keychain.sh](../../../scripts/insta-keychain.sh)
- Script de stories: [scripts/insta-stories.sh](../../../scripts/insta-stories.sh)
- Comunidades mapeadas: [growth/comunidades.md](../../../growth/comunidades.md)
