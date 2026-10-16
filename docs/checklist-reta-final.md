# Checklist da reta final — "Finalizando o jogo" (Prof. Caio Oliveira)

**Atualizado:** 2026-10-16 · Legenda: ✅ feito · 🟡 parcial · 👥 depende do grupo

## 1. Polimento (ciclo 4) — o infográfico do slide 9

| Área do slide | Status | O que existe no jogo |
|---|---|---|
| Jogabilidade e controles | ✅ | Aceleração/desaceleração no movimento, colisões revisadas, teclado **e controle** (analógico, D-pad, A, Start) |
| Feedback visual e sonoro | ✅ | Som em todo botão, escolha, perda/ganho de Reputação, Energia, objetivo e memória; números flutuantes no HUD; painel treme ao perder Reputação |
| Câmera e apresentação | ✅ | Câmera segue o jogador com limites da casa e **aproxima** no que importa durante as conversas |
| Arte, animações e efeitos | ✅ | Cutscene de abertura animada (escola → rua → porta), cenas curtas antes e depois de cada enquete, linguagem de cinema nas cutscenes (retratos, impact frame, celular, cartão de capítulo, gradação de cor), squash & stretch nos passos, emote "!" da mãe, painéis com entrada animada, pétalas no menu, transições com fade |
| UI/UX e navegação | ✅ | Menu com Jogar / Configurações / Controles / Créditos / Sair; pause completo; navegação por teclado e controle; faixa de objetivo + seta |
| Balanceamento | 🟡 | Valores de Energia e Reputação definidos (spec 003), mas **ainda sem playtest com pessoas** |
| Desempenho e otimização | ✅ | 2D leve; pacote web de 2,3 MB; sem threads (roda em qualquer navegador) |
| Polimento técnico | ✅ | Configurações salvas em disco (`user://settings.cfg`); casos de borda testados (sem energia, apagou de sono, reputação 0) |
| Acessibilidade e inclusão | ✅ | Velocidade do texto (normal/rápida/instantânea), texto grande, volumes por canal, controle; Reputação mostra número além da cor (daltonismo) |
| Testes e playtests | 👥 | Testado por screenshots automáticos e no navegador. **Falta o grupo fazer playtest com outras pessoas e registrar o feedback** |
| Coesão e atmosfera | ✅ | Arte, UI, som e luz contam a mesma história: fim de tarde → noite |

## 2. Áudio (slides 10–12)

| Item | Status |
|---|---|
| Música | ✅ Tema lo-fi original em loop (sintetizado por código, livre para venda) |
| Efeitos sonoros | ✅ UI, passos na madeira, escolhas, Reputação, Energia, memória, transição, digitação |
| Ambiente | ✅ Casa de dia (relógio, geladeira) e de noite (grilos) |
| Mixer / buses | ✅ Canais Music, SFX e Ambience com volume próprio |
| Áudio dinâmico | ✅ À noite a música fica abafada (passa-baixa) e entra a ambiência noturna; menus de pause abafam a música |

## 3. Luz (slides 13–14)

✅ `CanvasModulate` + `PointLight2D`: a casa muda de fim de tarde (quente) para anoitecer e para noite (azulada), e o abajur, a luz do jantar e a do corredor acendem conforme o momento.

## 4. Game feel / juice e princípios de animação (slides 15–18)

✅ Resposta imediata (aceleração), feedback multissensorial (som + animação + número), *ease in/out* em tudo, *squash & stretch*, antecipação nos painéis (escala com *overshoot*), texto em máquina de escrever, *staging* com a câmera.

## 5. "Arte sem cara de IA!!!" (slides 19–20)

🟡 **Feito o que dá por código:**
- O mapa tinha cerca de 45 mil cores e pixels de tamanhos diferentes (sinal típico de imagem gerada por IA). Agora ele passa por uma limpeza: remoção de ruído, grade única de 4 px e paleta de 128 cores (`tools/prepare_map.py`).
- Os personagens tinham cerca de 4.200 cores borradas por causa do JPG. Agora cada um tem uma paleta própria de 32 cores, com bordas nítidas (`tools/clean_sprites.py`).
- A interface usa uma fonte de verdade e componentes desenhados, não imagens.

👥 **O que só o grupo resolve:** os **logos** (jogo e estúdio) e a **composição do mapa** ainda têm cara de IA (traço de aquarela "perfeito demais", detalhes sem intenção). O ideal antes de vender é redesenhar à mão, ou ao menos retocar num editor de pixel art (Aseprite, LibreSprite, Pixelorama), usando as versões limpas como base.

## 6. Controles e mapeamento (slides 21–22)

✅ Tela **Controles** no menu e no pause, com teclado e controle lado a lado (no estilo do PadCrafter / Game Input Database).

## 7. Apresentação (slides 23–28)

👥 É do grupo: 5 minutos, todos na frente, computadores desligados, template do Canva do professor e **sem cara de Gamma**. Roteiro sugerido:

1. **Gancho (30 s):** "Hoje a professora achou uma cola embaixo da sua carteira. Não era sua." Mostrar o screenshot 03.
2. **O que é (45 s):** life sim de escolhas; o desafio é Reputação × Energia (não tem resposta certa).
3. **Como responde ao feedback (1 min):** antes era quiz → agora tem objetivo, obstáculos, consequências e progressão (seção 4.1 do GDD).
4. **Polimento (1 min):** som original, luz que passa do dia para a noite, game feel, acessibilidade.
5. **Identidade (45 s):** Estúdio Vívido, logo, paleta, press kit.
6. **Negócio (30 s):** Premium R$ 19,90, sem VIP nem pay-to-win.
7. **Fechamento (30 s):** link do itch.io + QR code.

## 8. Publicação (slides 29–34)

| Item | Status |
|---|---|
| Título e URL do projeto (único item obrigatório) | 👥 Criar no itch.io (conta do grupo) |
| Kind of project | ✅ Pronto para **HTML** (`build/ChosenZen_web.zip`) + download Windows |
| Página com descrição, capa e imagens | ✅ Texto, capa 630×500, banner e 6 screenshots prontos → [publicacao-itch.md](publicacao-itch.md) |
| Menu como o exemplo do slide 34 (Iniciar / Controles / Sair) | ✅ |

## 9. Press kit (slide 35)

✅ `presskit/` com página `index.html`, ficha técnica, descrição, recursos, 6 screenshots, logos com fundo transparente, ícone, capa e banner. Zip pronto: `build/ChosenZen_presskit.zip`.

## 10. Checklist final do slide 36

- [ ] 👥 Enviou o link da apresentação e do itch.io?
- [ ] 👥 Enviou o press kit no Trello? → anexar `build/ChosenZen_presskit.zip`
- [ ] 👥 O Trello está atualizado? → o professor apontou que o card do menu estava como feito, mas vazio: anexar os screenshots `presskit/screenshots/01_menu.png` e as telas de Configurações/Controles/Créditos
- [ ] 👥 Preencher os nomes do grupo nos créditos (`chozen-zen/scripts/ui/credits_panel.gd`, constante `EQUIPE`)
- [ ] 👥 Playtest com pelo menos 3 pessoas de fora do grupo
