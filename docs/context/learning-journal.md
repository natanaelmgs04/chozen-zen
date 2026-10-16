# Learning Journal

## 2026-09-23 — U0/U1: protótipo da Fase 1 (Família)

**O que foi implementado:** projeto Godot criado do zero; cena `phase1_casa.tscn` com sala em blocos cinzas, jogador controlável (idle/walk × 4 direções, sprites já recortados), mãe parada como NPC de interação, e o evento de decisão "Fase 1 — Família" (4 opções, deltas de Reputação 0/-2/-5/-8) aplicando o valor no autoload `GameState`.

**Decisão de escopo tomada durante a sessão:** o aluno pediu explicitamente movimento livre para esta cena, revertendo a exclusão de "movimento livre e interações" que `game-overview.md` tinha marcado como fora do escopo do Ciclo 1. Isso foi levantado como pergunta antes de implementar (não decidido silenciosamente) e documentado em `game-overview.md` + na nova spec [002](../specs/002-movimento-e-interacao-de-cenario.md).

**Validação até agora:** só técnica — a engine (Godot 4.7.2, via `godot-mcp`) carrega a cena e roda sem nenhum erro/warning no log. **Nenhum playtest humano ainda.** A janela do jogo não pôde ser inspecionada visualmente nesta sessão porque o processo lançado pela MCP não tem entrada no menu Iniciar do Windows, e a ferramenta de computer-use só controla apps da allowlist do sistema — não foi possível confirmar visualmente cores, alinhamento dos sprites (pés no chão) ou a legibilidade do prompt "Pressione E".

**Ideias/perguntas levantadas, ainda sem decisão:**
- Se o conteúdo de eventos crescer, vale migrar de `Dictionary` inline para um `Resource` reutilizável (ver ADR 0001).
- Ainda não há barra de Reputação visível permanentemente (RF-AGE-003) — a Reputação só aparece no texto de feedback depois de decidir.
- Não há transição entre fases nem tela de fim — fora do escopo desta unidade.

**Próximo passo recomendado:** playtest humano real da cena (abrir no editor Godot ou rodar o projeto, andar até a mãe, testar as 4 opções) antes de avançar para U2 (barra de Reputação com cor) ou para uma nova fase.

## 2026-09-30 — U2 + U4: arte da Fase 1, menu inicial, HUD, mãe em movimento

**Feedback do aluno que originou a unidade:** a mãe parada "fica meio sem sentido"; o jogador parecia "entrar dentro" dela; pedido da arte final do mapa, menu inicial e HUD de Reputação.

**O que foi implementado:** arte da casa como fundo com 18 colisões conferidas sobre a imagem; y-sort entre personagens; mãe circulando pela casa e se virando para o jogador (nova RF-MOV-003); HUD de Reputação conforme RF-AGE-003; menu inicial com a paleta da arte; tema visual global; título e letras A-D no diálogo.

**Aprendizados técnicos:**
- *Y-sort sozinho não resolve sobreposição* quando os personagens têm cabeça grande: foi preciso aumentar a distância mínima (colisão circular na mãe).
- *Móveis desenhados no fundo* não participam do y-sort; cobrir a pegada visual inteira com colisão evita o jogador "atravessar" visualmente os móveis.
- `CanvasLayer.layer` define o que fica por cima: o HUD precisou ir para a camada 11 para não ser escurecido pelo fundo do diálogo (camada 10).
- Arrays tipados (`Array[Vector2]`) não aceitam atribuição de `[]` sem tipo — use `.clear()`.

**Validação:** agora visual, com screenshots gerados por `tools/screenshot_runner.tscn` (menu, início da fase, colisão com a mãe por 3 lados, diálogo, HUD após escolha, mãe em movimento). Ainda falta playtest humano.

**Perguntas em aberto (resolvidas em 2026-10-16):** o nome é ChosenZen; a fonte escolhida foi a Quicksand, que combina com o logo em aquarela.

## 2026-10-16 — U5–U7: level design, identidade, pause e itch.io

**Feedback do professor que originou a unidade:** faltava desafio, objetivo, obstáculos e progressão, e a narrativa parecia um quiz.

**Diagnóstico:** com um só recurso (Reputação) e todas as opções negativas, sempre existia uma opção dominante, e escolher virava "acertar a resposta". **Lição de design:** uma escolha só é difícil quando cada opção custa algo diferente. Por isso entrou um segundo recurso, a Energia, que puxa para o lado oposto.

**Decisões do aluno:** Reputação × Energia; história do acusado injustamente; publicação por zip enviado por ele.

**Aprendizados técnicos:**
- Conteúdo separado da lógica (`fase1_roteiro.gd`): mudar texto e valores não mexe na máquina de momentos.
- Um único `StoryCard` serve para abertura, resumo, "apagou" e "desgraça".
- Pixel art pede filtro *nearest*, mas logo e texto em aquarela pedem *linear*: o padrão do projeto virou linear e só o mapa e os personagens forçam *nearest*.
- Na primeira importação, o tema falhou porque carregou antes da fonte; uma segunda importação resolveu.
- A versão web do Godot 4.7 sem threads roda em qualquer servidor (não precisa de cabeçalhos especiais), o que simplifica o itch.io.
- O pacote web caiu de 6,1 MB para 2,9 MB ao excluir `assets/source/` da exportação.

**Validação:** screenshots de todo o fluxo e versão web testada no navegador embutido. Ainda falta playtest humano, principalmente para balancear a Energia.

## 2026-10-16 — U8: polimento da reta final

**Origem:** slides "Finalizando o jogo" (polish, áudio, luz, game feel, princípios de animação, "arte sem cara de IA", controles, apresentação, publicação, press kit).

**Aprendizados:**
- **Pixel art de IA tem assinatura mensurável:** o mapa tinha cerca de 45 mil cores e pixels de tamanhos diferentes; os sprites, cerca de 4.200 cores por personagem. A limpeza funciona em quatro passos: tirar o ruído, reduzir para a grade real, quantizar sem dithering e ampliar com vizinho mais próximo. Quantizar com poucas cores (48) criou manchas; 128 cores no mapa e 32 por personagem ficaram limpos.
- **Áudio por síntese** é viável para protótipo e elimina o risco de licença. A convolução de reverb precisa ser via FFT: a direta travou o script.
- **Juice sem poluir:** tudo dura entre 0,1 e 0,4 s e usa *ease out*; os bipes de digitação tocam a cada 3 letras, em volume baixo.
- `Camera2D.offset` **ignora os limites** da câmera: foi preciso limitar o offset na mão para não mostrar a área fora da casa.
- Tweens criados com a árvore pausada só rodam com `TWEEN_PAUSE_PROCESS` ou num nó `PROCESS_MODE_ALWAYS`.
- No build web, testar sempre sem cache (porta nova): o navegador reaproveitou o `.pck` antigo e pareceu um bug de tela.

**Moodboard:** o professor também comentou o moodboard (deve ser uma colagem de referências). Isso é um entregável do grupo, fora do código, e não foi feito aqui.

## 2026-10-16 — U9: cutscene de abertura

**Pedido do aluno:** trocar o texto que contava o que aconteceu na escola por uma "animaçãozinha, tipo uma cutscene".

**Decisões:** cutscene no próprio Godot, com os sprites do jogo e cenários desenhados por código numa grade de 4 px. Só o protagonista tem cor; colegas e professora são silhuetas. Três planos: sala de aula (a cola), rua no pôr do sol (o grupo da turma) e a porta de casa (a mãe na janela). Ver [ADR 0005](../adr/0005-cutscene-de-abertura.md).

**Aprendizados:**
- **Mostrar, não contar:** a gota de suor no Lucas planta a pista de quem era a cola sem nenhuma linha de texto, e a escolha "perguntar ao Lucas" à noite ganha sentido.
- **Falta de arte vira direção de arte:** sem sprites de colegas, a silhueta é uma escolha que comunica (solidão, julgamento).
- `PanelContainer` reposiciona todos os filhos: o rabinho do balão precisou ficar fora dele, num `Control` comum.
- Arrays constantes sem tipo não entram em parâmetros `Array[Color]`: é preciso deixar o parâmetro sem tipo ou tipar a constante.
- Para "sentar" um personagem que só tem sprites em pé, recorte o sprite na cintura (`region_rect`) e desenhe o encosto da cadeira por cima.
- Esperas da cutscene com `Timer` filho da cena: ao pular, a cena some e a linha do tempo morre junto, sem erro.

**Validação:** screenshots dos três planos e da entrada na fase; execução completa e pulo sem erros. Ainda falta ouvir o áudio e um playtest humano para ver se o ritmo (cerca de 40 s) não cansa.
- **Feedback do aluno (mesmo dia):** a professora em silhueta "parecia um monstro". Ela ganhou sprites em pixel art desenhados por código (`tools/make_professora.py`): formas simples + contorno automático, na mesma grade de 4 px. Lição: silhueta só funciona com uma forma humana reconhecível; uma pilha de retângulos não lê como pessoa. Duas iterações foram necessárias (cabeça pontuda → arredondada; olhos que pareciam óculos escuros → lente clara com olho de 1 pixel).

## 2026-10-16 — U10: cenas antes e depois das enquetes

**Pedido do aluno:** pequenas cutscenes antes e depois de cada enquete, para mostrar visualmente a situação e o que foi escolhido.

**Decisão de design:** a ordem passou a ser **cena → escolha → cena → resultado**. Ver a ação antes dos números faz a consequência pesar; ver primeiro o "−8%" e depois a cena seria só uma ilustração. Ver [ADR 0006](../adr/0006-cenas-antes-e-depois-das-enquetes.md).

**Aprendizados técnicos:**
- Tipar uma variável com um nó já liberado dá erro *antes* do `is_instance_valid`: checar primeiro, tipar depois.
- `set_anchors_preset` em `ColorRect` criado por código e posto num `CanvasLayer` deixou a largura zerada; definir `anchor_*` e `offset_*` explicitamente resolveu.
- Um emote reaproveitado sumia antes da hora: o tween de "esconder" do emote anterior continuava rodando. Ao mostrar um novo, matar o tween antigo.
- O `offset` da câmera é relativo ao jogador; para enquadrar uma cena em que ele anda, é preciso recalcular o `offset` a cada quadro a partir de um ponto fixo do mundo.
- `Engine.time_scale` acelera tweens e timers de uma vez (bom para "segurar para acelerar"), mas precisa voltar a 1 no pause, senão o menu também acelera.

**Validação:** screenshots de todas as enquetes e de vários caminhos; sem erros. Falta playtest para ver se as cenas, somadas, não deixam o capítulo arrastado (por isso existe a aceleração).

## 2026-10-16 — U11: cutscenes com linguagem de cinema

**Pedido do aluno:** cutscenes muito profissionais, impactantes e bonitas, pesquisando jogos que usam bastante esse recurso.

**Pesquisa e escolhas:**
- Persona 5: tipografia e transições como identidade, impact frames, cochichos.
- Celeste: texto que se mexe para dar ênfase, retratos com expressão.
- Life is Strange: o celular como interface narrativa.
- Guias de game feel: hit-stop curto (50 a 150 ms), efeitos empilhados (flash + tremor + partículas) e tremor contido.

**Aprendizados técnicos:**
- Em shader de `canvas_item`, `SCREEN_PIXEL_SIZE` só existe dentro de `fragment()`: funções auxiliares precisam recebê-lo como parâmetro.
- Desfoque por mipmap da tela não é garantido na web; amostras manuais funcionam nos dois renderizadores.
- `Engine.time_scale` congela também os efeitos; os tweens dos efeitos precisam de `set_ignore_time_scale(true)`.
- Tween criado por um nó pausável não roda enquanto a enquete pausa o jogo: `set_pause_mode(TWEEN_PAUSE_PROCESS)`.
- `z_index` vence a ordem dos filhos: a plaquinha do nome precisou de `z_index` maior que o do retrato ativo.
- Arrays literais não entram em parâmetros `Array[String]`; para APIs de conteúdo, parâmetro sem tipo é mais prático.

**Validação:** capturas de todos os momentos e teste no navegador. Pendente: playtest para ritmo e leitura das falas, e ouvir a trilha nova.

## 2026-10-16 — U12: casa modular, sentar e jantar à mesa

**Pedido do aluno:** refazer o mapa para permitir animações e interações (sentar nas cadeiras e no sofá), o jantar com os dois sentados comendo e as poses de sentar.

**Aprendizados:**
- **Profundidade em top-down é escolha de ponto de ordenação**, não de camada. Cada móvel ordena por uma linha diferente (encosto, borda da frente da mesa), conforme o que deve cobrir quem.
- **Gerar arte e dados juntos** evita que colisão, zona e sprite saiam do lugar quando a arte muda.
- **Poses derivadas** (tronco original + pernas redesenhadas) mantêm o personagem reconhecível e custam muito menos que redesenhar o sprite.
- Câmera: além do offset não respeitar os limites, a *base* da câmera também é presa por eles perto das paredes. O offset precisa partir da base já limitada.
- Um sinal emitido no meio de uma cutscene (`levantou`) religou as zonas de sentar; o estado "zonas ativas" precisa ser global, não só por evento.

**Validação:** capturas de todos os pontos novos. Falta playtest para ver se as interações são encontradas naturalmente e se o tempo da mãe até a mesa está bom.
