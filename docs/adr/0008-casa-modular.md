# ADR 0008 — Casa modular em pixel art, com assentos e interações

**Data:** 2026-10-16
**Status:** aceito

## Contexto

O mapa da casa era uma imagem única (arte enviada pelo aluno, gerada por IA), com os móveis pintados no chão. O aluno pediu poder sentar nas cadeiras e no sofá, ter interações e animações, e um jantar com os dois sentados comendo.

## Decisões

**Redesenhar a casa em vez de recortar a imagem.**
Separar móveis do chão numa imagem de IA exigiria segmentação e "preencher o buraco" do piso, com resultado inconsistente. `tools/make_casa.py` desenha o fundo e cada móvel em pixel art, na mesma grade e paleta, e mantém a disposição da casa original. Isso também resolve parte do item em aberto sobre arte com cara de IA.

**Ficha de dados (`assets/casa/casa.json`) gerada junto com a arte.**
Para cada objeto, a ficha traz:
- posição de ordenação (y-sort), deslocamento do desenho e colisão;
- interação (tipo, texto, zona) e assentos (posição, direção, ponto de saída).

Também traz as colisões das paredes, as zonas da fase, as luzes e o caminho da mãe. `scripts/casa/casa.gd` monta tudo em tempo de execução. Mudou a arte, roda o script e a fase acompanha.

**Ponto de ordenação escolhido por móvel.**
O sofá ordena pelo encosto, para quem senta ficar na frente. A mesa ordena pela borda da frente: cobre as pernas de quem senta nas cabeceiras e o corpo de quem senta no fundo. As cadeiras de baixo ordenam abaixo do assento, para o encosto ficar na frente.

**Poses novas a partir dos sprites existentes (`tools/make_sentado.py`).**
O script mantém cabeça e tronco do sprite, redesenha as pernas na pose sentada com as cores e o contorno do próprio sprite e acrescenta o braço com garfo. Escreve as animações (`sit_*`, `eat_*`) no SpriteFrames de cada personagem.

**Sentar sem física.**
O jogador anda até o assento por tween (as cadeiras têm colisão) e levanta para o ponto de saída. A mãe faz o último trecho até a cadeira do mesmo jeito.

**Câmera: a base também é presa pelos limites.**
Perto das paredes a câmera não segue o jogador, então o offset do enquadramento passou a ser calculado a partir da posição-base já limitada. Corrigiu o jantar, que enquadrava o sofá.

## Consequências

- Novo móvel interativo: uma função `sprite_*` e uma entrada em `objetos` no `make_casa.py`.
- O mapa antigo (`assets/maps/fase1_casa.png`) ficou só como referência e saiu do build.
- Durante cutscenes, as zonas da casa ficam desligadas (`casa.ativar_zonas`).
