# Visão Geral

> **Atualização (2026-10-16):** o nome do jogo é **ChosenZen** ("Cada escolha, uma nova história."), do **Estúdio Vívido**. "SimuladorDeVida" segue só como nome de pasta. Ver [GDD](../gdd.md).

## Pitch
Um simulador de vida em que as escolhas do jogador constroem ou destroem sua reputação na sociedade, através de decisões que testam seu caráter.

## Público
Em aberto. A definir na continuação da S0.

## Gênero e promessa
Simulador de vida (life sim) orientado a decisões.

**Referência principal:** BitLife.
**Elementos que o grupo pega de lá:**
- As barras de status (mostram apenas o número; não há decoração extra — o número em si já comunica).
- A progressão por fases da vida (o jogo cobre a vida inteira, dividida em fases por idade).

**Diferencial em relação à referência:** ao contrário do BitLife (texto/menu estático), o jogo será animado, com mapas visíveis e interações no cenário (ligado ao eixo Controle — movimento livre).

## Eixos estruturais
| Eixo | Valor |
|---|---|
| Ritmo | Em aberto |
| Unidade de jogo | Sessão contínua ao longo da vida do personagem, dividida em fases por idade |
| Controle | Direto sobre um avatar (movimento livre pelo cenário) |
| Fim | Tem fim definido: morte do personagem (velhice, doença, acidente) OU Reputação chegando a 0%. Ambos levam à mesma tela de fim. |

## Loop principal
1. O jogador recebe um evento aleatório com 2 a 4 opções (ou gera uma decisão ao interagir com algo/alguém no cenário — camada secundária).
2. Escolhe uma opção.
3. Os status mudam (Reputação, Dinheiro, Saúde, Felicidade, Inteligência, Caráter), com efeito imediato ou consequência futura, dependendo do evento.
4. Opcionalmente, desfaz a última escolha (até 3x de graça por vida; depois disso, tela simulada de assinatura trava o desfazer).

O ciclo se repete conforme o personagem envelhece e passa pelas fases da vida, até morrer (velhice, doença, acidente) ou a Reputação chegar a 0% ("cair em desgraça").

**Origem:** loop confirmado pelo aluno a partir da síntese das decisões anteriores.

## Vitória e derrota
O jogo não tem condição de vitória — é uma simulação de vida que termina em derrota (game over), de duas formas possíveis, ambas levando à mesma tela de fim:
- Morte do personagem (velhice, doença ou acidente), ligada à progressão por fases de vida.
- Reputação chega a 0%, tratado como "cair em desgraça".

**Origem:** o grupo optou por dois caminhos de fim porque a experiência mistura o ciclo natural da vida (BitLife) com a consequência das escolhas de caráter (foco do jogo). Os dois levam à mesma tela porque, na prática, ambos significam "a vida deste personagem acabou".

## Escopo mínimo
Primeiro incremento jogável (Ciclo 1):
- Um personagem em uma única fase de vida (ex.: já adulto — sem progressão por idade ainda).
- Uma sequência de eventos aleatórios, cada um com 2 a 4 opções.
- A barra de Reputação (0-100%, com cor dinâmica) reagindo a cada escolha.
- Fim de jogo quando a Reputação chega a 0% ("cair em desgraça").
- Fim de jogo por morte, quando o jogador escolhe uma opção de evento marcada como fatal (acidente, doença ou outra causa definida pelo próprio evento) — não é morte por envelhecimento, já que este incremento não tem progressão de fases.

**Origem:** o aluno confirmou este recorte como a menor versão capaz de provar o loop de decisões e consequências, incluindo morte como desfecho possível de eventos específicos.

## Fora do escopo
- ~~Movimento livre do personagem pelo cenário e interações — adiado para ciclo seguinte~~ **Atualização (2026-09-23): liberado para o Ciclo 1** — ver nota abaixo e [002-movimento-e-interacao-de-cenario.md](../specs/002-movimento-e-interacao-de-cenario.md).
- Progressão por fases de vida (infância, adolescência etc.) e morte por velhice — adiado; este incremento cobre apenas uma fase.
- Status além de Reputação (Dinheiro, Saúde, Felicidade, Inteligência, Caráter) — adiados para aprofundar o núcleo primeiro.
- Mecânica de desfazer escolha (limite de 3x e tela simulada de assinatura) — adiada; depende de Dinheiro existir como status funcional.

### Atualização (2026-09-23) — Movimento liberado no Ciclo 1
Ao pedir o protótipo da primeira cena jogável (Fase 1 — Família: chegar em casa e conversar com a mãe), o aluno confirmou explicitamente que o personagem deve andar livremente pelo cenário (WASD/setas) até a mãe, em vez de uma cena estática. Isso reverte a exclusão original de "movimento livre e interações" para o Ciclo 1.

**Origem:** decisão explícita do aluno, tomada durante a implementação (não inventada pela função de desenvolvimento). Ver [002-movimento-e-interacao-de-cenario.md](../specs/002-movimento-e-interacao-de-cenario.md) para os requisitos derivados.

---

## Decisões fechadas nesta sessão

### Formato da decisão no jogo
O jogo apresenta eventos aleatórios com frequência, cada um com 2 a 4 opções de resposta. Paralelamente, o jogador pode caminhar livremente por cenários e interagir com objetos/pessoas, o que também pode gerar decisões — mas esta segunda camada é ocasional, não o núcleo do jogo.

**Origem:** o grupo definiu os eventos aleatórios como espinha dorsal do jogo; o caminhar/interagir é secundário.

### Eixo Controle — Direto sobre avatar (movimento livre)
O jogador controla diretamente um avatar que se move livremente pelo cenário (não é navegação por menu/mapa de destinos).

**Origem:** o grupo escolheu movimento livre porque dá mais autonomia ao jogador e aumenta a imersão na simulação de vida, comparado a uma navegação por lista/menu de destinos.

### Barras de status
As barras/valores de status mostram apenas o número (sem efeitos visuais extra de comunicação). O Dinheiro é um status que pode ficar insuficiente para certas tarefas; o jogador pode optar por deixar a conta negativa (dívida) ou evitar isso.

**Origem:** o grupo trouxe o formato das barras de status do BitLife, mas quis que o Dinheiro funcionasse como recurso que trava tarefas quando insuficiente, com a dívida como escolha do jogador.

### Progressão por fases de vida
O jogo cobre a vida inteira do personagem, dividida em fases por idade (ex.: infância, adolescência, vida adulta...). O caráter das decisões e eventos muda de acordo com a fase — uma criança não recebe decisões sobre emprego, por exemplo.

**Origem:** o grupo trouxe a progressão por fases do BitLife, porque quis que o tipo de decisão disponível reflita a idade do personagem.

### Sistema de Reputação
A Reputação é uma barra de 0% a 100%, que começa em 100% e sobe, desce ou permanece igual a cada decisão tomada pelo jogador. A cor da barra muda de acordo com a faixa de valor:

| Faixa | Cor |
|---|---|
| 0% – 20% | Vermelho |
| 21% – 80% | Amarelo |
| 81% – 100% | Verde |

Ao chegar a 0%, o jogador "cai em desgraça" e o jogo termina (ver Vitória e derrota).

**Origem:** o grupo escolheu o formato de barra percentual com código de cores para comunicar o estado da Reputação de forma imediata, e fixou 0% como o limite exato de game over para que a condição de derrota seja sempre clara e verificável.

### Lista provisória de status
Além da Reputação, o jogo terá: Dinheiro, Saúde, Felicidade, Inteligência e Caráter (como valor separado da Reputação).

**Origem:** lista inicial do grupo, baseada nos status típicos do BitLife, adaptada para incluir Caráter como valor próprio (distinto de Reputação) — ainda não definido como os dois se relacionam.

**Pergunta em aberto:** como o Caráter (valor separado) influencia ou se relaciona com a Reputação.

### Mecânica de desfazer escolha
O jogador pode desfazer apenas a **última** decisão tomada. Isso é permitido de graça até **3 vezes** (valor provisório — a definir se é por vida toda ou se recarrega por fase de vida). Depois de esgotado o limite grátis, uma tela **simulada** oferece "assinatura de R$30/mês" para continuar desfazendo — não há processamento de pagamento real; é uma simulação para fins de protótipo e também reforça o pilar de reflexão social.

**Origem:** o grupo quer um limite curto de correção de erros para manter o peso das escolhas (pilar de reflexão), e optou por simular uma cobrança real de assinatura em vez de moeda do próprio jogo, porque isso é intencionalmente parte da crítica social do jogo — mas deixou explícito que pagamento real está fora do escopo deste protótipo.

**Fora do escopo:** integração de pagamento real / processamento de assinatura verdadeira.

**Hipótese de protótipo (limite de usos grátis)**
- **Valor inicial:** 3 usos grátis de "desfazer" por vida toda.
- **Pergunta do protótipo:** 3 usos é suficiente para o jogador sentir o peso das escolhas sem parecer arbitrário ou muito punitivo?
- **Teto de exploração:** até 5 usos nesta rodada de teste.

### Feedback de decisão
O retorno de uma decisão pode ser imediato (efeito visível na hora) ou aparecer só como consequência futura, dependendo do evento.

**Origem:** o grupo quer que o jogador não consiga sempre prever o resultado de uma escolha, para reforçar o peso moral (pilar de Reflexão e peso moral).
