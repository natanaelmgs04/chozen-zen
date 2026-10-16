# ADR 0003 — Capítulo como máquina de momentos, roteiro em dados e interface única

**Data:** 2026-10-16
**Status:** aceito

## Contexto

A Fase 1 passou de um evento único para um capítulo com objetivo, três momentos, Energia, memórias e resumo ([spec 003](../specs/003-capitulo-energia-e-narrativa.md)). Também entraram menu de pause, abertura do estúdio, a identidade visual do logo e builds para o itch.io.

## Decisões

**Capítulo como uma máquina de estados simples em `phase1_casa.gd`.**
`enum Momento { INTRO, CHEGADA, JANTAR, NOITE, FIM }`; cada transição atualiza objetivo, seta e quais zonas reagem. Uma máquina explícita deixa claro em que ponto da história o jogador está e impede eventos fora de ordem. Ainda não vale uma abstração genérica de "capítulo": só existe um.

**Roteiro em dados (`scripts/data/fase1_roteiro.gd`), separado da lógica.**
Textos, valores e as variações por memória ficam num arquivo só. O grupo pode revisar ou balancear sem tocar na máquina de momentos.

**Zonas genéricas (`trigger_zone.gd`) para os pontos de interesse.**
Geladeira (tecla E), mesa e porta (ao entrar) usam o mesmo script; a fase decide o que cada uma faz no momento atual.

**Um `StoryCard` reutilizável para abertura, resumo e fins.**
Evita quatro telas quase iguais.

**Quem pausa a árvore é quem está na frente.**
`DecisionUI`, `StoryCard` e `PauseMenu` pausam a árvore e processam sempre. O pause só abre se a árvore não estiver pausada, para não empilhar menus.

**Filtro de textura: linear por padrão, nearest no pixel art.**
O logo, a fonte e os painéis precisam de suavização; o mapa e os personagens (nós `Mapa` e `Entities`, e os nós do menu) forçam `texture_filter = nearest`.

**Exportação: Web sem threads + Windows com pck embutido.**
Sem threads, o build web roda no itch.io sem *SharedArrayBuffer*. `assets/source/` e `tools/` ficam fora do pacote.

## Consequências

- Uma nova fase repete o padrão: cena com Mapa + Colisoes + Zonas + Entities + HUD + DecisionUI + StoryCard + PauseMenu, um script de fase com a máquina de momentos e um arquivo de roteiro.
- Quando houver duas ou mais fases, vale extrair o que for comum entre os scripts de fase.
- `GameState.flags` ainda não é salvo em disco; para levar memórias entre sessões será preciso persistência.
