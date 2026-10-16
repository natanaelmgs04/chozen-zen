# Publicação no itch.io

## Arquivos prontos

| Arquivo | Para quê |
|---|---|
| `build/ChosenZen_web.zip` | Jogável no navegador (`index.html` na raiz do zip) |
| `build/ChosenZen_windows.zip` | Download para Windows (`ChosenZen.exe`) |
| `presskit/capa_itch_630x500.png` | **Cover image** da página |
| `presskit/banner_1920x480.png` | Banner / fundo da página |
| `presskit/screenshots/*.png` | 6 screenshots (1280×720) |
| `build/ChosenZen_presskit.zip` | Press kit para o Trello e para imprensa |

## Criar a página (feito pelo dono da conta)

1. itch.io → **Upload new project**.
2. **Title:** ChosenZen · **Project URL:** ex. `chosenzen` (único item obrigatório, segundo o professor).
3. **Short description:** *Cada escolha, uma nova história.*
4. **Classification:** Game · **Kind of project:** HTML.
5. **Release status:** In development (é a demo do Capítulo 1).
6. **Pricing:** *No payments* (demo gratuita). O preço de R$ 19,90 do modelo de monetização vale para o jogo completo.
7. **Uploads:**
   - `ChosenZen_web.zip`, marcando **This file will be played in the browser**.
   - `ChosenZen_windows.zip`, marcando a plataforma **Windows**.
8. **Embed options:** 1280 × 720, **Mobile friendly** desmarcado, **Fullscreen button** marcado. Não precisa de SharedArrayBuffer.
9. **Description:** o texto abaixo.
10. **Genre:** Simulation · **Tags:** life-sim, narrative, choices-matter, pixel-art, cozy, singleplayer, controller.
11. **Cover image:** `capa_itch_630x500.png` · **Screenshots:** as 6 de `presskit/screenshots/`.
12. **Visibility:** comece em **Draft** para testar; troque para **Public** quando o grupo aprovar.

## Texto da página

> **ChosenZen** — *Cada escolha, uma nova história.*
>
> Hoje, a professora encontrou uma cola embaixo da sua carteira. Não era sua, mas ninguém acreditou. Você chega em casa cansado, e tudo o que quer é chegar ao seu quarto.
>
> ChosenZen é um simulador de vida sobre reputação e caráter. Cada conversa custa **Energia**, e cada resposta muda como os outros veem você. Ser atencioso cansa; poupar energia pode magoar quem você ama. Não existe resposta certa, só escolhas com consequências.
>
> **Nesta demo (Capítulo 1 — Família: "Uma noite em casa")**
> - Escolhas com custo real: Reputação × Energia
> - Consequências que voltam nas cenas seguintes e no resumo do dia
> - Uma noite que passa de verdade: luz, música e sons mudam do fim de tarde à madrugada
> - Trilha sonora original
> - Teclado ou controle · texto ajustável · volumes por canal
>
> **Controles:** WASD/Setas para andar · E para interagir · Esc para pausar (ou controle)
>
> Um jogo do **Estúdio Vívido** — "Ideias que ganham vida." · Feito com Godot.

## Gerar os builds de novo

Na pasta `chozen-zen/`, com os templates de exportação do Godot 4.7.2 instalados:

```bash
godot --headless --path . --export-release "Web" ../build/web/index.html
godot --headless --path . --export-release "Windows" ../build/windows/ChosenZen.exe
```

Zipe o **conteúdo** de `build/web/` e de `build/windows/`. Se a arte mudar, rode antes:

```bash
python tools/prepare_map.py
python tools/clean_sprites.py
python tools/prepare_logos.py
python tools/make_store_art.py
```

O áudio é gerado por `python tools/generate_audio.py`.
