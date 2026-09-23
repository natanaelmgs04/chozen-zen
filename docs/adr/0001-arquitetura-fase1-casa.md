# ADR 0001 — Arquitetura do protótipo Fase 1 (Família)

**Data:** 2026-09-23
**Status:** aceito

## Contexto

Primeira implementação jogável do projeto (Ciclo 1). Precisava suportar, ao mesmo tempo, movimento livre recém-liberado ([002](../specs/002-movimento-e-interacao-de-cenario.md)) e o sistema de decisões/reputação já especificado ([001](../specs/001-sistema-de-decisoes.md)), usando os spritesheets já recortados da mãe e do jogador.

## Decisões

**Reputação como autoload (`GameState`), não como estado local da cena.**
Toda fase futura vai precisar ler/alterar a mesma Reputação. Um autoload evita passar o valor entre cenas manualmente e já prepara o terreno para U2 (barra com cor) e U3 (fim de jogo), sem implementá-los agora.

**Conteúdo do evento como `Dictionary` constante na cena, não como `Resource` (.tres) genérico.**
Existe apenas um evento até agora (Fase 1 — Família). Um sistema genérico de "banco de eventos" seria abstração prematura. Quando houver mais de uma fase com múltiplos eventos, vale revisar para um `Resource` reutilizável — registrar como possível revisão futura, não implementar agora.

**Interação por `Area2D` + camadas de física (1 = cenário, 2 = jogador), não por distância calculada em `_process`.**
Sinais `body_entered`/`body_exited` do Godot são o padrão idiomático para isso e evitam checar distância a cada frame.

**UI de decisão como `CanvasLayer` com `process_mode = PROCESS_MODE_ALWAYS` + `get_tree().paused = true`.**
Pausar a árvore inteira impede o jogador de se mover ou a mãe de disparar novas interações enquanto o evento está na tela, sem precisar de uma flag de "input travado" espalhada por vários scripts. Só a UI de decisão precisa continuar processando durante a pausa.

**Blockout em `ColorRect` + `StaticBody2D`/`CollisionShape2D` simples, sem `TileMap`.**
A cena é uma única sala fixa. Um `TileMap` traria overhead de configuração (tileset, layers) sem benefício para uma sala que não se repete nem é editada por level design ainda. Revisar para `TileMap` quando houver múltiplos cômodos/fases reaproveitando peças.

## Consequências

- Adicionar uma nova fase/cena significa: nova cena com o mesmo padrão (Blockout + Player + NPC(s) + DecisionUI), e o mesmo `GameState` autoload acumula a Reputação entre fases.
- Se dois eventos precisarem coexistir na mesma cena (ex.: dois NPCs interativos), o código atual já suporta isso sem mudança (cada NPC dispara `talk_requested` e a mesma `DecisionUI` é reaberta com dados diferentes) — não testado ainda.
- Quando entrar em cena um "banco de eventos" com mais conteúdo, vale revisitar a decisão de `Dictionary` inline vs. `Resource`.
