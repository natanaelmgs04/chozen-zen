"""Retratos de diálogo em pixel art (bustos com expressões), no estilo Celeste / Night in the Woods.

Uso: python tools/make_retratos.py [--preview caminho.png]
Saída: assets/retratos/<personagem>/<expressao>_<quadro>.png
  quadro: "base" (olhos abertos, boca fechada), "pisca" (olhos fechados) e "fala" (boca aberta)

Tudo desenhado pixel a pixel por código (formas + sombreamento + contorno automático),
na mesma paleta dos sprites do jogo. Grade de 56×56 pixels de arte, ampliada 5×.
"""
import sys
from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "assets" / "retratos"
N = 56
ESCALA = 5
CONTORNO = (42, 26, 20, 255)


def hexa(c: str) -> tuple:
    return (int(c[0:2], 16), int(c[2:4], 16), int(c[4:6], 16), 255)


class Tela:
    def __init__(self) -> None:
        self.img = np.zeros((N, N, 4), dtype=np.uint8)
        # máscara de "camada" para o contorno saber o que é corpo
        self.cheio = np.zeros((N, N), dtype=bool)

    def px(self, x, y, cor, conta=True) -> None:
        x, y = int(round(x)), int(round(y))
        if 0 <= x < N and 0 <= y < N:
            self.img[y, x] = hexa(cor) if isinstance(cor, str) else cor
            if conta:
                self.cheio[y, x] = True

    def rect(self, x0, y0, x1, y1, cor) -> None:
        for y in range(int(y0), int(y1) + 1):
            for x in range(int(x0), int(x1) + 1):
                self.px(x, y, cor)

    def elipse(self, cx, cy, rx, ry, cor, cond=None) -> None:
        for y in range(N):
            for x in range(N):
                if ((x + 0.5 - cx) / rx) ** 2 + ((y + 0.5 - cy) / ry) ** 2 <= 1.0:
                    if cond is None or cond(x, y):
                        self.px(x, y, cor)

    def dentro(self, x, y) -> bool:
        return 0 <= x < N and 0 <= y < N and self.cheio[y, x]

    def contorno(self) -> None:
        borda = np.zeros_like(self.cheio)
        c = self.cheio
        borda[1:, :] |= c[:-1, :]
        borda[:-1, :] |= c[1:, :]
        borda[:, 1:] |= c[:, :-1]
        borda[:, :-1] |= c[:, 1:]
        alvo = borda & ~c
        self.img[alvo] = CONTORNO

    def imagem(self) -> Image.Image:
        return Image.fromarray(self.img).resize((N * ESCALA, N * ESCALA), Image.NEAREST)


# ------------------------------------------------------------------ personagens

PERSONAGENS = {
    "jogador": {
        "pele": "f2a477", "pele_s": "d9855c", "pele_c": "f9c39a",
        "cabelo": "6b3a1f", "cabelo_s": "4e2914", "cabelo_c": "8f5530",
        "roupa": "2fa84f", "roupa_s": "22803b", "roupa_c": "5cc673",
        "iris": "5a3a24", "estilo": "cacheado",
    },
    "mae": {
        "pele": "f2a477", "pele_s": "d9855c", "pele_c": "f9c39a",
        "cabelo": "7a4426", "cabelo_s": "5a301a", "cabelo_c": "9c5f3a",
        "roupa": "d27ea0", "roupa_s": "a95e7e", "roupa_c": "e9a2bf",
        "iris": "5a3a24", "estilo": "coque", "alca": "4f8fd0", "bebe": True,
    },
    "professora": {
        "pele": "d9a07a", "pele_s": "b97f5c", "pele_c": "ebbd98",
        "cabelo": "3b2a2e", "cabelo_s": "271b1e", "cabelo_c": "5b4248",
        "roupa": "e0a43c", "roupa_s": "b9802a", "roupa_c": "f0c264",
        "iris": "3a2a22", "estilo": "coque_alto", "oculos": True, "blusa": "fbf5ec",
    },
    "lucas": {
        "pele": "e8b58e", "pele_s": "c8916b", "pele_c": "f5d0b0",
        "cabelo": "d8b25a", "cabelo_s": "b08a3a", "cabelo_c": "f0d488",
        "roupa": "4a6fa5", "roupa_s": "36547e", "roupa_c": "6b90c4",
        "iris": "4a6a8a", "estilo": "espetado",
    },
}

EXPRESSOES = {
    "jogador": ["neutro", "triste", "surpreso", "irritado", "envergonhado", "feliz"],
    "mae": ["neutra", "preocupada", "feliz", "triste", "surpresa", "brava"],
    "professora": ["severa", "brava", "surpresa"],
    "lucas": ["neutro", "nervoso"],
}

CX = 28.0


def corpo(t: Tela, p: dict) -> None:
    # ombros (trapézio) com luz à esquerda e sombra à direita
    for y in range(44, N):
        meia = 11 + (y - 44) * 0.95
        for x in range(int(CX - meia), int(CX + meia) + 1):
            rel = (x - (CX - meia)) / (2 * meia)
            cor = p["roupa_c"] if rel < 0.18 else (p["roupa_s"] if rel > 0.78 else p["roupa"])
            t.px(x, y, cor)
    if p.get("blusa"):  # cardigã aberto com blusa
        for y in range(44, N):
            meia = 3 + (y - 44) * 0.25
            t.rect(CX - meia, y, CX + meia - 1, y, p["blusa"])
    else:  # gola
        for x in range(23, 33):
            t.px(x, 44, p["roupa_s"])
    if p.get("alca"):  # alça do sling atravessando o peito
        for y in range(44, N):
            x0 = 18 + (y - 44) * 1.6
            t.rect(x0, y, x0 + 3, y, p["alca"])
    # pescoço
    t.rect(24, 38, 31, 44, p["pele"])
    t.rect(24, 38, 31, 40, p["pele_s"])


def bebe(t: Tela) -> None:
    t.elipse(40, 51, 6.5, 6, "f2a477")
    t.elipse(40, 47, 6.5, 3.2, "3b2418")
    t.px(38, 52, "2a1a14")
    t.px(42, 52, "2a1a14")
    t.px(37, 54, "f0907a")
    t.px(43, 54, "f0907a")


def cabelo_atras(t: Tela, p: dict) -> None:
    estilo = p["estilo"]
    if estilo == "cacheado":
        t.elipse(CX, 22, 17, 15, p["cabelo_s"])
        for cx, cy, r in [(13, 22, 5), (43, 22, 5), (15, 32, 4), (41, 32, 4), (14, 14, 5), (42, 14, 5)]:
            t.elipse(cx, cy, r, r, p["cabelo_s"])
    elif estilo in ("coque", "coque_alto"):
        t.elipse(CX, 24, 16, 15.5, p["cabelo_s"])
        if estilo == "coque":
            t.elipse(CX + 9, 9, 7, 6.5, p["cabelo"])
            t.elipse(CX + 7, 7, 3, 2, p["cabelo_c"])
        else:
            t.elipse(CX, 6, 6.5, 5.5, p["cabelo"])
            t.elipse(CX - 2, 4.5, 2.5, 1.6, p["cabelo_c"])
        t.elipse(14.5, 33, 3.5, 7, p["cabelo_s"])
        t.elipse(41.5, 33, 3.5, 7, p["cabelo_s"])
    elif estilo == "espetado":
        t.elipse(CX, 22, 15.5, 14, p["cabelo_s"])


def rosto(t: Tela, p: dict) -> None:
    # rosto: "superelipse" (bochechas cheias, queixo arredondado — proporção chibi)
    for y in range(12, 42):
        for x in range(10, 46):
            dx = abs(x + 0.5 - CX) / 13.0
            dy = (y + 0.5 - 26.5) / (14.5 if y > 26 else 13.5)
            if dx ** 2.6 + abs(dy) ** 2.2 <= 1.0:
                cor = p["pele"]
                if x >= 37 and y > 22:
                    cor = p["pele_s"]
                if y >= 38:
                    cor = p["pele_s"]
                t.px(x, y, cor)
    # orelhas
    t.elipse(14.6, 29, 2, 3, p["pele"])
    t.elipse(41.4, 29, 2, 3, p["pele_s"])


def cabelo_frente(t: Tela, p: dict) -> None:
    estilo = p["estilo"]
    c, s, l = p["cabelo"], p["cabelo_s"], p["cabelo_c"]
    if estilo == "cacheado":
        for cx, cy, r in [(16, 13, 6), (24, 9, 6.5), (33, 9, 6.5), (40, 13, 6), (12, 19, 4.5), (44, 19, 4.5),
                          (20, 15, 4.5), (28, 14, 5), (36, 15, 4.5)]:
            t.elipse(cx, cy, r, r, c)
        for cx, cy in [(22, 7), (31, 7), (15, 11), (38, 11)]:
            t.elipse(cx, cy, 2.2, 1.4, l)
        for x in range(13, 44, 4):  # pontas da franja
            t.elipse(x + 1, 19.5, 2.2, 2.2, c)
            t.px(x + 2, 21, s)
    elif estilo in ("coque", "coque_alto"):
        t.elipse(CX, 15, 15, 7.5, c, lambda x, y: y < 20)
        # franja de lado, varrida para a direita
        for y in range(14, 22):
            x1 = 14 + (y - 14) * 2.2
            t.rect(13, y, min(x1, 30), y, c)
        t.rect(39, 16, 42, 24, c)
        for cx, cy in [(22, 11), (16, 15)]:
            t.elipse(cx, cy, 3, 1.3, l)
        for y in range(16, 22):
            t.px(13 + (y - 14) * 2.2, y, s)
    elif estilo == "espetado":
        for i, x in enumerate(range(12, 46, 5)):
            topo = [7, 2, 5, 1, 4, 3, 6][i % 7]
            for y in range(topo, 20):
                largura = (y - topo) * 0.45
                t.rect(x - largura, y, x + largura, y, c)
        t.elipse(CX, 16, 15, 5, c, lambda x, y: y < 20)
        for x in range(14, 44, 6):
            t.px(x, 9, l)
            t.px(x + 1, 10, l)


# ------------------------------------------------------------------- feições

def olho(t: Tela, x0: int, p: dict, expr: str, quadro: str, lado: str) -> None:
    """x0 = coluna esquerda do olho (7 de largura). Olhos grandes: é neles que a emoção se lê."""
    escuro, branco = "2a1a14", "fbf5ec"
    if quadro == "pisca" or expr == "feliz":
        if expr == "feliz":  # ^ ^
            for dx, dy in [(0, 30), (1, 29), (2, 28), (3, 27), (4, 28), (5, 29), (6, 30)]:
                t.px(x0 + dx, dy, escuro)
                t.px(x0 + dx, dy + 1, escuro)
        else:  # piscando: linha curva com cílios
            for dx in range(7):
                t.px(x0 + dx, 30 + (1 if dx in (0, 6) else 0), escuro)
            t.px(x0 + (0 if lado == "e" else 6), 29, escuro)
        return
    topo = 24
    if expr in ("triste", "preocupada", "envergonhado"):
        topo = 26  # pálpebra caída
    if expr in ("surpreso", "surpresa"):
        topo = 23
    t.rect(x0, topo, x0 + 6, 32, branco)
    olhar = 0
    if expr in ("envergonhado", "nervoso"):
        olhar = 1 if lado == "e" else 1
    if expr in ("surpreso", "surpresa"):
        # pupilas pequenas no meio do branco
        t.rect(x0 + 2, 26, x0 + 4, 29, p["iris"])
        t.rect(x0 + 3, 27, x0 + 3, 28, escuro)
        t.px(x0 + 2, 26, branco)
    else:
        i0 = max(topo, 25)
        t.rect(x0 + 1 + olhar, i0, x0 + 5 + olhar - (1 if olhar else 0), 32, p["iris"])
        t.rect(x0 + 2 + olhar, i0 + 1, x0 + 4 + olhar - (1 if olhar else 0), 31, escuro)
        # brilho do olho (2 pontos), dá vida ao retrato
        t.px(x0 + 2 + olhar, i0 + 1, branco)
        t.px(x0 + 4 + olhar - (1 if olhar else 0), 31, p["iris"])
        t.rect(x0 + 1 + olhar, 32, x0 + 5 + olhar - (1 if olhar else 0), 32, "cfe6ee" if expr == "triste" else p["iris"])
    # pálpebra superior grossa (cílios) e canto externo
    t.rect(x0, topo - 1, x0 + 6, topo - 1, escuro)
    t.px(x0 - 1 if lado == "e" else x0 + 7, topo, escuro)
    if expr in ("irritado", "brava", "severa"):
        for dx in range(7):
            corte = (6 - dx) // 2 if lado == "e" else dx // 2
            for dy in range(corte + 1):
                t.px(x0 + dx, topo - 1 + dy, p["pele"])
            t.px(x0 + dx, topo - 1 + corte + 1, escuro)
    t.rect(x0 + 1, 33, x0 + 5, 33, p["pele_s"])


def sobrancelhas(t: Tela, p: dict, expr: str) -> None:
    cor = p["cabelo_s"]
    if expr in ("irritado", "brava", "severa"):
        linhas = {"e": [(16, 19), (18, 20), (20, 21), (22, 22)], "d": [(39, 19), (37, 20), (35, 21), (33, 22)]}
    elif expr in ("triste", "preocupada", "envergonhado", "nervoso"):
        linhas = {"e": [(16, 22), (18, 21), (20, 20), (22, 19)], "d": [(39, 22), (37, 21), (35, 20), (33, 19)]}
    elif expr in ("surpreso", "surpresa"):
        linhas = {"e": [(16, 19), (18, 18), (20, 18), (22, 19)], "d": [(33, 19), (35, 18), (37, 18), (39, 19)]}
    else:
        linhas = {"e": [(16, 21), (18, 20), (20, 20), (22, 21)], "d": [(33, 21), (35, 20), (37, 20), (39, 21)]}
    for lado in linhas.values():
        for x, y in lado:
            t.px(x, y, cor)
            t.px(x + 1, y, cor)


def boca(t: Tela, expr: str, quadro: str) -> None:
    escuro, lingua, dente = "6a2a24", "d8707a", "fbf5ec"
    if quadro == "fala":
        if expr in ("surpreso", "surpresa", "brava", "irritado"):
            t.rect(26, 35, 30, 38, escuro)
            t.rect(27, 37, 29, 38, lingua)
            if expr in ("brava", "irritado"):
                t.rect(26, 35, 30, 35, dente)
        else:
            t.rect(26, 35, 30, 37, escuro)
            t.rect(27, 37, 29, 37, lingua)
        return
    if expr in ("feliz",):
        for x, y in [(25, 35), (26, 36), (27, 36), (28, 36), (29, 36), (30, 35)]:
            t.px(x, y, escuro)
        t.rect(26, 35, 29, 35, lingua)
    elif expr in ("triste", "preocupada", "brava", "irritado", "nervoso"):
        for x, y in [(25, 37), (26, 36), (27, 36), (28, 36), (29, 36), (30, 37)]:
            t.px(x, y, escuro)
    elif expr in ("surpreso", "surpresa"):
        t.rect(27, 35, 29, 37, escuro)
    elif expr == "envergonhado":
        for x, y in [(25, 36), (26, 37), (27, 36), (28, 37), (29, 36), (30, 37)]:
            t.px(x, y, escuro)
    else:
        t.rect(26, 36, 29, 36, escuro)


def detalhes(t: Tela, p: dict, expr: str) -> None:
    # nariz
    t.px(29, 33, p["pele_s"])
    t.px(28, 34, p["pele_s"])
    # bochechas
    rosa = "ef8f84"
    if expr in ("envergonhado", "feliz", "nervoso") or p["estilo"] in ("coque",):
        for x in (17, 18, 19, 36, 37, 38):
            t.px(x, 34, rosa)
    if expr in ("envergonhado", "nervoso"):  # gota de suor
        for x, y in [(42, 18), (42, 19), (41, 20), (42, 20), (43, 20), (42, 21)]:
            t.px(x, y, "8ec5e8")
        t.px(41, 20, "dff0f4")
    if expr == "triste" and p["estilo"] == "cacheado":  # lágrima
        t.px(19, 33, "8ec5e8")
        t.px(19, 34, "8ec5e8")
    if expr in ("irritado", "brava"):  # veia de raiva
        for x, y in [(40, 13), (41, 13), (43, 13), (44, 13), (42, 14), (42, 15), (40, 16), (44, 16)]:
            t.px(x, y, "c8412d")
    if p.get("oculos"):
        for x0 in (14, 31):
            t.rect(x0 + 1, 22, x0 + 9, 22, "2a1a14")
            t.rect(x0 + 1, 34, x0 + 9, 34, "2a1a14")
            t.rect(x0, 23, x0, 33, "2a1a14")
            t.rect(x0 + 10, 23, x0 + 10, 33, "2a1a14")
            t.px(x0 + 8, 24, "fbf5ec")
            t.px(x0 + 9, 25, "fbf5ec")
        t.rect(25, 26, 30, 26, "2a1a14")


def retrato(nome: str, expr: str, quadro: str) -> Image.Image:
    p = PERSONAGENS[nome]
    t = Tela()
    cabelo_atras(t, p)
    corpo(t, p)
    rosto(t, p)
    cabelo_frente(t, p)
    olho(t, 16, p, expr, quadro, "e")
    olho(t, 33, p, expr, quadro, "d")
    sobrancelhas(t, p, expr)
    boca(t, expr, quadro)
    detalhes(t, p, expr)
    if p.get("bebe"):
        bebe(t)
    t.contorno()
    return t.imagem()


def main() -> None:
    folhas = []
    for nome, expressoes in EXPRESSOES.items():
        pasta = OUT / nome
        pasta.mkdir(parents=True, exist_ok=True)
        linha = []
        for expr in expressoes:
            for quadro in ("base", "pisca", "fala"):
                img = retrato(nome, expr, quadro)
                img.save(pasta / f"{expr}_{quadro}.png")
                if quadro == "base":
                    linha.append(img)
        folhas.append(linha)
    print("retratos gerados em", OUT)
    if "--preview" in sys.argv:
        destino = Path(sys.argv[sys.argv.index("--preview") + 1])
        lado = N * ESCALA
        largura = max(len(l) for l in folhas) * (lado + 10) + 10
        folha = Image.new("RGBA", (largura, len(folhas) * (lado + 10) + 10), (251, 245, 236, 255))
        for i, linha in enumerate(folhas):
            for j, img in enumerate(linha):
                folha.alpha_composite(img, (10 + j * (lado + 10), 10 + i * (lado + 10)))
        folha.resize((folha.width // 2, folha.height // 2), Image.NEAREST).save(destino)
        print("preview:", destino)


if __name__ == "__main__":
    main()
