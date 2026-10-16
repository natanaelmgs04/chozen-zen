# ADR 0006 — Cenas curtas antes e depois das enquetes

**Data:** 2026-10-16
**Status:** aceito

## Contexto

O aluno pediu pequenas cutscenes antes e depois de cada enquete, para o jogo ficar mais dinâmico e mostrar visualmente a situação e o que foi escolhido. O feedback anterior do professor também dizia que a narrativa parecia um quiz.

## Decisões

**Encenar na própria casa, com os personagens do jogo.**
Não há troca de cena nem arte nova: a câmera enquadra, os personagens andam e reagem com emotes (os mesmos da abertura, mais coração, raiva, zzz, nota, choro, livro e triste) e balões curtos. Mantém a continuidade espacial e custa pouco para fazer as 16 variações.

**Ritmo cena → escolha → cena → resultado.**
`DecisionUI.before_result` recebe a cena "depois". O painel some ao escolher, a árvore despausa, a cena toca e o painel volta com o resultado. `GameState.apply_option` só roda depois da cena, para a barra de Reputação reagir junto com o retorno, e não antes de o jogador ver a ação.

**Separação em três peças.**
- `scripts/diretor_casa.gd` (`DiretorCasa`): faixas de cinema, balões que seguem os personagens, emotes, notificações, tremor, aceleração.
- `scripts/data/fase1_cenas.gd` (`Fase1Cenas`): o conteúdo, ou seja, o que acontece em cada cena.
- `fase1_roteiro.gd`: cada opção aponta para a sua cena pelo campo `"cena"`.

Mudar uma cena não mexe na máquina de momentos nem na interface.

**Balões compartilhados (`scripts/cutscene/baloes.gd`).**
A abertura e a fase usam a mesma classe. A diferença é só a função que converte ponto do mundo em ponto da tela (palco na abertura, câmera na fase).

**Câmera presa a um ponto do mundo durante as cenas.**
O `offset` da câmera é recalculado a cada quadro a partir de um foco fixo, então o enquadramento não acompanha o jogador quando ele anda numa cena. À noite o zoom é 1,9, porque a porta do quarto fica no canto da casa e os limites da câmera não deixariam centralizar.

**Aceleração com `Engine.time_scale` (segurar E).**
Vale só enquanto uma cena toca e volta a 1 no pause e na enquete. Exige soltar e apertar de novo, para o E que abriu a conversa não acelerar sem querer.

**Movimento roteirizado sem física** (`walk_to` no jogador e na mãe, com a rotina da mãe suspensa por `scripted`).
Os caminhos contornam os móveis à mão (ex.: `_rota_para_o_assento()` no jantar).

## Consequências

- Nova opção numa enquete: escrever `_depois_<nome>()` em `fase1_cenas.gd` e pôr `"cena": "<nome>"` no roteiro. Sem cena, a enquete segue direto para o resultado.
- O `screenshot_runner` precisa de `--wait` e `--choose-wait` maiores para capturar o painel e o resultado (as cenas vêm antes).
- Os caminhos sem física podem atravessar móveis se os personagens estiverem em lugares inesperados; vale observar no playtest.
