# ADR 0005 — Cutscene de abertura em pixel art no próprio motor

**Data:** 2026-10-16
**Status:** aceito

## Contexto

A Fase 1 começava com um cartão de texto contando o que aconteceu na escola. O aluno pediu que isso fosse mostrado em animação, "visual e não muito textual". Não existe arte da escola, da rua ou da fachada da casa.

## Decisões

**Cutscene feita no Godot, não em vídeo.**
Ela usa os mesmos sprites do jogo, roda igual na web e no Windows, ocupa poucos KB e pode ser pulada. Um vídeo pesaria vários MB e destoaria dos sprites.

**Cenários desenhados por código em "pixels de arte" de 4 px (`scripts/cutscene/pixel.gd`).**
É a mesma grade dos sprites, então tudo parece pixel art feita à mão. Não depende de arte nova gerada por IA, que é justamente o que o professor criticou. Se o grupo desenhar os cenários depois, basta trocar o `_draw()` de cada plano por um `Sprite2D`.

**Colegas em silhueta (shader `assets/shaders/silhueta.gdshader`); professora com sprites próprios.**
A turma em silhueta resolve a falta de sprites de colegas com uma escolha de direção de arte: uma multidão sem rosto que julga. A professora começou como silhueta desenhada por formas, mas o aluno achou que ela parecia um monstro. Por isso ganhou sprites em pixel art (frente, dois passos, papel no alto, costas, costas escrevendo, de lado apontando), feitos pixel a pixel por `tools/make_professora.py` na grade de 4 px dos outros personagens.

**Um "diretor" (`scripts/cutscene_intro.gd`) e um script por plano (`scripts/cutscene/cena_*.gd`).**
Cada plano expõe `tocar(diretor)`, uma linha do tempo com `await`. O diretor oferece as ferramentas comuns: espera, legenda, balão de fala, notificação, enquadrar, tremer.

**As esperas usam um `Timer` filho do diretor**, e não `get_tree().create_timer()`.
Se o jogador pular, a cena é liberada e as linhas do tempo param junto, sem tentar retomar uma função de um objeto que não existe mais.

**Emenda com a fase.**
A cutscene termina na luz da porta, e a transição usa essa cor (`Transition.change_scene(path, color)`). Na fase, o jogador entra pela porta da frente (`player.walk_to`) antes de ganhar o controle. "Jogar de novo" recarrega só a fase, sem repetir a cutscene.

## Consequências

- Nova fase com abertura: criar `cena_*.gd` com `tocar(d)` e listar em `PLANOS`.
- O texto de introdução saiu de `fase1_roteiro.gd`. Lá ficaram só as dicas curtas (`DICAS`) mostradas quando o jogador ganha o controle.
- A cutscene é testável pelo `screenshot_runner` (`--scene=res://scenes/cutscene_intro.tscn --wait=T`).
