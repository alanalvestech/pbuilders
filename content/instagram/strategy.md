# PBuilders Instagram — Guia de Conteúdo

## Contexto

Instagram é feed público. Diferente do WhatsApp:
- Sem limite de caracteres visível, mas atenção cai após 3 linhas
- Imagem/carrossel > texto puro
- Stories: efêmero, mais pessoal e direto
- Caption serve de complemento, não de conteúdo principal

## Tom e Voz

Seguir `brand.md` como base. No Instagram:
- Primeira linha da caption é o hook — aparece no feed antes do "ver mais"
- Tom visual primeiro: a imagem/carrossel precisa funcionar sozinha
- Hashtags no fim, nunca no meio do texto

## Tipos de Post

1. **Carrossel** — tutoriais, curadoria visual, recaps de evento
2. **Post único** — anúncio, quote, print de resultado
3. **Stories** — bastidores, votações, perguntas pro público, reposts
4. **Reels** — demos curtas (< 60s), highlights de eventos

## Frontmatter dos posts

```yaml
---
status: draft | ready | sent
sent_at: YYYY-MM-DD
type: carrossel | post | story | reel
canal: instagram
---
```

## Carrosséis

Templates HTML em `carousels/`. Exportar como PNG antes de publicar.
Usar a skill `/insta post` para publicar.

## Frequência

- 3-5 posts/semana no feed
- Stories: diário quando houver conteúdo real
- Não forçar — qualidade > quantidade
