# 002 — Movimento Livre e Interação de Cenário

**Sessão de origem:** implementação da Fase 1 (Família) — expansão de escopo confirmada pelo aluno em 2026-09-23.
**Última atualização:** 2026-09-23
**Status geral:** rascunho

## Objetivo

Permitir que o jogador controle diretamente um avatar em movimento livre por um cenário e inicie uma interação com um NPC, disparando um evento de decisão (ver [001-sistema-de-decisoes.md](001-sistema-de-decisoes.md)).

## Contexto

`game-overview.md` listava "Movimento livre do personagem pelo cenário e interações" como **fora do escopo** do Ciclo 1. Ao pedir o protótipo da Fase 1 — Família (chegar em casa e conversar com a mãe), o aluno confirmou explicitamente que essa cena precisa de movimento controlável, não de uma cena estática. Isso expande o escopo do Ciclo 1. Ver nota em [game-overview.md](../context/game-overview.md#atualização-2026-09-23--movimento-liberado-no-ciclo-1).

## Fora do escopo

- IA de NPCs (a mãe não se move; apenas fica parada e reage por proximidade).
- Múltiplos NPCs ou objetos interativos simultâneos — este incremento cobre uma interação (mãe) em uma cena.
- Colisão fina por pixel — caixas de colisão retangulares/circulares aproximadas são suficientes para o blockout.

## Requisitos

### RF-MOV-001 — Movimento livre em 4 direções

**Prioridade:** DEVE
**Status:** CONFIRMADO
**Depende de:** nenhum

O jogador controla diretamente um avatar que se move livremente pelo cenário usando as setas ou WASD, com animações de parado/andando corretas para a direção do movimento (baixo/cima/esquerda/direita).

**Critérios de aceitação**

- Dado que o jogador pressiona uma tecla de direção, quando o personagem se move, então a animação de "andando" correspondente à direção é exibida.
- Dado que o jogador solta as teclas de direção, quando o personagem para, então a animação de "parado" correspondente à última direção enfrentada é exibida.
- Dado que o personagem colide com uma parede ou objeto do cenário, quando tenta atravessar, então o movimento é bloqueado nessa direção.

**Origem:** aluno — confirmado ao pedir o protótipo da Fase 1 com o personagem andando até a mãe.

### RF-MOV-002 — Interação por proximidade dispara evento

**Prioridade:** DEVE
**Status:** CONFIRMADO
**Depende de:** RF-MOV-001, RF-AGE-001 (spec 001)

Quando o jogador se aproxima de um NPC interativo, um indicador visual aparece; ao confirmar a interação (tecla), o evento de decisão associado àquele NPC é disparado e o movimento do jogador é bloqueado enquanto o evento está na tela.

**Critérios de aceitação**

- Dado que o jogador entra na área de interação de um NPC, quando isso ocorre, então um indicador ("Pressione E") aparece.
- Dado que o indicador está visível, quando o jogador confirma a interação, então o evento de decisão daquele NPC aparece na tela e o jogador não pode mais se mover.
- Dado que o evento de decisão é resolvido (RF-AGE-001), quando o jogador fecha o evento, então o controle de movimento é devolvido ao jogador.
- Dado que o jogador já conversou com o NPC nesta sessão, quando se aproxima novamente, então o evento não é disparado de novo (conversa única no protótipo).

**Origem:** aluno — a cena da Fase 1 (Família) exige aproximar-se da mãe para a conversa acontecer.

## Alternativas descartadas

- Cena estática (sem movimento, evento disparado automaticamente ao entrar na cena) — era a opção recomendada por manter o escopo do Ciclo 1 intacto, mas foi descartada quando o aluno confirmou que queria movimento livre já neste protótipo.

## Perguntas em aberto

- Se cenas futuras (outras fases) terão múltiplos NPCs/interações por cenário — este incremento cobre apenas uma interação por cena.
- Se a trava de "conversa única" deve valer só nesta sessão de jogo ou persistir de alguma forma — não bloqueia esta implementação.

## Não aplicável a este jogo

- Nenhuma pergunta obrigatória de S0/S1 identificada como não aplicável até agora.
