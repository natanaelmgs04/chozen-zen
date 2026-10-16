# ADR 0007 — Linguagem de cinema nas cutscenes

**Data:** 2026-10-16
**Status:** aceito

## Contexto

O aluno pediu cutscenes "muito profissionais, impactantes, chamativas e bonitas", com pesquisa de jogos que usam bastante esse recurso. As cenas tinham emotes e balões simples.

## Decisões

**Referências: Persona 5, Celeste, Night in the Woods, Life is Strange, Undertale.**
Os recursos escolhidos são os que mais mudam a percepção de qualidade sem pedir arte nova grande:
- retratos com expressão;
- texto animado;
- impact frames;
- tipografia em movimento;
- celular como interface narrativa;
- gradação de cor.

**Quatro camadas reutilizáveis em `scripts/cinema/`**, usadas tanto pela abertura quanto pela casa:
- `CinemaFX` (camada 4 na abertura, 8 na casa): pós-processamento por shader (`assets/shaders/cinema_pos.gdshader`) com climas, desfoque, flash, impacto, linhas de velocidade e brilho. Fica *abaixo* da interface: o diálogo nunca é desfocado nem tingido.
- `Dialogo` (12) + `Retrato`: caixa com plaquinha do personagem, retratos que entram deslizando, voz por personagem e BBCode (`[shake]`, `[wave]`, `[color]`).
- `Celular` (13): conversa mensagem a mensagem com "digitando...", notificações e o "digita e desiste" do Lucas, uma pista visual.
- `Letreiros` (60): cartão de capítulo, carimbo de hora/lugar e cortina diagonal.

**Ritmo controlado pelo jogador.**
As falas esperam E / Espaço / clique, como nos jogos de referência. Por isso saiu a "aceleração com E" das cenas da casa. Na abertura, segurar E continua pulando tudo (1,2 s, para não pular sem querer ao avançar falas).

**Retratos desenhados por código, não por IA generativa.**
O professor criticou a cara de IA, e a consistência com os sprites importa mais que o detalhe. `tools/make_retratos.py` monta cada busto com formas, sombreamento em três tons e contorno automático, na paleta do jogo. Trocar uma expressão é editar uma função.

**Sem shaders com mipmap.**
O desfoque usa amostras manuais para funcionar igual no renderizador Compatibility (web). O build web foi testado no navegador.

**Câmera lenta e congelamento com `Engine.time_scale`.**
Os efeitos de tela usam tweens com `set_ignore_time_scale(true)` para continuar em tempo real. O `time_scale` volta a 1 ao sair da cena, ao pular e no fim de cada plano.

## Consequências

- Nova cutscene: usar `d.dizer()`, `d.fx.clima()`, `d.impacto()`, `d.celular...` nos scripts de cena.
- O `screenshot_runner` liga `Dialogo.avanco_automatico` para capturar cenas sem precisar apertar E.
- Mais texto em cena: vale revisar o ritmo no playtest (a abertura ficou com cerca de 50 s, pulável).
