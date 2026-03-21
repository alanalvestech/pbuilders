---
name: insta
description: Automação do Instagram @pbuilders.ai — login, seguir, unfollow, postar, DM, curtir, stories, perfil. Usar quando o usuário pedir qualquer operação no Instagram.
disable-model-invocation: true
argument-hint: "[login|follow|unfollow|post|dm|like|stories|bio|notifications|profile] [args...]"
allowed-tools: Bash, Read, Grep, Glob
---

# Instagram Ops — Skill de Automação

Conta: **@pbuilders.ai**
Ferramenta: `playwright-cli` com sessão persistente `-s=insta`
Scripts: `.claude/skills/insta/scripts/`

## Comandos

Todos os scripts usam `_helpers.sh` com funções compartilhadas (snapshot, get_ref, navegação, popups).

### `/insta login`
```bash
bash .claude/skills/insta/scripts/login.sh
```
Login via Keychain + Touch ID. Verifica se já logado antes de pedir credenciais.

### `/insta follow @usuario1 @usuario2 ...`
```bash
bash .claude/skills/insta/scripts/follow.sh follow usuario1 usuario2
```

### `/insta unfollow @usuario`
```bash
bash .claude/skills/insta/scripts/follow.sh unfollow usuario
```

### `/insta check @usuario`
```bash
bash .claude/skills/insta/scripts/follow.sh check usuario
```

### `/insta dm @usuario "mensagem"`
```bash
bash .claude/skills/insta/scripts/dm.sh usuario "mensagem aqui"
```
**PEDIR CONFIRMAÇÃO ao usuário antes de executar.**

### `/insta like /p/CODIGO`
```bash
bash .claude/skills/insta/scripts/like.sh /p/CODIGO/
```

### `/insta post /caminho/imagem.jpg "caption"`
```bash
bash .claude/skills/insta/scripts/post.sh /caminho/imagem.jpg "caption aqui"
```
**PEDIR CONFIRMAÇÃO ao usuário antes de executar.**

### `/insta stories @usuario`
Fluxo em 2 fases:

**Fase 1 — Coleta:**
```bash
bash .claude/skills/insta/scripts/stories.sh usuario
```
Retorna JSON + screenshots em `/tmp/insta-stories-PID/`.

**Fase 2 — Interação (agente):**
1. Ler screenshots pra entender contexto visual completo
2. Selecionar **no máximo 3** stories pra interagir
3. Para cada story:
```bash
bash .claude/skills/insta/scripts/story-reply.sh usuario "pattern_alt_text" "mensagem"
```

**Regras de stories:**
- **SEMPRE curtir antes de comentar**
- **Máximo 3 replies por usuário**
- Replies devem demonstrar conhecimento real do conteúdo
- Escolher stories relevantes pra PBuilders (IA, tech, eventos, Paraíba)

### `/insta bio "novo texto"`
```bash
bash .claude/skills/insta/scripts/bio.sh "novo texto da bio"
```
**PEDIR CONFIRMAÇÃO ao usuário antes de executar.**

### `/insta notifications`
```bash
bash .claude/skills/insta/scripts/notifications.sh
```

### `/insta profile @usuario`
```bash
bash .claude/skills/insta/scripts/profile.sh usuario
```
Retorna dados do perfil + screenshot em `/tmp/profile_usuario.png`.

## Scripts

| Script | Responsabilidade |
|---|---|
| `_helpers.sh` | Funções compartilhadas (snapshot, get_ref, navegação, popups, rate limit) |
| `keychain.sh` | CRUD de credenciais no macOS Keychain (Touch ID) |
| `login.sh` | Login automático no Instagram |
| `follow.sh` | Follow, unfollow e check de contas |
| `dm.sh` | Envio de DMs |
| `like.sh` | Curtir posts |
| `post.sh` | Publicar posts com imagem e caption |
| `stories.sh` | Coletar dados e screenshots de stories |
| `story-reply.sh` | Curtir e responder um story específico |
| `bio.sh` | Editar bio do perfil |
| `notifications.sh` | Ler notificações |
| `profile.sh` | Analisar perfil de um usuário |

## Padrão de operação

Todo script segue o ciclo:
```
goto → sleep → snapshot → get_ref → ação → snapshot verificação
```

Helpers disponíveis em `_helpers.sh`:
- `insta_snapshot` — tira snapshot, retorna path do YAML
- `insta_goto URL` — navega pra URL
- `insta_click REF` — clica num elemento
- `insta_fill REF TEXT` — preenche campo
- `insta_screenshot` — tira screenshot, retorna path do PNG
- `get_button_ref NAME SNAP` — extrai ref de botão pelo nome
- `get_textbox_ref NAME SNAP` — extrai ref de textbox pelo nome
- `dismiss_popups` — fecha "Not Now", "Close" e similares
- `is_logged_in` — verifica se está logado
- `ensure_session` — garante sessão ativa
- `rate_limit_wait [seconds]` — espera entre ações

## Problemas conhecidos

- **Refs ficam stale** — Instagram muda o DOM frequentemente. Sempre tirar snapshot novo antes de cada ação.
- **Stories avançam automaticamente** — agir rápido ou pausar.
- **Vídeos usam blob URL** — não dá pra baixar direto. Usar screenshots.
- **Sem áudio na gravação** — `video-start/stop` grava só tela.
- **Alt-text no img** — Instagram gera descrições automáticas: `img "Photo by..."`, `img "May be..."`.
- **Popups** — "Not Now", "Turn on Notifications", "Save login info" bloqueiam ações. `dismiss_popups` resolve.
- **Gravação de tela** pra vídeos:
```bash
playwright-cli -s=insta video-start
# ... navegar ...
playwright-cli -s=insta video-stop
ffmpeg -y -i .playwright-cli/video-*.webm -vf "fps=1/3" /tmp/frame_%02d.png
```

## Rate Limits

- Max **20 follows por hora**
- Max **100 follows por dia**
- Esperar **3-5 segundos** entre cada ação
- Se bloqueado → parar por 24h

## Segurança

- Credenciais no **macOS Keychain** com Touch ID obrigatório
- NUNCA exibir senhas no output
- NUNCA ultrapassar rate limits
- `.playwright-cli/` está no `.gitignore`
- Antes de enviar mensagens, postar ou alterar perfil → **sempre pedir confirmação**
