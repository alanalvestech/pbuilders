# PBuilders Content — Guia Unificado

## Regras Gerais

**Nunca usar em dash (—) em nenhum conteúdo.** Nem em captions, nem em copy, nem em slides, nem em textos de WhatsApp. Usar vírgula, ponto ou reescrever a frase.

**Nunca usar `<br>` em textos de parágrafo nos HTMLs.** Quebras forçadas criam layouts quebrados dependendo do tamanho do texto. Deixar o texto fluir naturalmente e ajustar o tamanho da fonte ou o `max-width` do container se necessário.

**Headlines com `<br>` devem usar no máximo 2 linhas — nunca criar órfãs.** Ao adicionar quebras manuais em títulos, verificar se a última palavra não ficou sozinha numa terceira linha. Exemplo errado: `a AWS dos<br>agentes` quando "agentes" cabe na linha anterior. Regra: cada linha deve ter peso visual equivalente. Se uma quebra gera uma linha com 1-2 palavras sozinhas que caberiam na linha anterior, remover o `<br>`.

**Sublines e textos de apoio devem ser diretos — no máximo 1 linha.** Subline do hook serve como complemento imediato do título, não como descrição completa. Preferir frases curtas tipo "Nova plataforma da Anthropic" a frases longas que quebram em 2 linhas.

**Títulos e headlines sempre em branco (`#F0F0F0` ou `#FFFFFF`).** Nunca usar cinza escuro em texto de headline — dificulta a leitura. Cinza só para textos de apoio, labels e eyebrows.

**Texto de corpo deve ter contraste legível.** Fundo `#0A0A0A`: usar no mínimo `#888` para parágrafos e `#777` para texto secundário. Cores como `#555` ou `#4A4A4A` são ilegíveis nesse fundo — contraste abaixo de 3:1.

**Acentuação sempre correta nos HTMLs.** Escrever diretamente em UTF-8 com acentos completos: não, não; padrão, não padrao; coordenação, não coordenacao. Não depender de encoding automático.

**Headlines de carrossel não levam ponto final.** Títulos grandes não precisam de pontuação — o peso visual já encerra a frase.

**Todo tema com carrossel deve ter um `whatsapp-cover.png`.** É a imagem enviada junto com o post no WhatsApp. Deve ser **sempre quadrada (1080×1080)** — imagens mais altas são clipadas pelo WhatsApp e o usuário precisa abrir pra ver o conteúdo. Criar sempre um `whatsapp-cover.html` dedicado com `height: 1080px` e renderizar separado com `render.py`.

---

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
- [ ] Link do Instagram formatado como `Saiba mais: (link)` — nunca link solto

---

## Instagram

### Contexto

Instagram é feed público. Diferente do WhatsApp:
- Sem limite de caracteres visível, mas atenção cai após 3 linhas
- Imagem/carrossel > texto puro
- Stories: efêmero, mais pessoal e direto. Seguir a mesma lógica narrativa do carrossel — cada slide tem headline contextual + corpo explicativo. Nunca slides com frases ou números soltos sem contexto. Cada slide deve fazer sentido sozinho.
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

### Regra obrigatória: último slide sempre é CTA

Todo carrossel e toda sequência de stories **deve terminar com um slide de CTA** direcionando para a comunidade. Sem exceção.

O slide de CTA deve conter:
- Handle: `@pbuilders`
- URL: `pbuilders.ai`
- Chamada para ação clara ("Venha construir.", "É aqui.", etc.)
- Direcionamento explícito para a comunidade no WhatsApp: **"Entre na comunidade — link na bio"**

Nunca terminar num slide de conteúdo. O último contato visual do usuário com o post é o CTA.

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

## Especificações de Imagem por Formato

Referência para evitar imagens com dimensões erradas.

| Formato | Dimensões | Proporção | Obs |
|---|---|---|---|
| Feed quadrado | 1080 × 1080 px | 1:1 | Menor alcance |
| Feed retrato ✅ | 1080 × 1350 px | 4:5 | Recomendado pelo Instagram em 2026 |
| Feed paisagem | 1080 × 566 px | 1.91:1 | Evitar — corta no grid |
| Carrossel (cada slide) | 1080 × 1350 px | 4:5 | Primeiro slide define proporção dos demais |
| Stories / Reels | 1080 × 1920 px | 9:16 | Safe zone: margem de 250px top/bottom pra UI |
| Foto de perfil | 320 × 320 px | 1:1 | |

**Regra geral:** sempre exportar com 1080px de largura. Instagram comprime se for maior, degrada se for menor.

**Stories:** manter texto e elementos interativos dentro do safe zone (y: 250px → 1670px).

### Tamanhos mínimos de fonte para legibilidade no mobile

Instagram exibe a imagem em ~390px de largura no iPhone (escala ~0.36×). Uma fonte de 13px na imagem aparece como ~5px na tela — ilegível.

| Uso | Tamanho mínimo na imagem |
|---|---|
| Eyebrows / labels / tags | 17–20px |
| Texto de apoio (secundário) | 24–28px |
| Corpo principal | 28–32px |
| Títulos / headlines | livre (já são grandes) |

Regra prática: **nada abaixo de 17px** nos HTMLs. Se parecer pequeno no browser em 1080px, vai ser ilegível no celular.

---

## render.py

Converte HTML com slides `.slide` em PNG(s). Passa o arquivo HTML diretamente:

```bash
# Imagem única (img.html → img.png)
python3 content/render.py content/2026-04-01-sequoia-services/img.html

# Carrossel (7 slides → instagram-carousel-01.png ... 07.png)
python3 content/render.py content/2026-04-01-sequoia-services/instagram-carousel.html

# Stories (4 slides → instagram-stories-01.png ... 04.png)
python3 content/render.py content/2026-04-01-sequoia-services/instagram-stories.html
```
