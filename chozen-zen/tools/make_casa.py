"""Casa da Fase 1 em pixel art modular: fundo (chão, paredes, móveis encostados) + móveis
separados (sofá, mesas, cadeiras, abajur, plantas, geladeira...) que o jogo ordena por
profundidade, com colisão, interações e assentos.

Uso: python tools/make_casa.py [--preview caminho.png]
Saída: assets/casa/*.png e assets/casa/casa.json (posições em pixels do mundo)

Tudo desenhado em "pixels de arte" (1 = 4 px na tela), a mesma grade dos personagens,
na paleta quente do mapa anterior. A disposição segue a casa original (cozinha ao fundo,
sofá no meio, jantar à direita, porta de entrada embaixo e porta do quarto no corredor).
"""
import json
import random
import sys
from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "assets" / "casa"
U = 4
W, H = 384, 256
RNG = random.Random(11)


def C(h: str, a: int = 255) -> tuple:
    return (int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16), a)


P = {
    "contorno": C("2a1a12"),
    "piso": [C("b8743f"), C("b06e3a"), C("bd7a45")], "piso_junta": C("80482a"), "piso_luz": C("cc8a52"),
    "azulejo": C("ddd6c6"), "azulejo2": C("d2cab8"), "rejunte": C("b7ad9a"),
    "parede": C("ecd8b6"), "parede_listra": C("e4cfa9"), "parede_sombra": C("d6bd92"),
    "lambri": C("7a4e2f"), "lambri_luz": C("93613b"), "lambri_escuro": C("5e3a22"),
    "rodape": C("4a2e1c"), "topo_parede": C("4a2f1f"), "topo_luz": C("6b4a32"),
    "madeira": C("8a5a3b"), "madeira_luz": C("a8744c"), "madeira_escura": C("6b4429"),
    "creme": C("fbf5ec"), "rosa": C("d9878a"), "rosa_escuro": C("b9616a"), "pessego": C("f4b183"),
    "verde": C("2f6b52"), "verde_escuro": C("1f4b3b"), "folha": C("4f8f5a"), "folha_luz": C("7fb07a"),
    "vaso": C("c0704a"), "vaso_escuro": C("9a5236"),
    "sofa": C("6f9478"), "sofa_luz": C("8fb293"), "sofa_escuro": C("4f7058"),
    "metal": C("a9b0b5"), "metal_escuro": C("6d757b"), "preto": C("25272c"), "tela": C("2b3440"),
    "ceu": C("9ccbe0"), "ceu2": C("cfe3e6"), "ouro": C("e6b422"), "pedra": C("d9d2c3"), "pedra_luz": C("ebe5d8"),
    "geladeira": C("ecebe4"), "geladeira_s": C("c9c6bd"), "sombra": (40, 20, 10, 70),
}


class Tela:
    def __init__(self, w: int, h: int) -> None:
        self.a = np.zeros((h, w, 4), dtype=np.uint8)
        self.w, self.h = w, h

    def px(self, x, y, cor) -> None:
        x, y = int(x), int(y)
        if 0 <= x < self.w and 0 <= y < self.h:
            if len(cor) == 4 and cor[3] < 255:  # mistura (sombras)
                base = self.a[y, x].astype(float)
                a = cor[3] / 255
                if base[3] == 0:
                    self.a[y, x] = (*cor[:3], cor[3])
                else:
                    self.a[y, x, :3] = (base[:3] * (1 - a) + np.array(cor[:3]) * a).astype(np.uint8)
            else:
                self.a[y, x] = cor

    def rect(self, x0, y0, x1, y1, cor) -> None:
        for y in range(int(y0), int(y1) + 1):
            for x in range(int(x0), int(x1) + 1):
                self.px(x, y, cor)

    def elipse(self, cx, cy, rx, ry, cor) -> None:
        for y in range(int(cy - ry) - 1, int(cy + ry) + 2):
            for x in range(int(cx - rx) - 1, int(cx + rx) + 2):
                if ((x + 0.5 - cx) / rx) ** 2 + ((y + 0.5 - cy) / ry) ** 2 <= 1:
                    self.px(x, y, cor)

    def contorno(self, cor=None) -> None:
        cor = cor or P["contorno"]
        cheio = self.a[:, :, 3] > 0
        borda = np.zeros_like(cheio)
        borda[1:, :] |= cheio[:-1, :]
        borda[:-1, :] |= cheio[1:, :]
        borda[:, 1:] |= cheio[:, :-1]
        borda[:, :-1] |= cheio[:, 1:]
        self.a[borda & ~cheio] = cor

    def imagem(self) -> Image.Image:
        return Image.fromarray(self.a).resize((self.w * U, self.h * U), Image.NEAREST)


def caixa(t: Tela, x0, y0, x1, y_frente, y1, topo, frente, luz=None, escuro=None) -> None:
    """Móvel em 3/4: tampo (y0..y_frente-1) mais claro, frente (y_frente..y1) mais escura."""
    t.rect(x0, y0, x1, y_frente - 1, topo)
    t.rect(x0, y_frente, x1, y1, frente)
    if luz:
        t.rect(x0, y0, x1, y0, luz)
    if escuro:
        t.rect(x0, y1, x1, y1, escuro)
        t.rect(x0, y_frente, x0, y1, escuro)


# =================================================================== FUNDO

def piso(t: Tela, x0, y0, x1, y1) -> None:
    for linha, y in enumerate(range(y0, y1 + 1, 6)):
        desloc = RNG.randint(0, 30)
        x = x0 - desloc
        while x <= x1:
            comp = RNG.randint(26, 40)
            cor = RNG.choice(P["piso"])
            t.rect(max(x, x0), y, min(x + comp - 1, x1), min(y + 5, y1), cor)
            t.rect(max(x, x0), y, min(x + comp - 1, x1), y, P["piso_luz"])
            if x + comp <= x1:
                t.rect(x + comp - 1, y, x + comp - 1, min(y + 5, y1), P["piso_junta"])
            if RNG.random() < 0.15:  # nó da madeira
                kx = RNG.randint(max(x, x0) + 2, min(x + comp - 3, x1))
                t.px(kx, y + 3, P["piso_junta"])
            x += comp
        if y + 5 <= y1:
            t.rect(x0, y + 5, x1, y + 5, P["piso_junta"])


def azulejos(t: Tela, x0, y0, x1, y1) -> None:
    for y in range(y0, y1 + 1):
        for x in range(x0, x1 + 1):
            gx, gy = (x - x0) % 8, (y - y0) % 8
            if gx == 0 or gy == 0:
                t.px(x, y, P["rejunte"])
            else:
                xadrez = ((x - x0) // 8 + (y - y0) // 8) % 2
                t.px(x, y, P["azulejo"] if xadrez else P["azulejo2"])


def parede(t: Tela, x0, x1, topo=0, base=54, cozinha=False) -> None:
    t.rect(x0, topo, x1, topo + 5, P["topo_parede"])
    t.rect(x0, topo + 5, x1, topo + 5, P["topo_luz"])
    t.rect(x0, topo + 6, x1, base - 9, P["parede"])
    for x in range(x0, x1 + 1, 6):  # papel de parede listrado bem sutil
        t.rect(x, topo + 6, x, base - 9, P["parede_listra"])
    if cozinha:  # azulejos atrás da bancada
        for y in range(24, base - 8):
            for x in range(x0, x1 + 1):
                t.px(x, y, P["rejunte"] if (x % 5 == 0 or y % 4 == 0) else P["creme"])
    else:
        t.rect(x0, base - 8, x1, base - 3, P["lambri"])
        t.rect(x0, base - 8, x1, base - 8, P["lambri_luz"])
        for x in range(x0 + 4, x1, 12):
            t.rect(x, base - 7, x, base - 3, P["lambri_escuro"])
    t.rect(x0, base - 2, x1, base - 1, P["rodape"])
    t.rect(x0, topo + 6, x1, topo + 7, P["parede_sombra"])


def pilar(t: Tela, x0, x1, ate=80) -> None:
    t.rect(x0, 0, x1, ate, P["topo_parede"])
    t.rect(x0, 0, x0, ate, P["topo_luz"])
    t.rect(x0, ate + 1, x1, ate + 8, P["parede"])
    t.rect(x0, ate + 5, x1, ate + 8, P["lambri"])
    t.rect(x0, ate + 9, x1, ate + 9, P["rodape"])


def sombras_do_chao(t: Tela) -> None:
    for i, a in enumerate((70, 45, 22)):
        t.rect(34, 54 + i, 348, 54 + i, (40, 20, 10, a))
        t.rect(34 + i, 54, 34 + i, 232, (40, 20, 10, a))
        t.rect(347 - i, 54, 347 - i, 232, (40, 20, 10, a))


def estante(t: Tela, x0=44, y0=8, x1=94, y1=56) -> None:
    caixa(t, x0, y0, x1, y1 - 3, y1, P["madeira_escura"], P["madeira_escura"], P["madeira_luz"], P["rodape"])
    t.rect(x0 + 2, y0 + 2, x1 - 2, y1 - 4, C("3e2716"))
    prateleiras = [y0 + 2, y0 + 13, y0 + 24, y0 + 35]
    cores = [P["rosa"], P["verde"], P["pessego"], C("4a6fa5"), C("e6c46a"), P["creme"], C("8e5a8a"), P["rosa_escuro"]]
    for i, py in enumerate(prateleiras):
        x = x0 + 3
        while x < x1 - 4:
            if RNG.random() < 0.12 and i != 0:  # vaso ou caixinha
                t.rect(x, py + 5, x + 4, py + 9, P["vaso"])
                t.elipse(x + 2, py + 4, 2.5, 2, P["folha"])
                x += 6
                continue
            larg = RNG.choice([2, 2, 3])
            alt = RNG.randint(6, 9)
            cor = RNG.choice(cores)
            t.rect(x, py + 10 - alt, x + larg - 1, py + 9, cor)
            t.px(x, py + 10 - alt + 1, P["creme"])
            x += larg + (1 if RNG.random() < 0.3 else 0)
        t.rect(x0 + 2, py + 10, x1 - 2, py + 10, P["madeira_luz"])


def janela(t: Tela, x0, y0, x1, y1) -> None:
    t.rect(x0 - 1, y0 - 1, x1 + 1, y1 + 1, P["madeira_escura"])
    for y in range(y0, y1 + 1):
        cor = P["ceu"] if y < (y0 + y1) / 2 else P["ceu2"]
        t.rect(x0, y, x1, y, cor)
    t.rect(x0 + 3, y0 + 3, x0 + 8, y0 + 4, C("ffffff", 200))
    t.rect((x0 + x1) // 2, y0, (x0 + x1) // 2, y1, P["madeira_escura"])
    t.rect(x0, (y0 + y1) // 2, x1, (y0 + y1) // 2, P["madeira_escura"])
    t.rect(x0 - 2, y1 + 2, x1 + 2, y1 + 3, P["madeira"])
    t.rect(x0 - 3, y0 - 2, x0 + 1, y1 + 1, P["rosa"])
    t.rect(x1 - 1, y0 - 2, x1 + 3, y1 + 1, P["rosa"])


def cozinha(t: Tela) -> None:
    janela(t, 170, 9, 194, 22)
    # armários de cima
    caixa(t, 200, 6, 236, 18, 19, P["madeira"], P["madeira"], P["madeira_luz"], P["madeira_escura"])
    for x in (209, 218, 227):
        t.rect(x, 7, x, 18, P["madeira_escura"])
    # bancada: tampo de pedra + armários
    caixa(t, 150, 30, 236, 37, 54, P["pedra"], P["madeira"], P["pedra_luz"], P["madeira_escura"])
    for x in range(160, 236, 13):
        t.rect(x, 38, x, 53, P["madeira_escura"])
        t.rect(x - 3, 44, x - 2, 45, P["ouro"])
    # pia
    t.rect(172, 31, 190, 36, P["metal"])
    t.rect(174, 32, 188, 35, P["metal_escuro"])
    t.rect(180, 27, 181, 31, P["metal_escuro"])
    t.rect(180, 27, 184, 27, P["metal_escuro"])
    # fogão
    t.rect(206, 30, 226, 54, P["preto"])
    t.rect(206, 30, 226, 30, C("4a4d55"))
    for cx in (211, 221):
        t.elipse(cx, 33.5, 3, 1.6, C("4a4d55"))
    t.rect(208, 39, 224, 51, C("3a3d44"))
    t.rect(210, 41, 222, 48, C("1b1d21"))
    t.rect(209, 38, 223, 38, P["metal"])
    # potes e tábua
    t.rect(154, 27, 158, 30, P["rosa"])
    t.rect(162, 28, 168, 30, P["madeira_luz"])


def porta_quarto(t: Tela, x0=268, x1=292, y0=12, y1=53) -> None:
    t.rect(x0 - 2, y0 - 2, x1 + 2, y1, P["rodape"])
    t.rect(x0, y0, x1, y1, P["madeira"])
    for py0, py1 in ((y0 + 3, y0 + 18), (y0 + 22, y1 - 3)):
        t.rect(x0 + 3, py0, x1 - 3, py1, P["madeira_luz"])
        t.rect(x0 + 4, py0 + 1, x1 - 4, py1 - 1, P["madeira"])
    t.rect(x1 - 4, (y0 + y1) // 2, x1 - 3, (y0 + y1) // 2 + 1, P["ouro"])
    t.rect(296, 28, 298, 32, P["creme"])
    t.px(297, 30, P["metal_escuro"])


def foto_familia(t: Tela, x0=304, y0=16) -> None:
    t.rect(x0, y0, x0 + 16, y0 + 13, P["madeira_escura"])
    t.rect(x0 + 1, y0 + 1, x0 + 15, y0 + 12, P["ceu2"])
    t.rect(x0 + 1, y0 + 9, x0 + 15, y0 + 12, C("e7d3ae"))
    for cx, cor, r in ((x0 + 5, P["rosa"], 2), (x0 + 9, P["verde"], 1.6), (x0 + 12, C("4a6fa5"), 2)):
        t.elipse(cx, y0 + 6, r, r, C("6b3a1f"))
        t.rect(cx - 1, y0 + 8, cx + 1, y0 + 11, cor)


def tv(t: Tela) -> None:
    # rack encostado na parede da esquerda
    caixa(t, 35, 122, 51, 128, 178, P["madeira_luz"], P["madeira"], P["madeira_luz"], P["madeira_escura"])
    for y in (140, 156):
        t.rect(35, y, 51, y, P["madeira_escura"])
        t.rect(48, y + 6, 49, y + 7, P["ouro"])
    # TV na parede, tela virada para a sala
    t.rect(37, 100, 49, 150, P["preto"])
    t.rect(39, 102, 47, 148, P["tela"])
    t.rect(40, 103, 41, 116, C("3c4858"))
    t.rect(42, 150, 44, 154, P["preto"])


def aparador(t: Tela) -> None:
    caixa(t, 330, 46, 346, 54, 74, P["madeira_luz"], P["madeira"], P["madeira_luz"], P["madeira_escura"])
    t.rect(333, 60, 343, 60, P["madeira_escura"])
    t.rect(335, 38, 341, 46, P["vaso"])
    for cx, cy in ((336, 33), (340, 31), (338, 28)):
        t.elipse(cx, cy, 3.5, 3, P["folha"])
    t.elipse(337, 30, 1.5, 1.2, P["folha_luz"])


def tapete(t: Tela, x0=108, y0=154, x1=198, y1=214) -> None:
    t.rect(x0, y0, x1, y1, C("e8d4ad"))
    t.rect(x0 + 2, y0 + 2, x1 - 2, y1 - 2, P["rosa"])
    t.rect(x0 + 4, y0 + 4, x1 - 4, y1 - 4, C("e8d4ad"))
    cx, cy = (x0 + x1) // 2, (y0 + y1) // 2
    for i in range(14):
        t.rect(cx - 13 + i, cy - i // 2, cx - 13 + i, cy + i // 2, P["pessego"])
        t.rect(cx + 13 - i, cy - i // 2, cx + 13 - i, cy + i // 2, P["pessego"])
    for x in range(x0 + 8, x1 - 6, 6):
        t.px(x, y0 + 6, P["rosa_escuro"])
        t.px(x, y1 - 6, P["rosa_escuro"])
    for y in range(y0, y1 + 1, 2):  # franjas
        t.px(x0 - 1, y, C("e8d4ad"))
        t.px(x1 + 1, y, C("e8d4ad"))


def fundo() -> Tela:
    t = Tela(W, H)
    piso(t, 34, 54, 347, 231)
    piso(t, 276, 232, 299, 252)
    azulejos(t, 126, 54, 237, 86)
    parede(t, 34, 119)
    parede(t, 126, 237, cozinha=True)
    parede(t, 244, 347)
    pilar(t, 120, 125)
    pilar(t, 238, 243)
    sombras_do_chao(t)
    # paredes laterais e de baixo (vistas de cima)
    t.rect(26, 0, 33, 240, P["topo_parede"])
    t.rect(33, 0, 33, 240, P["topo_luz"])
    t.rect(348, 0, 355, 240, P["topo_parede"])
    t.rect(348, 0, 348, 240, P["topo_luz"])
    t.rect(26, 232, 275, 240, P["topo_parede"])
    t.rect(300, 232, 355, 240, P["topo_parede"])
    t.rect(26, 232, 275, 232, P["topo_luz"])
    t.rect(300, 232, 355, 232, P["topo_luz"])
    t.rect(270, 232, 275, 255, P["topo_parede"])
    t.rect(300, 232, 305, 255, P["topo_parede"])
    t.rect(279, 244, 296, 251, P["rosa_escuro"])
    t.rect(280, 245, 295, 250, P["rosa"])
    t.rect(276, 253, 299, 255, P["rodape"])
    estante(t)
    cozinha(t)
    porta_quarto(t)
    foto_familia(t)
    tv(t)
    aparador(t)
    tapete(t)
    return t


# ================================================================== MÓVEIS

def sprite_sofa() -> Tela:
    t = Tela(78, 42)
    s, l, e = P["sofa"], P["sofa_luz"], P["sofa_escuro"]
    t.rect(4, 0, 73, 14, s)            # encosto
    t.rect(4, 0, 73, 1, l)
    for x in (27, 50):
        t.rect(x, 3, x, 14, e)
    t.rect(4, 12, 73, 14, e)
    t.rect(8, 14, 69, 28, l)           # assentos (almofadas)
    t.rect(8, 14, 69, 15, C("a9c7ab"))
    for x in (28, 49):
        t.rect(x, 14, x, 28, e)
    t.rect(8, 29, 69, 36, s)           # frente
    t.rect(8, 36, 69, 36, e)
    for x0 in (0, 70):                 # braços
        t.rect(x0, 4, x0 + 7, 36, s)
        t.rect(x0, 4, x0 + 7, 6, l)
        t.rect(x0 + (7 if x0 == 0 else 0), 7, x0 + (7 if x0 == 0 else 0), 36, e)
    t.rect(2, 37, 4, 40, P["madeira_escura"])
    t.rect(73, 37, 75, 40, P["madeira_escura"])
    # almofada rosa
    t.rect(11, 8, 20, 17, P["rosa"])
    t.rect(11, 8, 20, 9, C("eba4a6"))
    t.contorno()
    return t


def sprite_mesa_centro() -> Tela:
    t = Tela(52, 26)
    caixa(t, 0, 0, 51, 16, 21, P["madeira_luz"], P["madeira"], C("c08a5e"), P["madeira_escura"])
    t.rect(2, 22, 4, 25, P["madeira_escura"])
    t.rect(47, 22, 49, 25, P["madeira_escura"])
    t.rect(8, 4, 13, 9, P["vaso"])              # vasinho
    t.elipse(10.5, 3, 4, 3, P["folha"])
    t.rect(30, 6, 38, 11, C("4a6fa5"))          # livro
    t.rect(31, 7, 37, 7, P["creme"])
    t.rect(42, 8, 45, 9, P["preto"])            # controle
    t.contorno()
    return t


def sprite_mesa_jantar(com_comida=False) -> Tela:
    t = Tela(64, 36)
    caixa(t, 0, 0, 63, 24, 30, P["madeira"], P["madeira_escura"], P["madeira_luz"], P["rodape"])
    t.rect(4, 8, 59, 15, P["creme"])            # trilho de mesa
    t.rect(4, 8, 59, 8, C("e9dfcf"))
    for x in (2, 60):
        t.rect(x, 31, x + 1, 35, P["rodape"])
    t.rect(29, 6, 34, 11, P["vaso"])
    t.elipse(31.5, 4.5, 4, 3, P["folha"])
    if com_comida:
        for cx in (8, 55):  # pratos nas cabeceiras
            t.elipse(cx, 12, 5, 3.2, P["creme"])
            t.elipse(cx, 12, 3.5, 2.2, C("e9dfcf"))
            t.rect(cx - 2, 11, cx + 1, 12, C("e6c46a"))
            t.rect(cx + 1, 12, cx + 2, 13, C("7fb07a"))
            t.rect(cx - 1, 13, cx, 13, C("c8412d"))
        t.elipse(31.5, 18, 6, 3, C("c0704a"))   # panela
        t.elipse(31.5, 17, 4.5, 1.8, C("e6a86a"))
        t.rect(24, 17, 25, 18, C("9a5236"))
        t.rect(38, 17, 39, 18, C("9a5236"))
        t.rect(18, 19, 21, 20, P["metal"])      # copos
        t.rect(42, 19, 45, 20, P["metal"])
    t.contorno()
    return t


def sprite_cadeira(tipo: str) -> Tela:
    m, l, e = P["madeira"], P["madeira_luz"], P["madeira_escura"]
    if tipo == "lado":  # encosto à esquerda (cabeceira esquerda); a direita é espelhada
        t = Tela(14, 26)
        t.rect(0, 0, 3, 18, m)
        t.rect(0, 0, 3, 0, l)
        t.rect(1, 3, 2, 15, e)
        t.rect(0, 12, 13, 17, l)
        t.rect(0, 17, 13, 19, m)
        t.rect(0, 20, 1, 25, e)
        t.rect(12, 20, 13, 25, e)
    elif tipo == "cima":  # encosto no fundo, assento virado para a câmera
        t = Tela(14, 24)
        t.rect(1, 0, 12, 10, m)
        t.rect(1, 0, 12, 1, l)
        for x in (4, 6, 8):
            t.rect(x, 3, x, 9, e)
        t.rect(0, 10, 13, 15, l)
        t.rect(0, 15, 13, 17, m)
        t.rect(0, 18, 1, 23, e)
        t.rect(12, 18, 13, 23, e)
    else:  # "baixo": encosto virado para a câmera
        t = Tela(14, 24)
        t.rect(0, 0, 13, 5, l)
        t.rect(1, 6, 12, 18, m)
        t.rect(1, 6, 12, 6, l)
        for x in (4, 6, 8):
            t.rect(x, 8, x, 16, e)
        t.rect(0, 19, 1, 23, e)
        t.rect(12, 19, 13, 23, e)
    t.contorno()
    return t


def sprite_abajur(aceso=False) -> Tela:
    t = Tela(16, 48)
    cupula = C("fbe6b8") if aceso else C("e8d2a8")
    for i, y in enumerate(range(2, 14)):
        meia = 4 + i * 0.35
        t.rect(8 - meia, y, 7 + meia, y, cupula)
    t.rect(4, 13, 11, 13, C("d4b88a"))
    if aceso:
        t.rect(6, 4, 9, 11, C("fff6d8"))
    t.rect(7, 14, 8, 43, C("3a2a22"))
    t.rect(4, 43, 11, 46, C("3a2a22"))
    t.rect(4, 43, 11, 43, C("5a4636"))
    t.contorno()
    return t


def sprite_planta(grande=True) -> Tela:
    t = Tela(24, 34) if grande else Tela(16, 24)
    w, h = t.w, t.h
    vaso_topo = h - 10 if grande else h - 8
    t.rect(4, vaso_topo, w - 5, h - 1, P["vaso"])
    t.rect(4, vaso_topo, w - 5, vaso_topo + 1, C("d88a62"))
    t.rect(w - 7, vaso_topo + 2, w - 5, h - 1, P["vaso_escuro"])
    folhas = [(w / 2, vaso_topo - 8, 7, 6), (w / 2 - 5, vaso_topo - 4, 5, 4), (w / 2 + 5, vaso_topo - 5, 5, 4),
              (w / 2, vaso_topo - 15, 5, 5)] if grande else [(w / 2, vaso_topo - 5, 5, 4.5), (w / 2 - 3, vaso_topo - 2, 3.5, 3), (w / 2 + 3, vaso_topo - 3, 3.5, 3)]
    for cx, cy, rx, ry in folhas:
        t.elipse(cx, cy, rx, ry, P["folha"])
    for cx, cy, rx, ry in folhas[:2]:
        t.elipse(cx - 1, cy - 1, rx * 0.45, ry * 0.4, P["folha_luz"])
    t.contorno()
    return t


def sprite_geladeira(aberta=False) -> Tela:
    t = Tela(30, 54)
    g, s = P["geladeira"], P["geladeira_s"]
    t.rect(0, 0, 21, 52, g)
    t.rect(0, 0, 21, 1, C("ffffff"))
    t.rect(19, 2, 21, 52, s)
    t.rect(0, 18, 21, 18, s)
    t.rect(16, 6, 17, 14, P["metal_escuro"])
    t.rect(16, 22, 17, 34, P["metal_escuro"])
    t.rect(4, 24, 9, 28, P["rosa"])     # ímã com desenho
    t.rect(10, 30, 13, 33, P["pessego"])
    if aberta:
        t.rect(1, 19, 18, 51, C("fff7dd"))   # luz de dentro
        for y in (28, 37, 45):
            t.rect(1, y, 18, y, s)
        t.rect(3, 23, 6, 27, C("c8412d"))
        t.rect(9, 31, 13, 36, C("7fb07a"))
        t.rect(4, 40, 8, 44, C("e6c46a"))
        t.rect(22, 18, 29, 52, g)           # porta aberta para a direita
        t.rect(22, 18, 29, 19, C("ffffff"))
        t.rect(23, 22, 28, 22, s)
        t.rect(23, 32, 28, 32, s)
    t.contorno()
    return t


def sprite_relogio() -> Tela:
    t = Tela(12, 12)
    t.elipse(6, 6, 5.5, 5.5, P["madeira_escura"])
    t.elipse(6, 6, 4.5, 4.5, P["creme"])
    t.contorno()
    return t


def sprite_tela_tv() -> Tela:
    t = Tela(9, 47)
    t.rect(0, 0, 8, 46, C("8ec5e8"))
    t.rect(0, 0, 8, 10, C("cfe6ee"))
    t.rect(1, 14, 7, 22, C("f4b183"))
    t.rect(2, 26, 6, 34, C("7fb07a"))
    return t


# ================================================================== FICHA

def montar() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    fundo().imagem().save(OUT / "fundo.png")
    sprites = {
        "sofa": sprite_sofa(), "mesa_centro": sprite_mesa_centro(),
        "mesa_jantar": sprite_mesa_jantar(), "mesa_jantar_comida": sprite_mesa_jantar(True),
        "cadeira_lado": sprite_cadeira("lado"), "cadeira_cima": sprite_cadeira("cima"), "cadeira_baixo": sprite_cadeira("baixo"),
        "abajur": sprite_abajur(), "abajur_aceso": sprite_abajur(True),
        "planta_grande": sprite_planta(True), "planta_pequena": sprite_planta(False),
        "geladeira": sprite_geladeira(), "geladeira_aberta": sprite_geladeira(True),
        "relogio": sprite_relogio(), "tv_tela": sprite_tela_tv(),
    }
    for nome, t in sprites.items():
        t.imagem().save(OUT / f"{nome}.png")
    cadeira_dir = Image.open(OUT / "cadeira_lado.png").transpose(Image.FLIP_LEFT_RIGHT)
    cadeira_dir.save(OUT / "cadeira_lado_d.png")

    def px(v):
        return [v[0] * U, v[1] * U]

    def obj(nome, png, topo_esq, ordem_y, colisao=None, **extra):
        """topo_esq: canto do sprite em unidades de arte; ordem_y: linha (arte) usada no y-sort."""
        d = {"nome": nome, "png": f"res://assets/casa/{png}.png",
             "pos": px((topo_esq[0], ordem_y)), "offset": [0, (topo_esq[1] - ordem_y) * U]}
        if colisao:
            d["colisao"] = [colisao[0] * U, colisao[1] * U, colisao[2] * U, colisao[3] * U]
        d.update(extra)
        return d

    objetos = [
        obj("sofa", "sofa", (114, 110), 128, (115, 118, 76, 30),
            interacao={"tipo": "sentar", "texto": "[E] Sentar no sofá", "zona": px((112, 150)) + px((82, 14))},
            assentos=[{"pos": px((x, 146)), "dir": "down", "saida": px((x, 158))} for x in (128, 152, 176)]),
        obj("mesa_centro", "mesa_centro", (127, 168), 186, (128, 172, 50, 16)),
        obj("abajur", "abajur", (75, 64), 111, (77, 106, 11, 7),
            interacao={"tipo": "abajur", "texto": "[E] Acender/apagar o abajur", "zona": px((68, 104)) + px((28, 22))},
            alternativo="res://assets/casa/abajur_aceso.png"),
        obj("planta_canto", "planta_grande", (36, 196), 229, (38, 220, 20, 10),
            interacao={"tipo": "texto", "texto": "[E] Olhar a planta", "zona": px((36, 208)) + px((30, 26)),
                       "falas": ["A samambaia da sua mãe. Ela conversa com essa planta todo dia.", "Alguém esqueceu de regar. Provavelmente você."]}),
        obj("planta_entrada", "planta_pequena", (309, 206), 229, (311, 222, 12, 8)),
        obj("planta_estante", "planta_pequena", (96, 34), 57, (98, 50, 12, 8)),
        obj("geladeira", "geladeira", (128, 4), 57, (128, 40, 22, 18),
            alternativo="res://assets/casa/geladeira_aberta.png"),
        obj("relogio", "relogio", (102, 14), 0, None, decoracao="relogio"),
        obj("mesa_jantar", "mesa_jantar", (262, 100), 133, (262, 108, 64, 26),
            alternativo="res://assets/casa/mesa_jantar_comida.png"),
        obj("cadeira_e", "cadeira_lado", (247, 104), 122, (248, 116, 12, 8),
            assento={"pos": px((253, 125)), "dir": "right", "saida": px((246, 140))}),
        obj("cadeira_d", "cadeira_lado_d", (327, 104), 122, (328, 116, 12, 8),
            assento={"pos": px((334, 125)), "dir": "left", "saida": px((340, 140))}),
        obj("cadeira_c1", "cadeira_cima", (272, 86), 100, (272, 96, 14, 6),
            assento={"pos": px((279, 105)), "dir": "down", "saida": px((279, 82))}),
        obj("cadeira_c2", "cadeira_cima", (296, 86), 100, (296, 96, 14, 6),
            assento={"pos": px((303, 105)), "dir": "down", "saida": px((303, 82))}),
        obj("cadeira_b1", "cadeira_baixo", (272, 134), 152, (272, 140, 14, 10),
            assento={"pos": px((279, 147)), "dir": "up", "saida": px((279, 162))}),
        obj("cadeira_b2", "cadeira_baixo", (296, 134), 152, (296, 140, 14, 10),
            assento={"pos": px((303, 147)), "dir": "up", "saida": px((303, 162))}),
        obj("tv_tela", "tv_tela", (39, 102), 0, None, decoracao="tv"),
    ]
    # colisões das paredes e dos móveis encostados (que fazem parte do fundo)
    paredes = [
        (0, 0, 34, 256), (348, 0, 36, 256), (34, 0, 314, 57),      # laterais e parede do fundo
        (120, 0, 6, 89), (238, 0, 6, 89),                           # pilares
        (34, 232, 242, 24), (300, 232, 84, 24), (270, 252, 36, 4),  # parede de baixo e soleira
        (150, 30, 87, 28), (35, 120, 17, 59), (35, 98, 15, 22),    # bancada, rack, TV
        (44, 46, 51, 14), (330, 46, 17, 30),                        # estante, aparador
    ]
    interacoes_fundo = [
        {"tipo": "tv", "texto": "[E] Ligar/desligar a TV", "zona": px((52, 112)) + px((20, 56))},
        {"tipo": "texto", "texto": "[E] Olhar a estante", "zona": px((44, 58)) + px((50, 12)),
         "falas": ["Os livros da faculdade da sua mãe. Ela nunca terminou o curso.", "Um álbum de fotos com a etiqueta \"bebê\". O bebê é você."]},
        {"tipo": "texto", "texto": "[E] Olhar a foto", "zona": px((300, 54)) + px((24, 12)),
         "falas": ["Vocês três na praia, no ano passado. Todo mundo sorrindo.", "Na foto você ainda tinha o dente da frente lascado."]},
        {"tipo": "texto", "texto": "[E] Olhar o fogão", "zona": px((204, 56)) + px((24, 10)),
         "falas": ["Cheiro de arroz e feijão. Sua mãe cozinhou mesmo cansada."]},
        {"tipo": "pia", "texto": "[E] Beber um copo d'água", "zona": px((170, 56)) + px((22, 10)),
         "falas": ["Água gelada. Ajuda a pensar.", "Mais um copo d'água."]},
    ]
    ficha = {
        "tamanho": [W * U, H * U],
        "fundo": "res://assets/casa/fundo.png",
        "objetos": objetos,
        "paredes": [[a * U for a in r] for r in paredes],
        "interacoes": interacoes_fundo,
        "luzes": {"Abajur": px((82, 72)), "Jantar": px((294, 112)), "Cozinha": px((182, 40)), "Corredor": px((280, 60))},
        "zonas": {"Geladeira": px((139, 64)) + px((30, 16)), "Jantar": px((294, 122)) + px((110, 84)), "Quarto": px((280, 66)) + px((40, 14))},
        "mae_caminho": [px(p) for p in ((150, 100), (205, 95), (215, 150), (90, 140), (250, 175))],
        "mae_jantar": [px((240, 150)), px((246, 140)), px((253, 125))],
        "assento_mae_jantar": "cadeira_e",
        "assento_jogador_jantar": "cadeira_d",
    }
    (OUT / "casa.json").write_text(json.dumps(ficha, ensure_ascii=False, indent=1), encoding="utf-8")
    print("casa gerada:", len(objetos), "objetos")


def previa(destino: Path) -> None:
    ficha = json.loads((OUT / "casa.json").read_text(encoding="utf-8"))
    base = Image.open(OUT / "fundo.png").convert("RGBA")
    for o in sorted(ficha["objetos"], key=lambda o: o["pos"][1]):
        img = Image.open(OUT / Path(o["png"]).name).convert("RGBA")
        base.alpha_composite(img, (int(o["pos"][0] + o["offset"][0]), int(o["pos"][1] + o["offset"][1])))
    base.save(destino)


if __name__ == "__main__":
    montar()
    if "--preview" in sys.argv:
        previa(Path(sys.argv[sys.argv.index("--preview") + 1]))
