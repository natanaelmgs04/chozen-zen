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

**Perguntas em aberto:**
- Nome do jogo: o menu mostra "Chozen Zen" (nome do projeto Godot); o `game-overview.md` diz que o nome ainda não foi decidido.
- Fonte pixel para combinar com a arte (precisa baixar uma fonte com licença livre).
