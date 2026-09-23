# Progress Tracker

## Ciclo 1 — Núcleo Jogável

**Specs em implementação:** [001-sistema-de-decisoes.md](../specs/001-sistema-de-decisoes.md), [002-movimento-e-interacao-de-cenario.md](../specs/002-movimento-e-interacao-de-cenario.md)

### Unidades de implementação planejadas

| Unidade | Requisitos | Status |
|---|---|---|
| U0 — Movimento livre + interação de cenário | RF-MOV-001, RF-MOV-002 | IMPLEMENTADA (não playtestada) |
| U1 — Evento aleatório com opções (conteúdo: Fase 1 — Família) | RF-AGE-001 | IMPLEMENTADA (não playtestada) |
| U2 — Reputação e barra com cor | RF-AGE-002, RF-AGE-003 | PARCIAL — reputação é aplicada e mostrada como número no feedback do evento (RF-AGE-002); a barra com cor dinâmica (RF-AGE-003) ainda não existe |
| U3 — Condições de fim de jogo | RF-AGE-004, RF-AGE-005 | NÃO INICIADA |

### Projeto Godot
Criado em `chozen-zen/` (Godot 4.7.2). Cena principal: `scenes/phase1_casa.tscn` (`run/main_scene`).

- `scripts/game_state.gd` — autoload `GameState`, guarda a Reputação (100 → clamp 0-100) e emite `reputation_changed`.
- `scripts/player.gd` + `scenes/player.tscn` — `CharacterBody2D` com `AnimatedSprite2D` (idle/walk × 4 direções, `assets/sprites/jogador/jogador_frames.tres`), input `move_up/down/left/right` (setas + WASD).
- `scripts/mae_npc.gd` + `scenes/mae.tscn` — `StaticBody2D` parado (idle_down), `Area2D` de interação (raio 48px), prompt "Pressione E", emite `talk_requested` uma única vez por sessão.
- `scripts/decision_ui.gd` + `scenes/decision_ui.tscn` — `CanvasLayer` (sempre processa, mesmo com `get_tree().paused = true`) que monta os botões a partir de um dicionário de evento, aplica o delta em `GameState` e mostra o feedback.
- `scripts/phase1_casa.gd` + `scenes/phase1_casa.tscn` — sala em blocos cinzas (chão, 4 paredes, uma mesa), câmera estática, conecta a mãe à UI de decisão. Contém o conteúdo do evento "Fase 1 — Família" (4 opções, deltas 0/-2/-5/-8).
- Camadas de física: 1 = cenário (paredes/mesa/corpo da mãe), 2 = jogador. `InteractionArea` da mãe usa `collision_mask = 2`.

Rodado via `godot-mcp` (`run_project` / `get_debug_output`): carregou sem erros. **Ainda não foi verificado visualmente nem jogado por um humano** — a janela do jogo não pôde ser inspecionada por computer-use nesta sessão (processo sem entrada no menu Iniciar). Falta playtest real antes de fechar a unidade.

### Bloqueios conhecidos
Nenhum bloqueio de design pendente para U0/U1. Perguntas em aberto de conteúdo (quantidade de eventos, próximas fases) continuam não bloqueando a arquitetura. Próximo bloqueio real: **playtest humano** desta cena antes de avançar para U2 (barra de Reputação) ou para novas fases.
