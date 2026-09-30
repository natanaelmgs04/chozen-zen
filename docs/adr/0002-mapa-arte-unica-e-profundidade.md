# ADR 0002 — Mapa como arte única, colisões manuais e profundidade por y-sort

**Data:** 2026-09-30
**Status:** aceito — substitui a decisão de blockout em `ColorRect` do [ADR 0001](0001-arquitetura-fase1-casa.md)

## Contexto

O aluno enviou a arte final da Fase 1 (uma imagem 1536×1024 da casa vista de cima, em 3/4) e pediu que ela entrasse "idêntica" no jogo. Também relatou que o jogador parecia "entrar dentro" da mãe ao chegar perto.

## Decisões

**A arte entra como um único `Sprite2D`, sem recortar em tiles.**
Recortar em `TileMap` mudaria a arte (a imagem não foi desenhada em grade) e exigiria refazer o mapa. Como a pedida era "idêntico", a imagem é usada como está; só o branco externo vira transparente (`tools/prepare_map.py`).

**Colisões como retângulos manuais sobre a arte, cobrindo a pegada visual inteira de cada móvel.**
Como os móveis fazem parte da imagem de fundo, o jogador é sempre desenhado por cima deles. Cobrindo o retângulo visual inteiro, o jogador nunca fica "atrás" de um móvel: vindo de baixo, para na borda inferior (e desenhá-lo por cima está correto, ele está na frente); vindo de cima, para na borda superior e o corpo fica acima do móvel, sem sobreposição. Custo: não dá para passar colado atrás de objetos altos, aceitável para esta cena.

**Personagens em um nó com `y_sort_enabled`, origem nos pés.**
Quem está mais abaixo na tela é desenhado na frente. Os sprites usam `offset` para o pé ficar na origem do nó.

**Mãe com colisão circular maior (raio 42) como "espaço pessoal".**
Só o y-sort não bastava: com colisões pequenas nos pés, os personagens (de cabeça grande) ficavam a ~20 px e um cobria quase todo o outro. O círculo mantém ~50 px de distância na frente/atrás e deixa o jogador deslizar em volta dela. A colisão do jogador com paredes continua pequena (32×20) para não atrapalhar a navegação.

**Validação visual com `tools/screenshot_runner.tscn`.**
A janela do jogo não pode ser controlada pelas ferramentas de automação desta máquina. A cena de dev roda qualquer cena com argumentos de linha de comando, simula input e salva um PNG, permitindo conferir visualmente cada mudança.

## Consequências

- Mudou a arte do mapa → é preciso revisar os retângulos em `Colisoes` (fácil de ajustar no editor, cada um tem o nome do objeto).
- Se no futuro o jogador precisar passar atrás de móveis altos, os móveis terão que virar sprites separados participando do y-sort.
- Próximas fases podem seguir o mesmo padrão: `Mapa` + `Colisoes` + `Entities` (y-sort) + HUD + DecisionUI.
