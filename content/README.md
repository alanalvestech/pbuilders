# PBuilders Content — Guia Unificado

## Estrutura

Cada tema/assunto tem uma pasta `YYYY-MM-DD-slug/`. O mesmo conteúdo que gera posts para múltiplos canais fica junto na mesma pasta.

```
content/
  README.md
  render.py
  2026-03-24-ia-google/
    whatsapp.md
  2026-03-30-parcerias/
    whatsapp.md
    instagram-caption-carlos-rueda.md
    instagram-parceria-carlos-rueda.html
    instagram-parceria-carlos-rueda.png
    ...
```

### Convenções de nome
- **Pasta**: `YYYY-MM-DD-slug/` — uma pasta por tema
- **Prefixo do canal**: `whatsapp.md`, `instagram-caption.md`, `instagram-carousel.html`
- **Imagens compartilhadas**: sem prefixo (`img.html`, `img.png`)

---

## WhatsApp

### Contexto

WhatsApp é grupo fechado, comunidade. Não é feed público.
Diferenças fundamentais de LinkedIn/X:
- WhatsApp corta mensagens com mais de ~500 caracteres com "ver mais". Todo post DEVE ter no máximo 500 caracteres pra pessoa ler de uma vez, sem clicar
- Tom mais íntimo, como conversa entre conhecidos
- Post longo demais = ignorado (não é artigo)
- Pode mandar mídia direto (imagem, vídeo, link)
- Notificação push — cada post interrompe. Respeitar isso.

### Tom e Voz

Seguir `brand.md` como base, com ajustes pro WhatsApp:

#### Fazer
- Falar como se tivesse no grupo de amigos que constroem coisas
- "A galera", "o bizu", linguagem natural
- Compartilhar o que tá construindo de verdade (demo, print, resultado)
- Perguntar pro grupo — puxar conversa, não só broadcast
- Celebrar quem faz. Dar palco pra quem mostrou algo
- Ser direto: uma ideia por mensagem

#### NÃO fazer
- Tom institucional ("Prezados membros da comunidade...")
- Mensagem genérica de IA copiada ("5 dicas para...")
- Emoji wall (🚀🔥💡🎯 — não)
- Post enorme com 10 parágrafos
- Falar sobre IA sem conexão com PB ou com algo real
- Spam de link sem contexto

#### Palavras banidas (marcadores de IA)
- "a sacada é", "o segredo é", "o ponto-chave é"
- "vale ouro", "isso é ouro puro", "pulo do gato"
- brutal, massive, crucial, robust, pivotal, vibrant
- "em conclusão", "é importante notar", "aprofundar"
- "Cara," (não é vocabulário do Alan)
- Em dash (—) como estilo recorrente

### Formato

**Limite absoluto: 500 caracteres**

Estrutura padrão:
```
[Hook — primeira linha que prende]

[Corpo — contexto, o que rolou, o que aprendeu]

[Fechamento — pergunta ou call-to-action pro grupo]
```

### Tipos de Post

1. **Compartilhar build** — print, demo, resultado
2. **Curadoria** — ferramenta, artigo, vídeo útil pro grupo
3. **Pergunta/discussão** — puxar conversa sobre tema relevante
4. **Evento/anúncio** — próximo encontro, speaker confirmado
5. **Recap** — highlights do último evento
6. **Spotlight** — destacar algo que alguém do grupo fez

### Frequência

- 2-4 posts por semana no máximo
- Melhor horário: manhã (8-10h) ou noite (19-21h) em dia de semana

### Frontmatter

```yaml
---
type: build | curadoria | discussao | evento | recap | spotlight
canal: whatsapp
---
```

### Checklist antes de enviar

- [ ] Primeira linha prende?
- [ ] Tamanho ok? (máx 500 caracteres)
- [ ] Tom tá natural? (não parece newsletter)
- [ ] Não tem palavra banida?
- [ ] Mídia anexada se necessário?

---

## Instagram

### Contexto

Instagram é feed público. Diferente do WhatsApp:
- Sem limite de caracteres visível, mas atenção cai após 3 linhas
- Imagem/carrossel > texto puro
- Stories: efêmero, mais pessoal e direto
- Caption serve de complemento, não de conteúdo principal

### Tom e Voz

Seguir `brand.md` como base. No Instagram:
- Primeira linha da caption é o hook — aparece no feed antes do "ver mais"
- Tom visual primeiro: a imagem/carrossel precisa funcionar sozinha
- Hashtags no fim, nunca no meio do texto

### Tipos de Post

1. **Carrossel** — tutoriais, curadoria visual, recaps de evento
2. **Post único** — anúncio, quote, print de resultado
3. **Stories** — bastidores, votações, perguntas pro público, reposts
4. **Reels** — demos curtas (< 60s), highlights de eventos

### Carrosséis

Templates HTML na pasta do tema. Exportar como PNG antes de publicar usando `render.py`.
Usar a skill `/insta post` para publicar.

### Frequência

- 3-5 posts/semana no feed
- Stories: diário quando houver conteúdo real
- Qualidade > quantidade

### Frontmatter

```yaml
---
type: carrossel | post | story | reel
canal: instagram
---
```

---

## render.py

Converte `img.html` de uma pasta em `img.png` (1080x1080px):

```bash
python3 content/render.py content/2026-04-01-sequoia-services
```
