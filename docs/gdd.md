# GDD — ChosenZen

*"Cada escolha, uma nova história."* — um jogo do **Estúdio Vívido** ("Ideias que ganham vida")

**Última atualização:** 2026-10-16
**Estado:** Ciclo 1 — Núcleo Jogável, em andamento
**Engine:** Godot 4.7 (2D) · **Repositório:** github.com/natanaelmgs04/chozen-zen (privado) · **Publicação:** itch.io (web + Windows)

> Este GDD consolida as decisões de design já tomadas. Ele **não cria decisões novas**: cada item aponta de onde veio (seção 13) e o que ainda não foi decidido está marcado como **Em aberto** (seção 14). Os documentos de origem continuam valendo como fonte detalhada — ver o mapa na seção 15.

---

## 1. Visão

**Pitch:** um simulador de vida em que as escolhas do jogador constroem ou destroem sua reputação na sociedade, através de decisões que testam seu caráter.

| | |
|---|---|
| Gênero | Life sim orientado a decisões, com elementos de estratégia e RPG casual |
| Referência principal | BitLife |
| O que vem da referência | Barras de status que mostram só o número; progressão por fases da vida |
| Diferencial | Ao contrário do BitLife (texto e menus estáticos), o jogo é animado, com mapas visíveis, avatar controlável e interações no cenário |
| Público | **Em aberto** |
| Nome | **ChosenZen** |
| Estúdio | Estúdio Vívido |
| Monetização | Premium: compra única de R$ 19,90, sem anúncios obrigatórios, sem assinatura VIP, sem pay-to-win. Expansões opcionais no futuro |

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

Os eventos aleatórios são a espinha dorsal; andar e interagir no cenário é a camada secundária. No protótipo atual, as decisões da Fase 1 nascem de interações de cenário (falar com a mãe, ir até a mesa, ir para o quarto).

## 4.1 Level design: o que o jogador busca e o que o impede

Resposta ao feedback do professor (2026-10-16). Detalhes em [spec 003](specs/003-capitulo-energia-e-narrativa.md).

| Pergunta | Resposta |
|---|---|
| **O que o jogador busca?** | Em cada capítulo, um objetivo concreto (na Fase 1: *terminar o dia no quarto*). Na vida toda, chegar ao fim sendo a pessoa que escolheu ser, sem cair em desgraça. |
| **Qual é o desafio?** | Escolher sob **duas pressões que puxam para lados opostos**: ser atencioso custa **Energia**; poupar Energia custa **Reputação**. Não existe opção que seja melhor em tudo. |
| **Quais são os obstáculos?** | (1) Energia limitada: opções caras ficam bloqueadas quando falta Energia, e com 0 o personagem apaga e perde o resto do capítulo. (2) Consequências que voltam depois: uma escolha muda os eventos seguintes e o desfecho. (3) O próprio cenário: é preciso ir até as pessoas e lugares, e há recursos opcionais para achar (o lanche na geladeira). |
| **Como é a progressão?** | Capítulo → momentos em ordem (Chegada → Jantar → Antes de dormir) → resumo do dia → próximo capítulo. A Reputação e as memórias seguem pela vida; a Energia reinicia a cada capítulo. Os capítulos acompanham as fases da vida (Família → Escola → ...). |
| **Para onde a história leva?** | Um fio que atravessa os capítulos: na Fase 1, o personagem foi acusado injustamente de colar na prova. O que ele conta, esconde ou descobre à noite define como a Fase 2 (Escola: a prova de recuperação) começa. |

**Por que antes parecia um quiz:** toda opção só tirava Reputação, então a que tirava menos era sempre a certa. Agora cada opção tem um custo diferente, e o resultado aparece mais tarde.

## 4.2 Referências (o que pegamos de cada uma)

| Referência | O que entrou no ChosenZen |
|---|---|
| BitLife | Status por número, fases da vida (referência original do grupo) |
| Telltale / Life is Strange | Aviso "vai se lembrar disso" logo após escolhas com consequência (as **memórias**) |
| Night in the Woods / Undertale | Texto em máquina de escrever com bipes curtos, pulável; ritmo rápido de diálogo |
| Stardew Valley | Emote "!" sobre o NPC; o dia termina com um **resumo** do que vem amanhã; casa aconchegante em 3/4 |
| Reigns / Papers, Please | Dois recursos que puxam para lados opostos: nenhuma escolha é boa em tudo |
| Unpacking / A Short Hike | Interface discreta, sons suaves e clima de conforto |
| Cuphead e Terraria (artbooks citados pelo professor) | Identidade visual consistente do logo ao jogo |
| To the Moon / Stardew Valley | Cutscenes feitas no próprio motor, com os mesmos sprites, emotes e balões, em vez de vídeo ou parede de texto |
| Limbo / quadrinhos | Silhuetas para a turma na cutscene: o olho vai direto para quem importa na cena |
| Infográficos de polish e game feel do professor | Checklist de polimento aplicado item a item ([checklist-reta-final.md](checklist-reta-final.md)) |

## 5. Sistemas

### 5.1 Eventos e decisões
- Cada evento tem contexto e 2 a 4 opções.
- Ao escolher, o evento é resolvido e some da tela.
- Cada opção define seu próprio efeito na Reputação (positivo, negativo ou neutro); o sistema só lê esse valor dos dados do evento.
- Uma opção pode ser marcada como **fatal** (acidente, doença ou outra causa definida pelo evento).

Detalhes e critérios de aceitação: [spec 001](specs/001-sistema-de-decisoes.md).

### 5.1.1 Cenas antes e depois das enquetes

Toda enquete segue o mesmo ritmo: **cena → escolha → cena → resultado**.

1. **Antes (2 a 6 s):** faixas de cinema entram, a câmera enquadra os personagens e a situação é encenada na própria casa, com emotes, balões curtos e sons. Exemplos: a mãe pergunta "Filho? Aconteceu alguma coisa?"; no jantar, o e-mail da escola chega e o bebê chora; à noite, o celular vibra com a mensagem do Lucas.
2. **Enquete:** o painel de sempre (custo de Energia visível, efeito na Reputação escondido).
3. **Depois (2 a 5 s):** o painel some e o personagem faz o que o jogador escolheu: abraça a mãe, sai andando, responde com raiva, pega o bebê, estuda, posta a indireta (e as notificações explodem).
4. **Resultado:** o painel volta com o retorno, a Reputação e a Energia, e o aviso de memória.

Cada uma das 16 opções do capítulo tem uma cena própria (campo `"cena"` em `fase1_roteiro.gd`; as cenas ficam em `fase1_cenas.gd`). Segurar E acelera as cenas em 3×; a enquete nunca é acelerada.

### 5.2 Reputação
Medida de como a sociedade vê o jogador. Barra de 0% a 100%, **começa em 100%**, e sobe, desce ou fica igual a cada decisão.

| Faixa | Cor |
|---|---|
| 0% – 20% | Vermelho |
| 21% – 80% | Amarelo |
| 81% – 100% | Verde |

A barra mostra só o número, sem decoração extra. Chegar a 0% encerra o jogo ("cair em desgraça"). A Reputação vale pela vida toda.

### 5.2.1 Energia
Recurso do capítulo, de 0 a 100. Começa em 50 (o personagem chega cansado) e reinicia a cada capítulo.

- Opções atenciosas gastam Energia; o custo aparece **antes** da escolha.
- Sem Energia suficiente, a opção fica bloqueada ("sem energia").
- Com 0 depois de um momento, o personagem apaga de sono e o capítulo acaba antes.
- Recursos no cenário recuperam Energia (Fase 1: lanche na geladeira, +15, uma vez).
- O efeito na **Reputação** só aparece **depois** da escolha, para o jogador não decidir só pelo número.

### 5.2.2 Memórias
Cada escolha pode gravar uma memória ("contou para a mãe", "ajudou com o bebê", "estudou"...). As memórias mudam os eventos seguintes e o resumo do dia, e vão carregar o fio da história para o próximo capítulo.

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

### Fase 1 — Família: "Uma noite em casa"

**Abertura (cutscene, cerca de 40 s, pulável):** contada em imagens, quase sem texto, em três planos de pixel art feitos no próprio jogo:

1. **Sala de aula, dia da prova.** O Lucas, sentado atrás, empurra uma cola para baixo da cadeira do personagem. A professora desce o corredor, encontra o papel ("!") e pergunta: "Colando na prova?". A turma inteira se vira e cochicha. "Não é minha!" "Recuperação. Amanhã cedo." O Lucas desvia o olhar e sua (pista de quem era a cola, confirmada à noite se o jogador perguntar a ele).
2. **Voltando para casa.** Pôr do sol, os postes acendem um a um. O celular vibra: "Grupo da turma: 12 mensagens novas". Ele para, suspira e segue mais devagar.
3. **A porta de casa.** A sombra da mãe passa pela janela. Ele respira fundo e abre a porta; a luz quente de dentro emenda com o começo da fase, em que ele entra pela porta da frente.

O protagonista e a professora aparecem em cor; os colegas são silhuetas, uma multidão sem rosto que julga. Isso conta, sem palavras, que ele se sente sozinho. A professora tem sprites próprios em pixel art (coque, óculos, cardigã mostarda e saia verde), desenhados pixel a pixel por `tools/make_professora.py`. Ao ganhar o controle, o título do capítulo aparece sobre a casa e três dicas curtas (controles, Energia, Reputação) passam na base da tela.

| Momento | Onde | O que está em jogo |
|---|---|---|
| 1. Chegada | Falar com a mãe (ou ela chama se você tentar ir direto para o quarto) | Contar ou esconder o que aconteceu |
| 2. Jantar | Mesa de jantar | Se você contou: aceitar a ajuda dela e ajudar com o bebê. Se não contou: chega um e-mail da escola e você precisa se explicar |
| 3. Antes de dormir | Porta do quarto | Estudar, perguntar ao Lucas se a cola era dele, dormir ou postar uma indireta |
| Resumo do dia | — | O que vai acontecer amanhã, conforme as memórias; anúncio da Fase 2 (Escola) |

**Chegada** (texto original do grupo, agora com custo de Energia):

| | Opção | Reputação | Energia | Retorno ao jogador |
|---|---|---|---|---|
| A | Contar o que aconteceu e conversar com ela. | 0% | −25 | Você decidiu conversar com alguém próximo e demonstrou confiança e respeito. |
| B | Dizer que está tudo bem, mas agradecer pela preocupação. | −2% | −10 | Você não quis conversar naquele momento, mas respondeu de maneira respeitosa. |
| C | Ignorar a pergunta e ir para o quarto. | −5% | 0 | Você pode não querer conversar, mas ignorou alguém que demonstrou preocupação com você. |
| D | Responder de forma grosseira. | −8% | 0 | Você poderia não querer conversar, mas escolheu tratar mal alguém que estava tentando ajudar. |

Jantar, Antes de dormir e o resumo: textos completos em `scripts/data/fase1_roteiro.gd` e valores na [spec 003](specs/003-capitulo-energia-e-narrativa.md). Nenhuma opção é fatal.

Os textos do Jantar, de Antes de dormir e do resumo foram escritos na implementação a partir da história escolhida pelo aluno (acusação injusta) — **a revisar pelo grupo**.

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
- **Mãe:** circula entre a cozinha e a área central; no Jantar, vai para a mesa.
- **Pontos de interesse:** mãe (Chegada), mesa de jantar (Jantar), porta do corredor = quarto (Antes de dormir), geladeira (lanche opcional, +15 Energia).
- Uma seta flutuante mostra onde está o objetivo atual.
- Não há quarto jogável: chegar à porta encerra o dia.

### 9.1 Casa modular (desde 16/10)

A casa foi redesenhada em pixel art por código (`tools/make_casa.py`), na mesma grade de 4 px dos personagens e com a mesma disposição: cozinha ao fundo, sofá no meio, jantar à direita, porta de entrada embaixo e porta do quarto no corredor.

- **Fundo:** chão de tábuas, azulejos da cozinha, paredes com lambri, janela, porta do quarto, foto da família, estante, bancada, TV, rack e tapete.
- **Móveis separados**, ordenados por profundidade: sofá, mesa de centro, mesa de jantar com 6 cadeiras, abajur, geladeira, plantas e relógio. O jogador passa atrás do sofá e senta atrás da mesa.

| Interação | O que acontece |
|---|---|
| Sofá (3 lugares) e 6 cadeiras | [E] senta na pose certa (de frente, de lado ou de costas); E ou mover levanta |
| Abajur | Acende/apaga de verdade (sprite e luz da sala) |
| TV | Liga/desliga; a tela fica trocando de imagem; comentário sobre o programa |
| Geladeira | A porta abre (luz de dentro) ao fazer o lanche |
| Estante, foto, fogão, planta, pia | Comentários que contam a história da família |
| Relógio | Ponteiros andando com a hora do computador |
| Mesa no jantar | Pratos, panela e vapor aparecem quando a mãe põe a mesa |

**Jantar:** a mãe põe a mesa e senta na cabeceira esquerda. O jogador senta na cabeceira direita e os dois comem (animação de garfo à boca) enquanto conversam. As escolhas mostram o jogador levantando: ir até a mãe pegar o bebê, ou sair da mesa irritado.

## 10. Interface e identidade visual

**Identidade (logo do jogo e do estúdio):** natureza, caminho e as fases da vida, em traço de aquarela. Tons de **verde-escuro, rosa e pêssego** sobre creme. O cenário e os personagens são pixel art; a interface segue o logo.

| Elemento | Valor |
|---|---|
| Verde-escuro (texto, botões) | `#1F4B3B` / `#2F6B52` |
| Rosa (destaques, hover, bordas) | `#D9878A` / `#B9616A` |
| Pêssego (foco, Energia) | `#F4B183` / `#F4A672` |
| Creme (painéis) | `#FBF5EC` |
| Fonte | Quicksand (Google Fonts, licença OFL) |

| Tela | Conteúdo |
|---|---|
| Abertura | Logo do Estúdio Vívido sobre creme, com som de sino (qualquer tecla pula) |
| Cutscene do capítulo | Pixel art com os sprites do jogo, legenda de lugar no canto ("Mais cedo, na escola"), balões de fala curtos, emotes, "Segure E para pular" no canto |
| Menu inicial | Arte da casa ao fundo com papel creme à esquerda, logo flutuando de leve, pétalas de cerejeira caindo, Jogar / Configurações / Controles / Créditos / Sair, mãe e filho frente a frente, versão "Demo · Capítulo 1" |
| Configurações | Volume geral, música, efeitos e ambiente; tela cheia; velocidade do texto; texto grande (salvos em disco) |
| Controles | Teclado e controle lado a lado |
| Créditos | Estúdio, equipe, música original, fonte, agradecimentos e a licença do Godot (exigida para distribuir) |
| Título do capítulo | "Fase 1 — Família / Uma noite em casa" sobre a cena, some sozinho (estilo abertura de episódio) |
| Cartão de capítulo | Resumo do dia, "Você apagou de sono" e "Caiu em desgraça" |
| HUD | Canto superior esquerdo: Reputação (cor por faixa) e Energia. Topo: objetivo atual. Base: avisos rápidos |
| Evento de decisão | Faixas de cinema + cena curta; painel creme com título, contexto e opções A–D com custo de Energia; cena da escolha; o painel volta com o retorno e as variações. "Segure E para acelerar" no canto durante as cenas |
| Menu de pause | Esc ou P: logo, Continuar, Recomeçar a fase, Menu principal, Sair do jogo (escondido na versão web) |
| Indicador de interação | Texto creme com contorno verde acima do NPC ou objeto ("[E] Conversar") |

A paleta e a fonte seguem o logo. O layout das telas foi escolha de implementação, **a validar pelo grupo**.

### 10.1 Som
- **Música:** tema lo-fi original em loop (piano elétrico, baixo, bateria suave e sino), quente e um pouco melancólico, combinando com o pilar de reflexão. À noite fica abafada.
- **Ambiente:** casa de dia (relógio, geladeira); casa à noite (grilos).
- **Efeitos:** botões, passos na madeira, escolha, perda/ganho de Reputação, Energia, objetivo, memória, digitação e transição.
- Todo o áudio é **original**, gerado por código (`tools/generate_audio.py`), sem bancos de som: não há risco de licença para vender.
- Canais separados (Música, Efeitos, Ambiente), cada um com volume próprio nas Configurações.

### 10.2 Luz e passagem do tempo
A luz conta a história da noite: **fim de tarde** quente na Chegada → **anoitecer** no Jantar (luz sobre a mesa) → **noite** azulada em Antes de dormir (abajur e luz do corredor acesos).

### 10.3 Game feel
- Movimento com aceleração e desaceleração.
- Passos sonoros sincronizados com a animação e *squash & stretch* sutil a cada passo.
- Câmera aproxima durante as conversas.
- Painéis entram com animação.
- O texto aparece em máquina de escrever, com a opção de pular.
- As opções surgem em sequência.
- Números flutuantes e tremida do HUD ao perder Reputação.
- A mãe reage com "!".
- Pétalas no menu e fade entre telas.

### 10.4 Arte
O mapa e os personagens passam por uma limpeza automática que remove o aspecto de imagem gerada por IA (ruído, pixels de tamanhos diferentes e milhares de cores):
- **Mapa:** grade única de 4 px e 128 cores.
- **Personagens:** paleta de 32 cores cada, com bordas nítidas.

Os logos e a composição do mapa ainda pedem retoque humano (ver Em aberto).

### 10.5 Cutscenes: linguagem de cinema

| Recurso | Onde | Referência |
|---|---|---|
| Retratos em pixel art com expressões, piscando e mexendo a boca; quem escuta fica apagado | todas as falas | Celeste, Night in the Woods, Persona 5 |
| Voz por bipes com tom próprio de cada personagem; texto que treme no grito e ondula no carinho; pausas na pontuação | todas as falas | Undertale, Celeste |
| Impact frame (congela, negativo, flash, linhas de velocidade, aberração cromática) | professora acha a cola; "ME DEIXA EM PAZ!" | Persona 5, anime |
| Gradação de cor por clima (memória, tensão, frio, quente, noite) + vinheta e granulação | todas as cenas | linguagem de cor do cinema |
| Câmera com zoom, inclinação (dutch angle) e câmera lenta; plano detalhe da cola e do Lucas | abertura, conflitos | cinema |
| Celular em tela cheia: grupo da turma, conversa com o Lucas, story da indireta | rua, noite | Life is Strange |
| Cochichos da turma espalhados pela tela | sala de aula | Persona 5 |
| Cartão de capítulo animado; carimbo de hora e lugar; cortinas diagonais entre planos | abertura e início da fase | Persona 5, Life is Strange |
| Trilha por momento: tensão (drone + coração), melancolia (piano), calor (acorde que se abre) | abertura e resultados | — |
| Faixas de cinema e HUD escondido durante as cenas | casa | — |

Retratos: `tools/make_retratos.py` (4 personagens, 17 expressões, quadros de piscar e falar), desenhados pixel a pixel por código na paleta do jogo; a ficha está em `docs/arte/retratos_ficha.png`.

## 11. Controles

| Ação | Teclas |
|---|---|
| Mover | WASD ou setas · controle: analógico esquerdo ou D-pad |
| Interagir | E ou Espaço · controle: A / Xis |
| Pausar | Esc ou P · controle: Start |
| Pular o texto | Interagir ou clique |
| Navegar em menus e opções | Mouse, ou setas + Enter |

## 12. Escopo e estado

### Ciclo 1 — Núcleo Jogável
**Pergunta do ciclo:** o jogador consegue realizar a ação principal?

| Item | Estado |
|---|---|
| Um personagem em uma única fase de vida | Feito |
| Movimento livre e interação de cenário | Feito |
| Capítulo com objetivo, 3 momentos, Energia e memórias | Feito |
| Eventos com 2 a 4 opções alterando Reputação e Energia | Feito (3 momentos, 4 eventos) |
| Barra de Reputação com cor por faixa | Feito |
| Menu inicial, menu de pause, abertura do estúdio e identidade visual | Feito |
| Fim de jogo por Reputação em 0% | Feito (tela "Caiu em desgraça"; inalcançável com os valores atuais) |
| Fim de jogo por opção fatal | Não iniciado (nenhum evento tem opção fatal) |
| Build web e Windows para o itch.io | Feito |
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
| D22 | 16/10 | Nome do jogo: **ChosenZen**; slogan "Cada escolha, uma nova história." | Documento do logo do jogo (Fase 3) | seção 1 |
| D23 | 16/10 | Estúdio Vívido, "Ideias que ganham vida"; identidade em verde, rosa e pêssego | Documento do logo do estúdio (Fase 2) | seção 10 |
| D24 | 16/10 | Monetização Premium: R$ 19,90, sem anúncios obrigatórios, sem VIP, sem pay-to-win | A pesquisa de mercado apontou monetização agressiva como reclamação | documento de monetização (Fase 1) |
| D25 | 16/10 | Tensão das escolhas: **Reputação × Energia** (status novo, por capítulo) | Tirar o "quiz": nenhuma opção pode ser melhor em tudo | spec 003 |
| D26 | 16/10 | Fio da história da Fase 1: o personagem foi **acusado injustamente** de colar na prova | Liga a história ao tema da reputação | spec 003 |
| D27 | 16/10 | Fase 1 vira o capítulo "Uma noite em casa": objetivo terminar o dia, 3 momentos, resumo do dia | Responder o feedback sobre objetivo, obstáculos e progressão | spec 003 |
| D28 | 16/10 | Custo de Energia visível antes da escolha; efeito na Reputação só depois *(proposta, a validar)* | Energia permite planejar; Reputação escondida preserva o peso moral | spec 003 (RF-ENE-002) |
| D29 | 16/10 | Menu de pause e todos os menus na identidade do logo | Pedido do aluno | seção 10 |
| D30 | 16/10 | Publicação no itch.io: o aluno cria a página e envia o zip | Contas e login são do aluno | [publicacao-itch.md](publicacao-itch.md) |
| D31 | 16/10 | Trilha e efeitos originais, gerados por código | Slides de áudio; sem risco de licença para vender | seção 10.1 |
| D32 | 16/10 | A luz marca a passagem do tempo (tarde → noite) | Slides de luz; reforça a narrativa da noite | seção 10.2 |
| D33 | 16/10 | Aviso de "memória" após escolhas com consequência | Mostrar que a história vai a algum lugar (feedback do professor) | seção 4.2 |
| D34 | 16/10 | Menu com Configurações, Controles e Créditos; suporte a controle | Checklist de UI/UX e acessibilidade dos slides | seção 10 |
| D35 | 16/10 | Limpeza automática do mapa e dos sprites (grade e paleta) | "Arte sem cara de IA" | seção 10.4 |
| D36 | 16/10 | O build publicado é a **Demo do Capítulo 1**; o preço de R$ 19,90 vale para o jogo completo | Publicar de forma honesta com o conteúdo atual | press kit |
| D40 | 16/10 | A casa vira **mapa modular em pixel art** (fundo + móveis separados), com assentos, interações e animações; jogador e mãe ganham poses de **sentar e comer**; o jantar acontece sentado à mesa | Pedido do aluno: o mapa era uma imagem só, sem como sentar ou interagir. Também resolve a "cara de IA" do mapa (item em aberto 12) | seção 9, [ADR 0008](adr/0008-casa-modular.md) |
| D39 | 16/10 | **Linguagem de cinema nas cutscenes**: retratos com expressões, diálogo no ritmo do jogador, impact frame, câmera inclinada e lenta, gradação de cor por clima, celular em tela cheia, cartão de capítulo e cortinas diagonais, trilha por momento | Pedido do aluno: cutscenes profissionais, impactantes e bonitas; referências em Persona 5, Celeste, Night in the Woods, Life is Strange | seção 10.5, [ADR 0007](adr/0007-linguagem-de-cinema.md) |
| D38 | 16/10 | Cada enquete ganha uma **cena curta antes** (a situação) e **outra depois** (o personagem fazendo o que foi escolhido); o resultado só aparece depois da cena | Pedido do aluno: jogo mais dinâmico e visual; a consequência pesa mais quando o jogador vê a ação | seção 5.1.1, [ADR 0006](adr/0006-cenas-antes-e-depois-das-enquetes.md) |
| D37 | 16/10 | A abertura do capítulo vira **cutscene animada** (escola → rua → porta), e o cartão de texto sai | Pedido do aluno: contar visualmente, não com texto. Também mostra a pista do Lucas | seção 7, [ADR 0005](adr/0005-cutscene-de-abertura.md) |

Decisões técnicas (arquitetura, colisões, profundidade) ficam nos ADRs, não aqui.

## 14. Em aberto

**Design**
1. **Público-alvo.**
2. **Ritmo** (eixo estrutural).
3. **Caráter × Reputação:** como um influencia o outro.
4. **O que é uma "Fase":** na implementação, cada Fase virou um capítulo dentro de uma etapa da vida (Fase 1 — Família, Fase 2 — Escola...). Confirmar se é isso.
5. **Limite do desfazer:** 3 usos pela vida toda ou recarrega por fase?
6. **Desfazer × monetização:** o documento de monetização diz "sem assinatura VIP", mas a mecânica de desfazer prevê uma tela *simulada* de assinatura de R$30/mês como crítica social. Os jogadores podem ler isso como monetização de verdade, justamente o que a pesquisa apontou como reclamação. Manter, mudar ou explicar no jogo?
7. **Reputação começa em 100%:** efeitos positivos no início não aparecem (já está no máximo).
8. **Energia:** só por capítulo ou um status da vida toda?
9. **Correr, pular e cair:** a arte existe; há mecânica planejada?
10. **Vários NPCs por cenário** nas próximas fases?
11. **Tela de fim de jogo:** hoje é um cartão simples ("Caiu em desgraça"); o que ela deve mostrar?
12. **Arte com cara de IA:** o mapa foi redesenhado (seção 9.1); os logos ainda parecem gerados por IA. Antes de vender, o ideal é redesenhar ou retocar os logos à mão.
13. **Nomes da equipe** para os créditos.

**A validar**
- Textos do Jantar, de Antes de dormir e do resumo do dia (seção 7).
- Layout das telas (seção 10).
- Valores de Energia e Reputação (spec 003).
- Playtest humano do capítulo.

## 15. Mapa dos documentos

| Documento | Para quê |
|---|---|
| [context/game-overview.md](context/game-overview.md) | Visão, loop, escopo e decisões da sessão de design, com a origem de cada uma |
| [context/gameplay-pillars.md](context/gameplay-pillars.md) | Pilar de design |
| [context/glossary.md](context/glossary.md) | Termos do jogo |
| [specs/001-sistema-de-decisoes.md](specs/001-sistema-de-decisoes.md) | Requisitos de eventos, Reputação e fim de jogo |
| [specs/002-movimento-e-interacao-de-cenario.md](specs/002-movimento-e-interacao-de-cenario.md) | Requisitos de movimento, interação e NPC |
| [specs/003-capitulo-energia-e-narrativa.md](specs/003-capitulo-energia-e-narrativa.md) | Level design da Fase 1: capítulo, Energia, memórias, resumo |
| [publicacao-itch.md](publicacao-itch.md) | Como publicar no itch.io e texto da página |
| [checklist-reta-final.md](checklist-reta-final.md) | O que os slides da reta final pedem e o status de cada item |
| [../presskit/index.html](../presskit/index.html) | Press kit |
| [context/cycle.md](context/cycle.md) | Estado do ciclo atual |
| [context/progress-tracker.md](context/progress-tracker.md) | O que está implementado e como foi validado |
| [context/learning-journal.md](context/learning-journal.md) | Aprendizados de cada unidade |
| [adr/](adr/) | Decisões técnicas |
