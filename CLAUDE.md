# PBuilders

Comunidade presencial de builders de IA em Campina Grande/PB. O "PB" de Paraíba tá embutido no nome.

## Estrutura

```
pbuilders/
├── CLAUDE.md              # Este arquivo
├── brand.md               # Identidade, voz, tom, visual
├── content/
│   ├── strategy.md        # Regras de conteúdo
│   └── posts/             # Postagens
├── eventos/
│   └── primeiro.md        # Planejamento do kickoff
├── growth/
│   ├── comunidades.md     # Mapeamento de comunidades na PB
│   └── pessoas.md         # Stakeholders e pessoas-chave
└── site/                  # Código do site (deploy automático)
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

## Contexto

- Antes de escrever qualquer texto público (posts, bio, copy), consultar `brand.md`
- Antes de planejar eventos, consultar `eventos/`
- Antes de estratégia de crescimento, consultar `growth/`
- Antes de criar conteúdo, consultar `content/strategy.md`
