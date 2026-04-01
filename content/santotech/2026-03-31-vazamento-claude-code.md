# A Anthropic vazou o código-fonte inteiro do Claude Code por acidente — e o que estava escondido surpreende

**Por um arquivo de map esquecido no npm, qualquer pessoa pôde baixar 512 mil linhas de código da ferramenta de IA mais usada por desenvolvedores no mundo**

---

A Anthropic, empresa criadora do Claude, cometeu um erro básico de segurança que expôs o código-fonte completo do Claude Code — sua ferramenta de desenvolvimento com IA — para qualquer pessoa na internet. O vazamento aconteceu através do npm, o maior repositório de pacotes JavaScript do mundo, e revelou não apenas o funcionamento interno da ferramenta, mas também dezenas de funcionalidades que a empresa nunca anunciou publicamente.

## Como aconteceu

Ao publicar a versão 2.1.88 do pacote `@anthropic-ai/claude-code` no npm, a Anthropic deixou acidentalmente um arquivo de source map de **59,8 MB** junto com o pacote. Arquivos de source map são ferramentas de desenvolvimento que mapeiam código minificado de volta ao código-fonte original — úteis para debug, mas que nunca deveriam ir para produção.

O pesquisador de segurança Chaofan Shou foi o primeiro a identificar o problema. Em minutos, screenshots se espalharam pela internet e backups foram criados no GitHub antes que a Anthropic conseguisse remover o pacote.

O resultado: **1.900 arquivos e mais de 512 mil linhas de código** do Claude Code ficaram expostos publicamente.

## O que estava escondido

Além do código principal, o vazamento revelou **44 feature flags** — funcionalidades completamente desenvolvidas, mas mantidas desativadas na versão pública. São recursos que a Anthropic claramente estava preparando para lançar, mas ainda não havia anunciado.

### Kairos — o agente que nunca dorme

O mais comentado. Citado mais de 150 vezes no código-fonte, o **Kairos** (palavra grega para "o momento certo") representa uma mudança fundamental no funcionamento do Claude Code: um modo daemon autônomo que opera em background de forma contínua, mesmo quando o usuário não está usando ativamente a ferramenta.

No modo Kairos, o agente realiza um processo chamado **autoDream**: consolida memórias, remove contradições entre informações coletadas e converte observações vagas em fatos concretos — tudo enquanto o usuário está inativo. É, essencialmente, um assistente que pensa enquanto você dorme.

### Coordinator Mode — um agente que comanda outros agentes

O **Coordinator Mode** transforma o Claude Code em um orquestrador capaz de criar e gerenciar múltiplos agentes trabalhadores em paralelo, cada um com conjuntos de ferramentas restritos para tarefas específicas. Junto a ele, o vazamento também menciona o **ULTRAPLAN**, voltado para sessões remotas de planejamento de até 30 minutos na nuvem.

Para quem desenvolve com IA, isso representa um salto: sair de um assistente único para uma equipe de agentes especializados coordenados por um agente principal.

### Auto Mode — fim das confirmações

O **Auto Mode** implementa um classificador de IA que aprova automaticamente permissões de ferramentas, eliminando as confirmações constantes que o Claude Code exige hoje. Menos interrupções, mais autonomia — mas também mais risco se algo der errado.

### Undercover Mode — o mais polêmico

O **Undercover Mode** é, sem dúvida, a descoberta mais controversa. O recurso, ativado automaticamente para funcionários da Anthropic em repositórios públicos, remove qualquer atribuição de IA dos commits — mensagens, metadados, qualquer rastro de que o código foi gerado com auxílio do Claude.

O prompt de sistema encontrado no código é direto: *"You are operating UNDERCOVER... Your commit messages MUST NOT contain ANY Anthropic-internal information. Do not blow your cover."*

Não há opção de desligar para os funcionários. A revelação levantou questões imediatas sobre transparência: se a própria empresa que defende o uso ético de IA tem um modo para esconder esse uso, o que isso diz sobre o setor como um todo?

### Buddy System — a surpresa inesperada

Por fim, o **Buddy System**: um sistema completo de pet virtual estilo Tamagotchi, com 18 espécies diferentes, tiers de raridade, variantes shiny e atributos. Um detalhe que, no mínimo, mostra que os engenheiros da Anthropic têm senso de humor.

## Outras funcionalidades reveladas

Além das citadas, o código expôs recursos como:

- Agendamento via **cron** com webhooks externos
- **Controle de navegador via Playwright** (além do simples web_fetch atual)
- **Comando por voz** com CLI dedicado
- Agentes auto-resumíveis sem intervenção do usuário
- Memória persistente entre sessões sem necessidade de armazenamento externo

## A resposta da Anthropic

A Anthropic removeu o pacote rapidamente após a descoberta, mas o estrago já estava feito — múltiplos backups públicos foram criados antes da remoção. A empresa não emitiu comunicado oficial detalhado sobre o incidente até o momento de publicação desta matéria.

## O que isso significa

O vazamento em si é um erro técnico comum — source maps esquecidos em produção acontecem. O que chama atenção é o que estava dentro.

O Kairos e o Coordinator Mode revelam para onde o Claude Code está indo: de ferramenta reativa para agente autônomo permanente. O Auto Mode aponta para menos controle humano nas operações. E o Undercover Mode levanta perguntas que vão além da tecnologia — sobre transparência, atribuição e os padrões que as próprias empresas de IA aplicam (ou não) a si mesmas.

Para desenvolvedores e builders que usam o Claude Code no dia a dia, uma certeza: o produto que você usa hoje é bem diferente do produto que a Anthropic está construindo para o futuro.

---

*Fontes: VentureBeat, The AI Corner, DEV Community, PiunikaWeb, GitHub (Kuberwastaken/claude-code)*
