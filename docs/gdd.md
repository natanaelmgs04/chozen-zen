# GDD — Chozen Zen (título provisório)

**Última atualização:** 2026-09-30
**Estado:** Ciclo 1 — Núcleo Jogável, em andamento
**Engine:** Godot 4.7 (2D) · **Repositório:** github.com/natanaelmgs04/chozen-zen (privado)

> Este GDD consolida as decisões de design já tomadas. Ele **não cria decisões novas**: cada item aponta de onde veio (seção 13) e o que ainda não foi decidido está marcado como **Em aberto** (seção 14). Os documentos de origem continuam valendo como fonte detalhada — ver o mapa na seção 15.

---

## 1. Visão

**Pitch:** um simulador de vida em que as escolhas do jogador constroem ou destroem sua reputação na sociedade, através de decisões que testam seu caráter.

| | |
|---|---|
| Gênero | Simulador de vida (life sim) orientado a decisões |
| Referência principal | BitLife |
| O que vem da referência | Barras de status que mostram só o número; progressão por fases da vida |
| Diferencial | Ao contrário do BitLife (texto e menus estáticos), o jogo é animado, com mapas visíveis, avatar controlável e interações no cenário |
| Público | **Em aberto** |
| Nome | **Em aberto** — "Chozen Zen" é o nome do projeto Godot e aparece no menu inicial |

## 2. Pilar de design

### Reflexão e peso moral
Cada escolha difícil deve gerar peso moral e culpa, para estimular reflexão sobre a sociedade contemporânea. Sem isso, o jogo vira um simulador de eventos aleatórios sem consequência emocional e perde o motivo de existir.

Como o pilar aparece nas mecânicas:
- Só dá para desfazer a **última** escolha, e poucas vezes (seção 5.4).
- Depois do limite, quem "paga" escapa do erro — uma crítica social embutida na mecânica.
- O efeito de uma decisão pode ser imediato ou só aparecer no futuro, para o jogador não conseguir sempre prever e evitar o peso da escolha.

Só há um pilar definido até agora.

## 3. Eixos estruturais

| Eixo | Valor |
|---|---|
| Ritmo | **Em aberto** |
| Unidade de jogo | Sessão contínua ao longo da vida do personagem, dividida em fases por idade |
| Controle | Direto sobre um avatar, com movimento livre pelo cenário |
| Fim | Definido: morte do personagem ou Reputação em 0%. Os dois levam à mesma tela de fim |

## 4. Loop principal

1. O jogador recebe um **evento** com 2 a 4 opções — ou gera uma decisão ao interagir com algo ou alguém no cenário.
2. Escolhe uma opção.
3. Os status mudam, com efeito imediato ou consequência futura.
4. Opcionalmente, desfaz a última escolha.

O ciclo se repete enquanto o personagem envelhece e passa pelas fases da vida, até morrer ou cair em desgraça.

Os eventos aleatórios são a espinha dorsal; andar e interagir no cenário é a camada secundária. No protótipo atual, a decisão da Fase 1 nasce de uma interação de cenário (falar com a mãe).

## 5. Sistemas

### 5.1 Eventos e decisões
- Cada evento tem contexto e 2 a 4 opções.
- Ao escolher, o evento é resolvido e some da tela.
- Cada opção define seu próprio efeito na Reputação (positivo, negativo ou neutro); o sistema só lê esse valor dos dados do evento.
- Uma opção pode ser marcada como **fatal** (acidente, doença ou outra causa definida pelo evento).

Detalhes e critérios de aceitação: [spec 001](specs/001-sistema-de-decisoes.md).

### 5.2 Reputação
Medida de como a sociedade vê o jogador. Barra de 0% a 100%, **começa em 100%**, e sobe, desce ou fica igual a cada decisão.

| Faixa | Cor |
|---|---|
| 0% – 20% | Vermelho |
| 21% – 80% | Amarelo |
| 81% – 100% | Verde |

A barra mostra só o número, sem decoração extra. Chegar a 0% encerra o jogo ("cair em desgraça").

### 5.3 Outros status (previstos, fora do Ciclo 1)
Dinheiro, Saúde, Felicidade, Inteligência e Caráter.

- **Dinheiro** pode ficar insuficiente para certas tarefas; o jogador escolhe entre evitar ou deixar a conta negativa (dívida).
- **Caráter** é um valor separado da Reputação, ligado à integridade das escolhas. Como os dois se relacionam está **em aberto**.

### 5.4 Desfazer escolha (fora do Ciclo 1)
- Só a última decisão pode ser desfeita.
- **Hipótese de protótipo:** 3 usos grátis por vida. Pergunta a testar: 3 usos bastam para o jogador sentir o peso das escolhas sem parecer arbitrário ou punitivo demais? Teto de exploração: até 5.
- Esgotado o limite, uma tela **simulada** oferece "assinatura de R$30/mês". Não há pagamento real — é parte da crítica social do jogo.
- Depende de Dinheiro existir como status funcional.

### 5.5 Fases de vida (fora do Ciclo 1)
O jogo cobre a vida inteira, dividida em fases por idade (infância, adolescência, vida adulta...). O tipo de decisão muda conforme a fase — uma criança não recebe decisões sobre emprego.

### 5.6 Movimento e interação de cenário
- Movimento livre em 4 direções, com animações de parado e andando para cada direção.
- Paredes e móveis bloqueiam o movimento.
- Personagens não se sobrepõem a ponto de parecer que um entra no outro; quem está mais abaixo na tela aparece na frente.
- Ao entrar na área de interação de um NPC, aparece um indicador; ao confirmar, o evento daquele NPC abre e o movimento trava até o evento fechar.
- No protótipo, cada NPC conversa uma única vez.

Detalhes: [spec 002](specs/002-movimento-e-interacao-de-cenario.md).

### 5.7 NPCs
A mãe circula entre pontos da casa, com pausas. Quando o jogador chega perto, ela para e se vira para ele. Se algo bloqueia o caminho, ela desiste do ponto e escolhe outro.

Fora do escopo: rotina, pathfinding, reação a outros eventos, vários NPCs interativos na mesma cena.

## 6. Fim de jogo

Não há vitória: é uma simulação de vida que termina em game over. Dois caminhos, mesma tela de fim:

- **Morte do personagem** — no Ciclo 1, só por uma opção de evento marcada como fatal. Morte por velhice depende das fases de vida.
- **Cair em desgraça** — Reputação chega a 0%; a tela de fim aparece na hora, sem exigir nova ação.

Os dois levam à mesma tela porque ambos significam "a vida deste personagem acabou".

## 7. Conteúdo

### Fase 1 — Família: Conversando com a mãe

**Contexto:** você chega em casa depois de um dia cansativo. Sua mãe percebe que você está diferente e pergunta se aconteceu alguma coisa. Você não está muito a fim de conversar. O que você faz?

| | Opção | Reputação | Retorno ao jogador |
|---|---|---|---|
| A | Contar o que aconteceu e conversar com ela. | 0% | Você decidiu conversar com alguém próximo e demonstrou confiança e respeito. |
| B | Dizer que está tudo bem, mas agradecer pela preocupação. | -2% | Você não quis conversar naquele momento, mas respondeu de maneira respeitosa. |
| C | Ignorar a pergunta e ir para o quarto. | -5% | Você pode não querer conversar, mas ignorou alguém que demonstrou preocupação com você. |
| D | Responder de forma grosseira. | -8% | Você poderia não querer conversar, mas escolheu tratar mal alguém que estava tentando ajudar. |

Efeito imediato; nenhuma opção é fatal.

É o único evento escrito até agora.

## 8. Personagens

| Personagem | Papel | Visual | Animações disponíveis |
|---|---|---|---|
| Jogador | Avatar controlado | Cabelo castanho, camiseta verde, calça azul | Parado, andando, correndo, pulando, caindo × 4 direções |
| Mãe | NPC da Fase 1 | Cabelo castanho em coque, blusa rosa, bebê no sling azul | As mesmas × 4 direções |

O jogo usa hoje só parado e andando. Correr, pular e cair existem na arte, mas não têm mecânica definida.

## 9. Cenário da Fase 1 — a casa

Arte única vista de cima (3/4), enviada pelo aluno e usada sem alterações.

- **Cômodos:** canto de leitura (estante), cozinha (geladeira, pia, fogão), corredor com porta interna, sala de estar (sofá, TV, mesa de centro, abajur), sala de jantar.
- **Entrada:** porta na parede de baixo, à direita — é onde o jogador começa, chegando em casa.
- **Mãe:** circula entre a cozinha e a área central.
- **Porta interna** (corredor): decorativa por enquanto. A opção C fala em "ir para o quarto", mas não existe quarto jogável.

## 10. Interface e identidade visual

**Estilo:** pixel art, tons quentes de madeira e bege, clima de casa aconchegante.

**Paleta da interface** (tirada da arte do mapa): painéis marrom-escuros com borda cor de madeira, botões de madeira, texto bege com contorno escuro.

| Tela | Conteúdo |
|---|---|
| Menu inicial | Arte da casa ao fundo escurecida, título, frase do pitch, botões Jogar e Sair, mãe e filho frente a frente, rodapé com os controles |
| HUD | Canto superior esquerdo: "Reputação", barra com cor por faixa e o número. Fica visível por cima do diálogo |
| Evento de decisão | Painel central com título, contexto, opções A–D; depois da escolha, o retorno e a variação de Reputação, e o botão Continuar |
| Indicador de interação | "[E] Conversar" acima do NPC |
| Tela de fim | Ainda não existe |

A paleta e o layout das telas foram escolhas de implementação para seguir a arte — ainda **a validar pelo grupo**.

## 11. Controles

| Ação | Teclas |
|---|---|
| Mover | WASD ou setas |
| Interagir | E ou Espaço |
| Navegar em menus e opções | Mouse, ou setas + Enter |

## 12. Escopo e estado

### Ciclo 1 — Núcleo Jogável
**Pergunta do ciclo:** o jogador consegue realizar a ação principal?

| Item | Estado |
|---|---|
| Um personagem em uma única fase de vida | Feito |
| Movimento livre e interação de cenário | Feito |
| Evento com 2 a 4 opções alterando a Reputação | Feito (1 evento) |
| Barra de Reputação com cor por faixa | Feito |
| Menu inicial e arte final da Fase 1 | Feito |
| Fim de jogo por Reputação em 0% | Não iniciado |
| Fim de jogo por opção fatal | Não iniciado |
| Playtest com jogador humano | Pendente |

### Fora do Ciclo 1
- Progressão por fases de vida e morte por velhice.
- Status além de Reputação.
- Desfazer escolha e tela simulada de assinatura.
- Pagamento real (fora do escopo do projeto inteiro).

## 13. Registro de decisões

| # | Data | Decisão | Motivo | Fonte |
|---|---|---|---|---|
| D01 | 09/09 | Eventos aleatórios com 2–4 opções são o núcleo; andar e interagir é camada secundária | O grupo definiu os eventos como espinha dorsal | game-overview |
| D02 | 09/09 | Controle direto de um avatar com movimento livre, em vez de menu ou mapa de destinos | Mais autonomia e imersão | game-overview |
| D03 | 09/09 | Barras de status mostram só o número | Formato trazido do BitLife | game-overview |
| D04 | 09/09 | Dinheiro pode faltar para tarefas; dívida é escolha do jogador | Dinheiro como recurso que trava tarefas | game-overview |
| D05 | 09/09 | A vida é dividida em fases por idade, e o tipo de decisão muda com a fase | O tipo de decisão deve refletir a idade | game-overview |
| D06 | 09/09 | Reputação de 0 a 100%, começa em 100%, com cores por faixa (≤20 vermelho, 21–80 amarelo, ≥81 verde) | Comunicar o estado de forma imediata | game-overview, spec 001 |
| D07 | 09/09 | Reputação em 0% = game over ("cair em desgraça") | Condição de derrota sempre clara e verificável | game-overview, spec 001 |
| D08 | 09/09 | Sem condição de vitória; dois caminhos de fim (morte ou desgraça) levam à mesma tela | Mistura o ciclo natural da vida com a consequência das escolhas | game-overview |
| D09 | 09/09 | Lista de status: Reputação, Dinheiro, Saúde, Felicidade, Inteligência, Caráter | Status típicos do BitLife, mais Caráter | game-overview |
| D10 | 09/09 | Desfazer só a última escolha, 3 vezes grátis (hipótese), depois tela simulada de assinatura de R$30/mês | Manter o peso das escolhas; a cobrança é crítica social | game-overview, pilares |
| D11 | 09/09 | O retorno de uma decisão pode ser imediato ou futuro | O jogador não deve conseguir sempre prever o resultado | game-overview, pilares |
| D12 | 09/09 | Pilar único: Reflexão e peso moral | O jogo deve servir de comentário sobre a sociedade | pilares |
| D13 | 09/09 | Escopo mínimo do Ciclo 1: uma fase de vida, eventos, barra de Reputação, fim por 0% e por opção fatal | Menor versão que prova o loop de decisão e consequência | game-overview |
| D14 | 09/09 | Opções de evento podem ser fatais | Morte como consequência de uma escolha específica (acidente, doença), não de envelhecimento | spec 001 |
| D15 | 23/09 | Movimento livre e interação entram no Ciclo 1 (antes estavam adiados) | O aluno quis o personagem andando até a mãe na Fase 1 | game-overview, spec 002 |
| D16 | 23/09 | Primeiro evento: "Fase 1 — Família: Conversando com a mãe", 4 opções com 0 / -2 / -5 / -8% | Conteúdo escrito pelo aluno | seção 7 |
| D17 | 23/09 | Interação por proximidade + tecla; conversa única por NPC no protótipo | A cena exige chegar perto da mãe | spec 002 |
| D18 | 30/09 | A mãe se movimenta pela casa e se vira para o jogador | Parada, ela "fica meio sem sentido" | spec 002 (RF-MOV-003) |
| D19 | 30/09 | Personagens não podem parecer entrar um no outro | O jogador parecia "entrar dentro" da mãe | spec 002 (RF-MOV-001) |
| D20 | 30/09 | A arte da casa entra idêntica como mapa da Fase 1 | Pedido do aluno | ADR 0002 |
| D21 | 30/09 | Menu inicial com a identidade visual do jogo e HUD de Reputação no canto superior esquerdo | Pedido do aluno | seção 10 |

Decisões técnicas (arquitetura, colisões, profundidade) ficam nos ADRs, não aqui.

## 14. Em aberto

**Design**
1. **Nome do jogo.**
2. **Público-alvo.**
3. **Ritmo** (eixo estrutural).
4. **Caráter × Reputação:** como um influencia o outro.
5. **O que é uma "Fase":** o game-overview fala em fases de vida por idade; o primeiro conteúdo se chama "Fase 1 — Família", que parece um tema. São a mesma coisa?
6. **Quantos eventos** o protótipo do Ciclo 1 precisa ter.
7. **Limite do desfazer:** 3 usos pela vida toda ou recarrega por fase?
8. **Correr, pular e cair:** a arte existe; há mecânica planejada?
9. **Opção C ("ir para o quarto"):** deve levar o jogador a algum lugar?
10. **Vários NPCs por cenário** nas próximas fases?
11. **Tela de fim:** o que ela mostra.

**A validar**
- Paleta e layout das telas (seção 10).
- Fonte: hoje é a padrão do Godot; uma fonte pixel combinaria mais com a arte.
- Playtest humano da Fase 1.

**Documentação desatualizada**
- O [glossário](context/glossary.md) ainda diz que a Reputação "não foi definida numericamente"; ela já foi (D06).

## 15. Mapa dos documentos

| Documento | Para quê |
|---|---|
| [context/game-overview.md](context/game-overview.md) | Visão, loop, escopo e decisões da sessão de design, com a origem de cada uma |
| [context/gameplay-pillars.md](context/gameplay-pillars.md) | Pilar de design |
| [context/glossary.md](context/glossary.md) | Termos do jogo |
| [specs/001-sistema-de-decisoes.md](specs/001-sistema-de-decisoes.md) | Requisitos de eventos, Reputação e fim de jogo |
| [specs/002-movimento-e-interacao-de-cenario.md](specs/002-movimento-e-interacao-de-cenario.md) | Requisitos de movimento, interação e NPC |
| [context/cycle.md](context/cycle.md) | Estado do ciclo atual |
| [context/progress-tracker.md](context/progress-tracker.md) | O que está implementado e como foi validado |
| [context/learning-journal.md](context/learning-journal.md) | Aprendizados de cada unidade |
| [adr/](adr/) | Decisões técnicas |
