# 001 — Sistema de Decisões e Reputação

**Sessão de origem:** S0/S1 (Ciclo 1 — Núcleo Jogável)
**Última atualização:** 2026-09-09
**Status geral:** rascunho

## Objetivo

Permitir que o jogador tome decisões diante de eventos aleatórios e veja essas decisões afetarem sua Reputação, até o jogo terminar por desgraça (Reputação zerada) ou morte.

## Contexto

Depende de [game-overview.md](../context/game-overview.md) (Loop principal, Vitória e derrota, Escopo mínimo) e [gameplay-pillars.md](../context/gameplay-pillars.md) (Reflexão e peso moral).

## Fora do escopo

- Movimento livre pelo cenário e interações com objetos/pessoas — camada secundária do loop, adiada.
- Progressão por fases de vida e morte por velhice — este incremento cobre uma única fase.
- Status além de Reputação (Dinheiro, Saúde, Felicidade, Inteligência, Caráter).
- Mecânica de desfazer escolha (limite de 3x grátis + tela simulada de assinatura).

## Requisitos

### RF-AGE-001 — Evento aleatório com opções

**Prioridade:** DEVE
**Status:** CONFIRMADO
**Depende de:** nenhum

O jogo apresenta ao jogador, periodicamente, um evento com 2 a 4 opções de resposta.

**Critérios de aceitação**

- Dado que um evento aleatório é disparado, quando ele aparece na tela, então o jogador vê entre 2 e 4 opções de resposta.
- Dado que um evento está sendo exibido, quando o jogador seleciona uma das opções, então o evento é resolvido e some da tela.

**Origem:** eventos aleatórios com 2-4 opções são a espinha dorsal do loop, decidido pelo aluno como núcleo do jogo.

### RF-AGE-002 — Escolha altera Reputação

**Prioridade:** DEVE
**Status:** CONFIRMADO
**Depende de:** RF-AGE-001

Ao escolher uma opção de um evento, a Reputação do jogador aumenta, diminui ou permanece igual, conforme o efeito definido para aquela opção naquele evento.

**Critérios de aceitação**

- Dado que o jogador escolhe uma opção com efeito positivo, quando a escolha é confirmada, então o valor de Reputação aumenta pela quantidade definida naquela opção.
- Dado que o jogador escolhe uma opção com efeito negativo, quando a escolha é confirmada, então o valor de Reputação diminui pela quantidade definida naquela opção.
- Dado que o jogador escolhe uma opção neutra, quando a escolha é confirmada, então o valor de Reputação permanece igual.

**Origem:** sistema de Reputação como barra de 0% a 100%, que começa em 100% e muda a cada decisão — decisão do aluno.

### RF-AGE-003 — Barra de Reputação com cor dinâmica

**Prioridade:** DEVE
**Status:** CONFIRMADO
**Depende de:** RF-AGE-002

A barra de Reputação exibe o valor atual (apenas o número) e muda de cor conforme a faixa em que o valor está.

**Critérios de aceitação**

- Dado que a Reputação está entre 0 e 20, quando a barra é exibida, então ela aparece vermelha.
- Dado que a Reputação está entre 21 e 80, quando a barra é exibida, então ela aparece amarela.
- Dado que a Reputação está entre 81 e 100, quando a barra é exibida, então ela aparece verde.

**Origem:** aluno — código de cores para comunicar o estado da Reputação de forma imediata.

### RF-AGE-004 — Fim de jogo por reputação zerada

**Prioridade:** DEVE
**Status:** CONFIRMADO
**Depende de:** RF-AGE-002

Quando a Reputação chega a 0%, o jogo é encerrado e a tela de fim é exibida.

**Critérios de aceitação**

- Dado que a Reputação chega a 0%, quando o valor é atualizado, então a tela de fim de jogo é exibida imediatamente, sem exigir nova ação do jogador.

**Origem:** aluno — "cai em desgraça" ao chegar a 0%; único gatilho numérico de derrota por Reputação.

### RF-AGE-005 — Morte por consequência de evento

**Prioridade:** DEVE
**Status:** CONFIRMADO
**Depende de:** RF-AGE-001

Algumas opções de evento podem, ao serem escolhidas, causar a morte do personagem (acidente, doença ou outra causa definida pelo próprio evento). Quando isso ocorre, o jogo é encerrado e a mesma tela de fim de RF-AGE-004 é exibida.

**Critérios de aceitação**

- Dado que o jogador escolhe uma opção marcada como fatal, quando a escolha é confirmada, então o jogo é encerrado e a tela de fim é exibida.
- Dado que o jogador escolhe uma opção não marcada como fatal, quando a escolha é confirmada, então o jogo continua normalmente, sem exibir a tela de fim.

**Origem:** aluno — "algumas decisões podem causar mortes acidentais, ou doenças que causam a morte, entre outros"; morte é consequência de uma escolha específica, não de envelhecimento (fora de escopo neste incremento).

## Alternativas descartadas

- Navegação por menu/mapa de destinos em vez de movimento livre. Descartado porque o grupo quer mais autonomia e imersão (decisão registrada em game-overview.md, mas afeta o ciclo seguinte, não este).

## Perguntas em aberto

- Quantos eventos aleatórios existem no protótipo mínimo deste incremento. Depende de definição de conteúdo (Game Designer / Level Designer).
- Como cada evento define seus valores de efeito na Reputação (fixos por opção, definidos individualmente por quem escrever o evento). Não bloqueia a implementação do sistema, que apenas lê esse valor dos dados do evento.

## Não aplicável a este jogo

- Nenhuma pergunta obrigatória de S0/S1 identificada como não aplicável até agora.
