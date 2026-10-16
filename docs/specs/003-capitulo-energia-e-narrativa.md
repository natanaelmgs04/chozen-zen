# 003 — Capítulo, Energia e Narrativa (level design da Fase 1)

**Sessão de origem:** feedback do professor (2026-10-16) + decisões do aluno na mesma data
**Última atualização:** 2026-10-16
**Status geral:** rascunho

## Objetivo

Dar à Fase 1 um desafio, um objetivo, obstáculos e progressão, e uma história que leve a algum lugar, em vez de uma sequência de perguntas com uma resposta "certa".

## Contexto

O professor apontou que não estava claro "qual o desafio/dinâmica do jogo, o que o jogador está buscando, quais obstáculos e progressão", e que a narrativa estava "mais para um quiz do que um storytelling". O diagnóstico: toda opção só tirava Reputação, então a opção que tirava menos era sempre a certa.

Decisões do aluno que resolvem isso:
- **Tensão Reputação × Energia:** ser atencioso custa Energia; poupar Energia custa Reputação.
- **Fio da história:** o personagem foi **acusado injustamente** de colar na prova.

Depende de [001](001-sistema-de-decisoes.md) (eventos e Reputação) e [002](002-movimento-e-interacao-de-cenario.md) (movimento e interação).

## Fora do escopo

- Fase 2 (Escola) — o resumo do dia só anuncia o que vem.
- Outros status (Dinheiro, Saúde, Felicidade, Inteligência, Caráter).
- Salvar o progresso entre sessões.

## Requisitos

### RF-CAP-001 — Capítulo com objetivo e momentos

**Prioridade:** DEVE · **Status:** CONFIRMADO

A Fase 1 é o capítulo "Uma noite em casa", com objetivo **terminar o dia no quarto**, dividido em três momentos em ordem: **Chegada** (falar com a mãe) → **Jantar** (mesa de jantar) → **Antes de dormir** (porta do quarto). O objetivo atual aparece na tela e uma seta mostra onde ir.

**Critérios de aceitação**
- Dado que o capítulo começa, quando a abertura termina, então aparece o objetivo "Fale com sua mãe" e uma seta sobre ela.
- Dado que um momento termina, quando o evento fecha, então o objetivo e a seta mudam para o próximo momento.
- Dado que o jogador tenta ir direto para o quarto na Chegada, quando chega à porta, então a mãe o chama e o evento da Chegada acontece mesmo assim.

### RF-ENE-001 — Energia como recurso do capítulo

**Prioridade:** DEVE · **Status:** CONFIRMADO

A Energia (0–100) começa em 50 em cada capítulo (o personagem chega cansado) e aparece no HUD abaixo da Reputação. Opções atenciosas gastam Energia; um lanche na geladeira recupera +15, uma vez por capítulo.

**Critérios de aceitação**
- Dado que um capítulo começa, quando o HUD aparece, então a Energia mostra 50.
- Dado que o jogador interage com a geladeira, quando confirma, então ganha +15 de Energia e a geladeira não pode ser usada de novo.

### RF-ENE-002 — Custo visível e opção bloqueada

**Prioridade:** DEVE · **Status:** CONFIRMADO

O custo de Energia de cada opção aparece **antes** da escolha; se o jogador não tem Energia suficiente, a opção fica bloqueada ("sem energia"). O efeito na Reputação só aparece **depois** da escolha.

**Critérios de aceitação**
- Dado que uma opção custa mais Energia do que o jogador tem, quando o evento aparece, então a opção está desabilitada e marcada "sem energia".
- Dado que o jogador escolhe uma opção, quando o retorno aparece, então ele mostra a variação de Reputação e de Energia.

**Origem da regra de mostrar/esconder:** proposta de implementação, a validar pelo grupo. Mostrar a Energia permite planejar (desafio); esconder a Reputação preserva o pilar de peso moral (o jogador não escolhe só pelo número).

### RF-ENE-003 — Sem Energia, o capítulo acaba antes

**Prioridade:** DEVE · **Status:** CONFIRMADO

Se a Energia chega a 0 depois de um momento que não é o último, o personagem apaga de sono, o capítulo termina e os momentos restantes são perdidos.

**Critérios de aceitação**
- Dado que a Energia chega a 0 depois da Chegada ou do Jantar, quando o evento fecha, então aparece "Você apagou de sono" e o resumo do dia.

### RF-CAP-002 — Escolhas viram memórias que mudam o que vem depois

**Prioridade:** DEVE · **Status:** CONFIRMADO

Cada opção pode gravar uma memória. As memórias mudam os eventos seguintes e o resumo do dia (aplica a decisão já existente de que o retorno pode ser futuro).

**Critérios de aceitação**
- Dado que o jogador contou a verdade à mãe na Chegada, quando chega o Jantar, então a mãe já sabe e a conversa é outra (ela oferece ajuda).
- Dado que o jogador não contou, quando chega o Jantar, então chega o e-mail da escola e ele precisa decidir o que dizer.
- Dado que o jogador ignorou ou foi grosseiro, quando chega o Jantar, então o texto mostra que a mãe está magoada.

### RF-CAP-003 — Resumo do dia e gancho para a próxima fase

**Prioridade:** DEVE · **Status:** CONFIRMADO

Ao fim do capítulo, um resumo mostra as consequências das escolhas para "amanhã", a Reputação e a Energia finais, e anuncia a Fase 2 (Escola: a prova de recuperação).

**Critérios de aceitação**
- Dado que o capítulo termina, quando o resumo aparece, então ele lista o que vai acontecer amanhã de acordo com as memórias e oferece "Jogar de novo" e "Menu principal".

## Valores do protótipo (para balancear em playtest)

| Momento | A | B | C | D |
|---|---|---|---|---|
| Chegada | Rep 0 · En −25 | Rep −2 · En −10 | Rep −5 · En 0 | Rep −8 · En 0 |
| Jantar (contou) | Rep +3 · En −25 | Rep 0 · En −5 | Rep −2 · En −10 | Rep −6 · En 0 |
| Jantar (não contou) | Rep +2 · En −20 | Rep −2 · En −5 | Rep +1 · En −25 | Rep −6 · En 0 |
| Antes de dormir | En −30 | En −15 | En 0 | Rep −6 · En −5 |

Energia inicial 50 e lanche +15. Ser atencioso em tudo (A na Chegada e A no Jantar) gasta os 50 e o personagem apaga antes da noite, a menos que tenha comido o lanche. Para conseguir estudar, é preciso ter economizado em algum momento.

## Perguntas em aberto

- A Reputação começa em 100%, então efeitos positivos no começo do jogo não aparecem.
- Energia deve existir só por capítulo ou virar um status da vida toda (como Saúde)?
- Os valores acima precisam de playtest.
