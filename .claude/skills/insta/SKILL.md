---
name: insta
description: Automação do Instagram @pbuilders.ai — login, seguir, unfollow, postar, DM, curtir, stories, perfil, download de mídia. Usar quando o usuário pedir qualquer operação no Instagram.
disable-model-invocation: true
argument-hint: "[login|follow|unfollow|post|dm|like|stories|bio|notifications|profile|media] [args...]"
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

### `/insta media <url|stories|highlights|profile> [args]`
Baixa mídias do Instagram via `instaloader`.
```bash
# Post ou reel individual
bash .claude/skills/insta/scripts/media.sh https://www.instagram.com/p/ABC123/

# Stories de um usuário
bash .claude/skills/insta/scripts/media.sh stories usuario

# Highlights de um usuário
bash .claude/skills/insta/scripts/media.sh highlights usuario

# Todos os posts de um perfil
bash .claude/skills/insta/scripts/media.sh profile usuario

# Com diretório customizado
bash .claude/skills/insta/scripts/media.sh stories usuario /tmp/meus-downloads
```
Requer `instaloader` (`pip install instaloader`). Login: `instaloader --login=pbuilders.ai`.

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
| `media.sh` | Baixar mídias (fotos, vídeos, stories, highlights) via instaloader |
| `log.sh` | CRM/logging — registra conversas, follows, perfis e busca histórico |

### `/insta log <comando> [args]`
Sistema de CRM que registra todas as interações do Tank.

```bash
# Registrar mensagem (DM, story reply, etc)
bash .claude/skills/insta/scripts/log.sh conversation usuario sent dm "mensagem"
bash .claude/skills/insta/scripts/log.sh conversation usuario sent story_reply "mensagem"
bash .claude/skills/insta/scripts/log.sh conversation usuario sent story_like "Curtiu story"
bash .claude/skills/insta/scripts/log.sh conversation usuario received dm "resposta"

# Registrar follow/unfollow
bash .claude/skills/insta/scripts/log.sh follow usuario [manual|auto|reciprocal] ["notas"]
bash .claude/skills/insta/scripts/log.sh unfollow usuario

# Registrar visita (atualiza última visita no following.csv)
bash .claude/skills/insta/scripts/log.sh visit usuario story
bash .claude/skills/insta/scripts/log.sh visit usuario profile
bash .claude/skills/insta/scripts/log.sh visit usuario chat

# Atualizar perfil
bash .claude/skills/insta/scripts/log.sh profile usuario "Nome" "Valor"

# Consultar dados
bash .claude/skills/insta/scripts/log.sh read usuario
bash .claude/skills/insta/scripts/log.sh list-following
bash .claude/skills/insta/scripts/log.sh list-conversations
bash .claude/skills/insta/scripts/log.sh search "termo"
```

**Dados em:** `.claude/skills/insta/data/`
- `conversations/*.csv` — histórico por pessoa
- `profiles/*.md` — análise de perfil por pessoa
- `following.csv` — lista de quem segue + últimas visitas (story, profile, chat)

**Integrado automaticamente em:** `dm.sh`, `follow.sh`, `story-reply.sh` — logam cada ação.

## Ritual de novo follow

Ao seguir uma pessoa nova, SEMPRE executar este fluxo completo na ordem:

1. **Seguir** — `follow.sh follow usuario`
2. **Criar perfil no CRM** — `log.sh profile usuario`
3. **Analisar perfil** — `profile.sh usuario`
   - Ler bio e anotar no perfil MD (profissão, área, localização)
   - Se perfil **aberto**: analisar os **últimos 6 posts** (alt-text + screenshots) pra entender interesses e estilo
   - Se perfil **fechado**: anotar só o que a bio revela
4. **Stories** (se tiver e perfil aberto):
   - Coletar stories — `stories.sh usuario`
   - Selecionar os **1-3 mais relevantes** pra PBuilders (IA, tech, eventos, PB)
   - **Curtir** cada story selecionado
   - **Comentar** cada story com reply contextualizado
5. **DM de boas-vindas**:
   - Compor mensagem personalizada baseada em:
     - Tudo que aprendeu do perfil (bio, posts, stories)
     - Comentários que fez nos stories
     - Conexão com a PBuilders
   - Apresentar como **Tank** (agente principal da PBuilders)
   - Apresentar a **PBuilders.ai** (comunidade de builders de IA na PB)
   - Tom: informal, direto, entusiasmado mas não forçado
   - `dm.sh usuario "mensagem"`

**Importante:**
- A DM deve ser a ÚLTIMA ação — depois de já ter curtido e comentado
- Isso garante que quando a pessoa ler a DM, já viu as interações nos stories
- Toda ação é logada automaticamente no CRM

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
