# PBuilders WhatsApp — Guia de Conteúdo

## Contexto

WhatsApp é grupo fechado, comunidade. Não é feed público.
Diferenças fundamentais de LinkedIn/X:
- WhatsApp corta mensagens com mais de ~500 caracteres com "ver mais". Todo post DEVE ter no máximo 500 caracteres pra pessoa ler de uma vez, sem clicar
- Tom mais íntimo, como conversa entre conhecidos
- Post longo demais = ignorado (não é artigo)
- Pode mandar mídia direto (imagem, vídeo, link)
- Notificação push — cada post interrompe. Respeitar isso.

## Tom e Voz

Seguir `profile/brand.md` como base, com ajustes pro WhatsApp:

### Fazer
- Falar como se tivesse no grupo de amigos que constroem coisas
- "A galera", "o bizu", linguagem natural
- Compartilhar o que tá construindo de verdade (demo, print, resultado)
- Perguntar pro grupo — puxar conversa, não só broadcast
- Celebrar quem faz. Dar palco pra quem mostrou algo
- Ser direto: uma ideia por mensagem

### NÃO fazer
- Tom institucional ("Prezados membros da comunidade...")
- Mensagem genérica de IA copiada ("5 dicas para...")
- Emoji wall (🚀🔥💡🎯 — não)
- Post enorme com 10 parágrafos
- Falar sobre IA sem conexão com PB ou com algo real
- Spam de link sem contexto

### Palavras banidas (marcadores de IA)
- "a sacada é", "o segredo é", "o ponto-chave é"
- "vale ouro", "isso é ouro puro", "pulo do gato"
- brutal, massive, crucial, robust, pivotal, vibrant
- "em conclusão", "é importante notar", "aprofundar"
- "Cara," (não é vocabulário do Alan)
- Em dash (—) como estilo recorrente

## Formato

### Limite absoluto: 500 caracteres
- Toda mensagem tem que caber em 500 caracteres (incluindo espaços e quebras de linha)
- Se passar de 500, cortar ou quebrar em 2 mensagens separadas
- Contar caracteres antes de marcar como ready

### Estrutura padrão

```
[Hook — primeira linha que prende]

[Corpo — contexto, o que rolou, o que aprendeu]

[Fechamento — pergunta ou call-to-action pro grupo]
```

O hook não precisa ser clickbait. No WhatsApp, precisa ser **relevante** — a pessoa decide em 1 segundo se vai ler o resto.

### Com mídia
- Print > texto sobre print
- Vídeo curto (< 1min) > texto longo explicando
- Link sempre com contexto ("isso aqui mostra X, olha o que acontece quando Y")

## Hooks para WhatsApp

Adaptação do banco de hooks (ref: `projects/archived/creator/strategy/hooks.md`):

### Técnicas que funcionam no grupo

1. **Pergunta direta** — "Alguém aqui já usou [X] pra [Y]?"
2. **Resultado real** — "Fiz isso aqui em 2h usando Claude:" + print
3. **Provocação leve** — "Vocês acham que [afirmação controversa]?"
4. **Behind the scenes** — "Tô testando uma parada aqui, olha o que saiu:"
5. **Curadoria** — "Vi isso aqui e achei que a galera ia curtir:"
6. **Chamada pra ação** — "Quem quiser testar junto, cola aqui"
7. **Surpresa com dado** — "X% das empresas que [Y] fazem [Z]. Olha esse estudo:"

### Técnicas que NÃO funcionam no WhatsApp
- FOMO artificial ("Você tá perdendo se não...")
- Hook de LinkedIn com "see more" bait
- Lista numerada longa (5 dicas, 7 passos...)
- Frases motivacionais genéricas

## Tipos de Post (Rotação)

1. **Compartilhar build** — mostrar algo que tá construindo, print, demo, resultado
2. **Curadoria** — ferramenta, artigo, vídeo que é útil pro grupo
3. **Pergunta/discussão** — puxar conversa sobre tema relevante
4. **Evento/anúncio** — próximo encontro, speaker confirmado, agenda
5. **Recap** — o que rolou no último evento, highlights
6. **Spotlight** — destacar algo que alguém do grupo fez

Não precisa seguir ordem fixa. O bizu é não ficar repetindo o mesmo tipo.

## Frequência

- 2-4 posts por semana no máximo
- Não postar todo dia — grupo vira ruído
- Melhor horário: manhã (8-10h) ou noite (19-21h) em dia de semana
- Se alguém postou algo bom, não sobrepor. Deixar respirar.

## Frontmatter dos posts

```yaml
---
status: draft | ready | sent
sent_at: YYYY-MM-DD
type: build | curadoria | discussao | evento | recap | spotlight
---
```

## Checklist antes de enviar

- [ ] Primeira linha prende? (leria se recebesse no grupo?)
- [ ] Tamanho ok? (não passou de 20 linhas?)
- [ ] Tom tá natural? (leria como mensagem de grupo, não como newsletter?)
- [ ] Não tem palavra banida / tom de IA?
- [ ] Mídia anexada se necessário?
- [ ] Não tá sobrepondo outra conversa ativa no grupo?
