---
name: sympla
description: Gerencia eventos Sympla — lista eventos, participantes, pedidos e faz check-in via API v3
user-invocable: true
argument-hint: [events | participants | orders | checkin | check]
---

# /sympla

Gerencia o Sympla via API REST v3. Pure Ruby, zero gems — stdlib only.

## Setup (verificar antes de usar)

```bash
ruby .claude/skills/sympla/scripts/check_setup.rb
```

Token salvo em `~/.sympla/config.json`. Para trocar:
```bash
echo '{"token":"seu_token"}' > ~/.sympla/config.json
# ou
export SYMPLA_TOKEN=seu_token
```

## Estrutura

```
scripts/
├── auth.rb          # Token auth + sympla_request helper (required por todos)
├── check_setup.rb   # Verifica se o token existe
├── events.rb        # Listar todos os eventos
├── event_get.rb     # Detalhes de um evento específico
├── participants.rb  # Listar participantes de um evento
├── orders.rb        # Listar pedidos de um evento
└── checkin.rb       # Realizar check-in (por participant_id ou ticket_number)
```

## Default — usar SEMPRE

| Variável | Descrição |
|---|---|
| `SYMPLA_EVENT_ID` | ID do evento ativo (preencher quando criar o evento na Sympla) |

Quando o usuário não especificar evento, usar `SYMPLA_EVENT_ID` do ambiente. Nunca perguntar "qual evento?" se o default estiver definido.

## Comandos

**Listar eventos:**
```bash
ruby .claude/skills/sympla/scripts/events.rb
ruby .claude/skills/sympla/scripts/events.rb --page 2
```

**Ver evento:**
```bash
ruby .claude/skills/sympla/scripts/event_get.rb EVENT_ID
```

**Listar participantes:**
```bash
ruby .claude/skills/sympla/scripts/participants.rb EVENT_ID
ruby .claude/skills/sympla/scripts/participants.rb EVENT_ID --page 2 --size 50
```

**Listar pedidos:**
```bash
ruby .claude/skills/sympla/scripts/orders.rb EVENT_ID
```

**Check-in:**
```bash
ruby .claude/skills/sympla/scripts/checkin.rb EVENT_ID --participant PARTICIPANT_ID
ruby .claude/skills/sympla/scripts/checkin.rb EVENT_ID --ticket TICKET_NUMBER
```

## Notas

- **Pure Ruby, zero gems** — stdlib only (json, net/http, uri)
- Token passado via header `s_token` em todas as requests
- Token lido de `SYMPLA_TOKEN` env var ou `~/.sympla/config.json` → campo `token`
- API endpoint base: `https://api.sympla.com.br/public/v3`
- Resultados paginados — usar `--page N` para avançar
