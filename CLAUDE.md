# PBuilders

Comunidade presencial de builders de IA em Campina Grande/PB. O "PB" de Paraíba tá embutido no nome.

## Estrutura

```
pbuilders/
├── CLAUDE.md                    # Este arquivo
├── .claude/skills/insta/        # Skill /insta (automação Instagram)
│   ├── SKILL.md                 # Documento da skill
│   └── scripts/                 # Scripts bash modulares
│       ├── _helpers.sh          # Funções compartilhadas
│       ├── keychain.sh          # Credenciais via Keychain + Touch ID
│       ├── login.sh             # Login automático
│       ├── follow.sh            # Follow / unfollow / check
│       ├── dm.sh                # Enviar DMs
│       ├── like.sh              # Curtir posts
│       ├── post.sh              # Publicar posts
│       ├── stories.sh           # Coletar dados de stories
│       ├── story-reply.sh       # Curtir e responder stories
│       ├── bio.sh               # Editar bio
│       ├── notifications.sh     # Ler notificações
│       └── profile.sh           # Analisar perfil de usuário
├── agents/
│   └── bia-copywriter.md        # Persona: Head de Copy & Social Media
├── brand.md                     # Identidade, voz, tom, visual
├── content/
│   ├── whatsapp/                # Posts e strategy do grupo WhatsApp
│   │   ├── strategy.md
│   │   └── YYYY-MM-DD-slug.md
│   └── instagram/               # Posts e strategy do Instagram
│       ├── strategy.md
│       ├── YYYY-MM-DD-slug.md
│       └── carousels/           # Templates HTML de carrosséis
├── eventos/
│   └── primeiro.md              # Planejamento do kickoff
├── growth/
│   ├── comunidades.md           # Mapeamento de comunidades na PB
│   └── pessoas.md               # Stakeholders e pessoas-chave
└── site/                        # Código do site (deploy automático)
    ├── index.html
    ├── wrangler.toml
    └── assets (favicons, logo, og-image)
```

## Estratégia

PBuilders é o canal principal de conteúdo e marca do Alan.

Funil:
1. **PBuilders** (comunidade grátis) → audiência e autoridade
2. **Workshops** (eventos pagos na comunidade) → receita direta
3. **Consultoria** → networking dos encontros

## Presença Digital

| Canal | Handle | Uso |
|---|---|---|
| Site | pbuilders.ai | Landing page, inscrições |
| Instagram | @pbuilders.ai | Conteúdo, eventos, recaps |
| Email | pbuildersai@gmail.com | Contato |
| WhatsApp | Grupo da comunidade | Comunicação direta |

## Deploy

- Deploy automático via GitHub Actions ao fazer push na main
- Hospedagem: Cloudflare Pages (projeto: pbuildersai)
- Domínio: pbuilders.ai
- Código do site em `site/`

## Workflow

- Sempre fazer commit e push automaticamente após mudanças no código
- Mensagens de commit em português
- Antes de criar conteúdo ou textos públicos, ler `brand.md` (voz, tom, palavras banidas)

## Agents (Personas)

Personas especializadas em `agents/`. Cada arquivo define uma persona com prompt base, frameworks e princípios. Ao precisar de copy, conteúdo ou textos de marketing, invocar a persona como agente seguindo o prompt base do arquivo.

- **Bia** (`agents/bia-copywriter.md`) — Copy & Social Media. Usar pra bios, captions, posts, qualquer texto público.

## Operações Instagram

Skill `/insta` em `.claude/skills/insta/`. Cada operação tem um script bash dedicado em `scripts/`.

Comandos: `/insta login`, `/insta follow`, `/insta unfollow`, `/insta check`, `/insta post`, `/insta dm`, `/insta like`, `/insta stories`, `/insta bio`, `/insta notifications`, `/insta profile`.

Credenciais no macOS Keychain com Touch ID. Scripts usam `playwright-cli -s=insta`.

## Restrições de Marca

- **NUNCA** mencionar "PTHI" (Parque Tecnológico Horizontes de Inovação) em nenhum material público (site, posts, copy, bio) sem aprovação explícita do Alan. O nome pode existir em docs internos (growth/, eventos/) como referência, mas não sai pro público.

## Contexto

- Antes de escrever qualquer texto público (posts, bio, copy), consultar `brand.md` e invocar a Bia (`agents/bia-copywriter.md`)
- Antes de planejar eventos, consultar `eventos/`
- Antes de estratégia de crescimento, consultar `growth/`
- Antes de criar conteúdo WhatsApp, consultar `content/whatsapp/strategy.md`
- Antes de criar conteúdo Instagram, consultar `content/instagram/strategy.md`
- Posts salvos em `content/whatsapp/` ou `content/instagram/` conforme o canal
