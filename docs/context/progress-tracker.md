# Progress Tracker

## Ciclo 1 — Núcleo Jogável

**Specs em implementação:** [001-sistema-de-decisoes.md](../specs/001-sistema-de-decisoes.md), [002-movimento-e-interacao-de-cenario.md](../specs/002-movimento-e-interacao-de-cenario.md)

### Unidades de implementação planejadas

| Unidade | Requisitos | Status |
|---|---|---|
| U0 — Movimento livre + interação de cenário | RF-MOV-001, RF-MOV-002 | IMPLEMENTADA — sobreposição jogador/mãe corrigida em 2026-09-30 (não playtestada por humano) |
| U1 — Evento aleatório com opções (conteúdo: Fase 1 — Família) | RF-AGE-001 | IMPLEMENTADA (não playtestada por humano) |
| U2 — Reputação e barra com cor | RF-AGE-002, RF-AGE-003 | IMPLEMENTADA — HUD no canto superior esquerdo (barra + número, vermelho ≤20 / amarelo 21-80 / verde ≥81) |
| U3 — Condições de fim de jogo | RF-AGE-004, RF-AGE-005 | NÃO INICIADA |
| U4 — Arte da Fase 1, menu inicial, mãe em movimento | RF-MOV-003 + pedidos visuais do aluno | IMPLEMENTADA (validada por screenshots, não playtestada por humano) |
| U5 — Level design: capítulo, Energia, memórias, resumo | RF-CAP-001..003, RF-ENE-001..003 (spec 003) | IMPLEMENTADA (validada por screenshots e na versão web; não playtestada por humano) |
| U6 — Identidade ChosenZen, menu de pause, abertura do estúdio | Pedidos do aluno + logos | IMPLEMENTADA |
| U7 — Builds para o itch.io | — | Web e Windows gerados em `build/`; página a ser criada pelo aluno |
| U8 — Polimento da reta final (slides do professor) | Áudio, luz, game feel, UI/UX, acessibilidade, controle, arte sem cara de IA, press kit | IMPLEMENTADA — ver [checklist-reta-final.md](../checklist-reta-final.md) |
| U12 — Casa modular, sentar e jantar à mesa | Mapa redesenhado em peças (móveis com profundidade e colisão), sofá e 6 cadeiras para sentar, abajur/TV/geladeira animados, comentários nos objetos, poses de sentar e comer, jantar sentado | IMPLEMENTADA — ver [ADR 0008](../adr/0008-casa-modular.md) |
| U11 — Cutscenes com linguagem de cinema | Retratos com expressões, diálogo animado, impact frame, gradação de cor, câmera inclinada/lenta, celular em tela cheia, cartão de capítulo, trilha por momento | IMPLEMENTADA — ver [ADR 0007](../adr/0007-linguagem-de-cinema.md) |
| U10 — Cenas antes e depois das enquetes | Cena curta encenando a situação, a enquete, a cena da escolha e só então o resultado; 16 cenas de escolha | IMPLEMENTADA — ver [ADR 0006](../adr/0006-cenas-antes-e-depois-das-enquetes.md) |
| U9 — Cutscene de abertura | A história da escola contada em animação (sala → rua → porta) no lugar do cartão de texto | IMPLEMENTADA — ver [ADR 0005](../adr/0005-cutscene-de-abertura.md) |

### Atualização 2026-10-16 (U12)
- `tools/make_casa.py` → `assets/casa/` (fundo, móveis, `casa.json`, `casa_completa.png` para o menu); `scripts/casa/casa.gd`, `scripts/casa/relogio.gd`.
- `tools/make_sentado.py` → `sit_*`/`eat_*` do jogador e da mãe (e animações nos SpriteFrames).
- `player.gd`: `sentar`, `levantar`, `comer`, `pode_levantar`. `mae_npc.gd`: `sentar`, `levantar(saida)`, `comer`, `settle_at(..., sit)`.
- `phase1_casa.tscn`: o mapa aponta para o fundo novo e as 18 colisões antigas saíram (vêm da ficha). Zonas, luzes e o caminho da mãe são posicionados pela ficha.
- Jantar reescrito em `fase1_cenas.gd` com os dois sentados e comendo.
- Validação: capturas da casa, do sofá, das cabeceiras, do jantar (antes, enquete, pegar o bebê, sair da mesa), da TV, da noite e do menu, sem erros.

### Atualização 2026-10-16 (U11)
- `scripts/cinema/`: `cinema_fx.gd`, `dialogo.gd`, `retrato.gd`, `celular.gd`, `letreiros.gd`; `assets/shaders/cinema_pos.gdshader`; `assets/retratos/` (gerados por `tools/make_retratos.py`).
- Abertura reescrita: abertura fria com carimbo, travelling, plano detalhe da cola em câmera lenta, impact frame, diálogo com retratos e cochichos, plano do Lucas, grupo da turma no celular, monólogo interno, porta com a luz estourando.
- Casa: todas as 20 cenas (4 "antes" e 16 "depois") com retratos e falas reescritas, climas de cor, impacto no "grosseiro", celular com o Lucas e o story da indireta; cartão de capítulo animado no início.
- Trilha nova em `generate_audio.py` (`main_cutscene_v2`): tensão, melancolia, impacto, swoosh, batimento, calor. `Audio.sfx_pitch` para as vozes.
- Validação: sequências de capturas da abertura e das cenas da casa (todos os caminhos principais rodando até o resultado e o fim do dia), sem erros; build web testado no navegador (pós-processamento, diálogo e retratos funcionando, console sem erros).

### Atualização 2026-10-16 (U10)
- `scripts/diretor_casa.gd`, `scripts/data/fase1_cenas.gd`, `scripts/cutscene/baloes.gd` (balões compartilhados com a abertura).
- `decision_ui.gd`: `before_result` (painel some → cena → resultado). `phase1_casa.gd`: `_abrir_evento` com cena antes; câmera presa a um foco durante as cenas; close de 1,9 à noite.
- `mae_npc.gd`: `scripted`, `walk_to`, `face`, `face_towards`. `player.gd`: `face`.
- Emotes novos (coração, raiva, zzz, nota, choro, livro, triste) e sons (bebê chorando, talheres, página, notificação).
- Validação: screenshots da chegada (antes, enquete, abraço, resultado, grosseiro), da variante do corredor, do jantar nas duas versões, de "pegar o bebê" e da noite (Lucas, indireta, estudar); caminho de Energia baixa; abertura conferida depois da troca dos balões. Sem erros no log.

### Atualização 2026-10-16 (U9)
- Fluxo: splash → menu → **`scenes/cutscene_intro.tscn`** → `phase1_casa.tscn` (o jogador entra pela porta e o título do capítulo aparece).
- `scripts/cutscene_intro.gd` (diretor), `scripts/cutscene/` (`pixel.gd`, `aluno.gd`, `professora.gd`, `emote.gd`, `cena_sala.gd`, `cena_rua.gd`, `cena_porta.gd`), `assets/shaders/silhueta.gdshader`.
- Sons novos em `tools/generate_audio.py` (`main_cutscene()`): ambiente de sala e de rua, papel, sting, cochichos, celular, porta, pop de emote. Os sons antigos continuam idênticos.
- Câmera da fase limitada a y 960, para não mostrar a faixa fora da casa.
- Validação: screenshots dos três planos e da entrada na fase; execução completa e o caminho de pular (segurando E), sem erros no log.

### Atualização 2026-10-16 (U8)
- Autoloads novos: `Settings` (volumes, tela cheia, velocidade/tamanho do texto → `user://settings.cfg`), `Audio` (canais Music/SFX/Ambience em `default_bus_layout.tres`, sons e reação de escala em todo botão), `Transition` (fade entre cenas).
- `tools/generate_audio.py` gera trilha, ambiências e efeitos (`assets/audio/*.wav`).
- `scenes/ui/` com `settings_panel`, `controls_panel`, `credits_panel` (base `OverlayPanel`); usados no menu e no pause.
- Fase: `CanvasModulate` + 4 `PointLight2D` com presets por momento; câmera foca durante conversas (offset limitado à casa); memórias no HUD; grilos e música abafada à noite.
- Painel de decisão: máquina de escrever pulável, entrada animada, opções em sequência. HUD: números flutuantes, tremida, pulso do objetivo.
- Arte: `tools/prepare_map.py` (grade 4 px + 128 cores) e `tools/clean_sprites.py` (32 cores por personagem).
- Controle (gamepad) no mapa de input. Press kit em `presskit/` (+ `tools/make_store_art.py` para capa e banner).
- Validação: screenshots de menu, painéis, tarde, noite, conversa, memória e fim do dia; build web testado no navegador (tela inteira, sem erros no console). Atenção: ao testar o build web localmente, o navegador pode usar o pacote antigo do cache.

**Atualização (2026-10-16):** U3 parcial — a tela "Caiu em desgraça" (RF-AGE-004) existe, mas é inalcançável com os valores atuais; RF-AGE-005 (opção fatal) continua sem conteúdo.

### Projeto Godot
`chozen-zen/` (Godot 4.7.2), janela 1280×720. Cena inicial: `scenes/main_menu.tscn` → botão Jogar → `scenes/phase1_casa.tscn`.

- `ui/theme.tres` — tema global (`gui/theme/custom`): painéis marrom-escuro com borda de madeira, botões de madeira, texto bege com contorno. Paleta tirada da arte do mapa.
- `scripts/game_state.gd` — autoload `GameState`: Reputação (100, clamp 0-100), `reset()` ao iniciar um jogo, sinal `reputation_changed`.
- `scripts/main_menu.gd` + `scenes/main_menu.tscn` — arte da casa ao fundo com degradê, título, subtítulo (pitch), Jogar/Sair, mãe e filho em escala 3× frente a frente, rodapé com controles.
- `scripts/hud.gd` + `scenes/hud.tscn` — HUD de Reputação (camada 11, fica por cima do diálogo para o jogador ver a mudança). Barra anima em 0,4 s.
- `scripts/player.gd` + `scenes/player.tscn` — `CharacterBody2D` (modo flutuante/top-down), colisão nos pés 32×20, velocidade 130.
- `scripts/mae_npc.gd` + `scenes/mae.tscn` — `CharacterBody2D` que circula entre `waypoints` (exportados, definidos na cena da fase) com pausas de 1,5-3,5 s; para e se vira para o jogador dentro da área de interação (raio 90). Colisão circular de raio 42 ("espaço pessoal") para os dois não se fundirem. Prompt "[E] Conversar".
- `scripts/decision_ui.gd` + `scenes/decision_ui.tscn` — título do evento, opções com letras A-D, foco por teclado, feedback + Continuar.
- `scenes/phase1_casa.tscn` — `Mapa` (Sprite2D com `assets/maps/fase1_casa.png`), `Colisoes` (18 retângulos: paredes, pilares, estante, quadro, abajur, TV, planta, sofá, mesa de centro, mesa de jantar, aparador), `Entities` com **y-sort** (jogador + mãe), câmera seguindo o jogador com limites da casa, HUD e DecisionUI. Jogador começa na porta de entrada.
- `assets/maps/fase1_casa.png` — gerado por `tools/prepare_map.py` a partir de `assets/source/fase1_casa_mapa.jpg` (arte enviada pelo aluno; exterior branco vira transparente).
- `tools/screenshot_runner.tscn` — ferramenta de dev: roda uma cena, simula input e salva um PNG (ver cabeçalho do script). Usada para validar esta unidade.
- Camadas de física: 1 = cenário + corpo da mãe, 2 = jogador. Mãe colide com 1 e 2.

### Validação (2026-09-30)
Screenshots gerados com `tools/screenshot_runner.tscn`: menu inicial; início da fase (jogador na porta, HUD 100% verde); jogador andando contra a mãe por baixo, por cima e pela lateral (sem fusão, y-sort correto); diálogo aberto; após escolher D (HUD 92%, feedback correto); mãe em posições diferentes em 2 s e 7 s. Nenhum erro de script no log.

### Atualização 2026-10-16 (U5–U7)
- Cena inicial agora é `scenes/splash.tscn` (logo do Estúdio Vívido) → `main_menu.tscn` (logo ChosenZen) → `phase1_casa.tscn`.
- `scripts/data/fase1_roteiro.gd` — todo o texto e os valores do capítulo (eventos, variações por memória, resumo).
- `scripts/phase1_casa.gd` — máquina de momentos (INTRO → CHEGADA → JANTAR → NOITE → FIM), zonas, objetivo, seta, Energia 0, desgraça.
- `scripts/game_state.gd` — Energia (50 por capítulo), memórias (`flags`), `apply_option()`.
- Novas cenas: `story_card` (abertura/resumo/fim), `pause_menu` (Esc/P), `splash`; `trigger_zone.gd` (geladeira, mesa, porta), `objective_marker.gd`.
- `ui/theme.tres` refeito com a paleta do logo e a fonte Quicksand (`assets/fonts`, OFL). Filtro de textura padrão agora é linear; mapa e personagens forçam *nearest*.
- `export_presets.cfg` (Web sem threads, Windows); builds e zips em `../build/` (no `.gitignore` da raiz). Passo a passo em [publicacao-itch.md](../publicacao-itch.md).
- Validação: screenshots (abertura, menu, cartão do capítulo, exploração com objetivo, evento com custos, opções bloqueadas, pause, fim do dia, apagou de sono) e a versão web rodando no navegador (WebGL, sem erros no console).

### Bloqueios conhecidos
- **Playtest humano** ainda pendente (balanceamento da Energia, clareza do objetivo, textos novos).
- Página do itch.io: precisa ser criada pelo aluno (conta e login são dele).
