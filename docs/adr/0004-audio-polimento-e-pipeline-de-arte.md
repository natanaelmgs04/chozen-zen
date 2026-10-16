# ADR 0004 — Áudio, polimento global e pipeline de arte

**Data:** 2026-10-16
**Status:** aceito

## Contexto

A reta final pede áudio, luz, game feel, acessibilidade, controle, transições e "arte sem cara de IA", tudo pronto para publicação comercial.

## Decisões

**Três autoloads de serviço: `Settings`, `Audio`, `Transition`.**
São usados por todas as cenas. Centralizar evita repetir a mesma lógica (volume, sons de botão, fade) em cada menu.

**Sons de botão ligados globalmente via `SceneTree.node_added`.**
Todo `BaseButton` criado ganha som de hover/clique e uma leve reação de escala, inclusive os botões criados por código (opções do diálogo). Nenhuma cena precisa lembrar de ligar isso.

**Canais de áudio (`default_bus_layout.tres`): Master → Music (com passa-baixa), SFX, Ambience.**
Permite volume por canal nas Configurações e o áudio dinâmico (música abafada à noite e no pause) sem trocar de faixa.

**Áudio gerado por código, em WAV.**
Não há encoder de OGG na máquina e o Godot comprime WAV na importação. O loop é feito em código (`AudioStreamWAV.loop_mode`), sem editar os `.import`.

**Painéis sobrepostos herdam de `OverlayPanel`.**
Configurações, Controles e Créditos compartilham abrir/fechar animado, Esc para voltar e foco inicial. Os mesmos painéis servem ao menu e ao pause.

**Pipeline de arte reprodutível em `tools/`.**
`slice_spritesheets.py` → `clean_sprites.py`; `prepare_map.py` (limpeza + exterior transparente); `prepare_logos.py`; `make_store_art.py`. Se a arte de origem mudar, basta rodar os scripts de novo.

## Consequências

- Uma cena nova ganha som de botão, tema e transição sem código extra; só precisa usar `Transition.change_scene()`.
- Trocar a trilha por uma composta por alguém do grupo é só substituir os `.wav` com os mesmos nomes.
- Se o grupo redesenhar o mapa ou os sprites à mão, desligar a limpeza (ou reduzir a quantização) para não alterar a arte feita com intenção.
