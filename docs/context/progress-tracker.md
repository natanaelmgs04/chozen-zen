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

### Bloqueios conhecidos
- **Playtest humano** ainda pendente (sensação do movimento, ritmo da mãe, clareza do diálogo).
- O título no menu usa "Chozen Zen" (nome do projeto Godot/repositório); `game-overview.md` ainda diz que o nome não foi definido. Trocar o texto do `Titulo` em `main_menu.tscn` se o grupo decidir outro.
- A fonte ainda é a padrão do Godot; uma fonte pixel combinaria mais com a arte (depende de baixar uma fonte com licença livre).
