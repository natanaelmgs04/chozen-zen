"""Desenha os sprites da professora (cutscene de abertura) em pixel art, pixel a pixel.

Uso: python tools/make_professora.py [--preview caminho.png]
Saída: assets/sprites/professora/*.png (grade de 4 px, mesma escala do jogador e da mãe)

Feito à mão em código (formas + contorno automático) para seguir a grade dos outros sprites,
sem arte gerada por IA. Cada pose é uma grade de 24×35 "pixels de arte".
"""
import sys
from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "assets" / "sprites" / "professora"
U = 4
W, H = 24, 35
M = 1  # margem para o contorno

PALETA = {
    "O": "2a1a14",  # contorno
    "H": "3b2a2e",  # cabelo
    "h": "5b4248",  # brilho do cabelo
    "S": "d9a07a",  # pele
    "s": "b97f5c",  # sombra da pele
    "R": "e8968a",  # bochecha
    "E": "1f1a1a",  # olho
    "W": "fbf5ec",  # branco do olho
    "G": "2a1a14",  # armação dos óculos
    "L": "cfe6ee",  # lente
    "M": "9a4a40",  # boca
    "C": "e0a43c",  # cardigã mostarda
    "c": "b9802a",  # sombra do cardigã
    "B": "fbf5ec",  # blusa
    "b": "e2d6c6",  # sombra da blusa
    "K": "2f6b52",  # saia verde (cor da identidade)
    "k": "1f4b3b",  # dobra da saia
    "F": "5a3a2a",  # sapato
    "P": "fbf5ec",  # papel
    "p": "8ec5e8",  # linha do papel
}


class Pose:
    def __init__(self) -> None:
        self.g = np.full((H + 2 * M, W + 2 * M), ".", dtype="<U1")

    def px(self, x: int, y: int, c: str) -> None:
        if 0 <= x < W and 0 <= y < H:
            self.g[y + M, x + M] = c

    def rect(self, x0: int, y0: int, x1: int, y1: int, c: str) -> None:
        for y in range(y0, y1 + 1):
            for x in range(x0, x1 + 1):
                self.px(x, y, c)

    def elipse(self, cx: float, cy: float, rx: float, ry: float, c: str, so_preenchido=False) -> None:
        for y in range(H):
            for x in range(W):
                if ((x + 0.5 - cx) / rx) ** 2 + ((y + 0.5 - cy) / ry) ** 2 <= 1.0:
                    if not so_preenchido or self.g[y + M, x + M] != ".":
                        self.px(x, y, c)

    def get(self, x: int, y: int) -> str:
        return self.g[y + M, x + M]

    def contorno(self) -> None:
        cheio = self.g != "."
        borda = np.zeros_like(cheio)
        borda[1:, :] |= cheio[:-1, :]
        borda[:-1, :] |= cheio[1:, :]
        borda[:, 1:] |= cheio[:, :-1]
        borda[:, :-1] |= cheio[:, 1:]
        self.g[borda & ~cheio] = "O"

    def imagem(self) -> Image.Image:
        h, w = self.g.shape
        img = np.zeros((h, w, 4), dtype=np.uint8)
        for (y, x), c in np.ndenumerate(self.g):
            if c != ".":
                cor = PALETA[c]
                img[y, x] = [int(cor[0:2], 16), int(cor[2:4], 16), int(cor[4:6], 16), 255]
        return Image.fromarray(img).resize((w * U, h * U), Image.NEAREST)

    def espelhar(self) -> "Pose":
        nova = Pose()
        nova.g = self.g[:, ::-1].copy()
        return nova


# ------------------------------------------------------------------- partes

def cabeca_redonda(p: Pose, x0: int, x1: int, y0: int, y1: int, c: str) -> None:
    """Cabeça "quadrada arredondada", como a do jogador (cantos comidos em 2 e 1)."""
    p.rect(x0 + 2, y0, x1 - 2, y1, c)
    p.rect(x0 + 1, y0 + 1, x1 - 1, y1 - 1, c)
    p.rect(x0, y0 + 2, x1, y1 - 2, c)


def cabeca(p: Pose, vista: str) -> None:
    coque_x = 11.5 if vista == "frente" or vista == "costas" else 8.0
    p.elipse(coque_x, 2.2, 2.4, 2.2, "H")
    cabeca_redonda(p, 4, 19, 3, 16, "H")
    p.px(int(coque_x) - 1, 1, "h")
    if vista == "frente":
        p.rect(7, 4, 10, 4, "h")
        rosto(p)
    elif vista == "lado":
        p.rect(6, 4, 9, 4, "h")
        rosto_lado(p)
    else:
        p.rect(8, 4, 12, 4, "h")
        p.rect(6, 5, 7, 5, "h")


def olho(p: Pose, x: int, y: int) -> None:
    """Olho de 1 pixel de largura, como os pontinhos do jogador e da mãe, atrás da lente clara."""
    p.rect(x, y, x, y + 1, "E")
    p.px(x, y + 2, "L")


def rosto(p: Pose) -> None:
    cabeca_redonda(p, 6, 17, 7, 16, "S")
    # franja de lado (cabelo cobre a testa à esquerda)
    p.rect(5, 6, 12, 7, "H")
    p.rect(6, 8, 8, 8, "H")
    p.px(13, 7, "H")
    p.px(5, 8, "H")
    p.px(18, 8, "H")
    # óculos finos por cima dos olhos
    for x0 in (6, 13):
        p.rect(x0, 9, x0 + 4, 9, "G")
        p.rect(x0, 13, x0 + 4, 13, "G")
        p.rect(x0, 10, x0, 12, "G")
        p.rect(x0 + 4, 10, x0 + 4, 12, "G")
        p.rect(x0 + 1, 10, x0 + 3, 12, "L")
    p.rect(11, 10, 12, 10, "G")
    olho(p, 8, 10)
    olho(p, 15, 10)
    p.px(6, 14, "R")
    p.px(17, 14, "R")
    p.rect(11, 15, 12, 15, "M")
    p.rect(10, 17, 13, 17, "s")


def rosto_lado(p: Pose) -> None:
    cabeca_redonda(p, 10, 19, 7, 16, "S")
    p.rect(9, 6, 15, 7, "H")
    p.rect(9, 8, 11, 15, "H")
    p.px(20, 11, "S")  # nariz
    p.px(20, 12, "S")
    p.rect(14, 9, 18, 9, "G")
    p.rect(14, 13, 18, 13, "G")
    p.rect(14, 10, 14, 12, "G")
    p.rect(18, 10, 18, 12, "G")
    p.rect(15, 10, 17, 12, "L")
    olho(p, 16, 10)
    p.rect(11, 10, 13, 10, "G")  # haste dos óculos
    p.px(14, 14, "R")
    p.rect(17, 15, 18, 15, "M")
    p.rect(12, 17, 14, 17, "s")


def corpo(p: Pose, vista: str) -> None:
    if vista == "lado":
        p.rect(9, 17, 15, 25, "C")
        p.rect(9, 17, 9, 25, "c")
        p.rect(14, 17, 15, 18, "B")
        return
    p.rect(7, 17, 16, 25, "C")
    p.rect(7, 18, 7, 25, "c")
    p.rect(16, 18, 16, 25, "c")
    if vista == "frente":
        p.rect(10, 17, 13, 25, "B")
        p.rect(10, 17, 10, 18, "b")
        p.rect(13, 17, 13, 18, "b")
        p.px(11, 19, "b")
        p.px(11, 22, "b")
    else:
        p.rect(11, 18, 12, 24, "c")


def braco(p: Pose, lado: str, pose: str, deslocamento: int = 0) -> None:
    """lado: 'e' (esquerda da tela) ou 'd'. pose: 'baixo', 'cima' (erguido) ou 'frente'."""
    x = 5 if lado == "e" else 17
    if pose == "baixo":
        p.rect(x, 18 + deslocamento, x + 1, 24 + deslocamento, "C")
        p.rect(x if lado == "e" else x + 1, 18 + deslocamento, x if lado == "e" else x + 1, 24 + deslocamento, "c")
        p.rect(x, 25 + deslocamento, x + 1, 26 + deslocamento, "S")
    elif pose == "cima":
        p.rect(x, 9, x + 1, 18, "C")
        p.rect(x + (1 if lado == "d" else 0), 9, x + (1 if lado == "d" else 0), 18, "c")
        p.rect(x, 7, x + 1, 8, "S")


def saia_pernas(p: Pose, passo: int = 0, vista: str = "frente") -> None:
    if vista == "lado":
        p.rect(9, 26, 16, 30, "K")
        p.rect(8, 28, 16, 30, "K")
        p.rect(11, 27, 11, 30, "k")
        e = 1 if passo == 1 else 0
        p.rect(11, 31, 12, 32 - e, "S")
        p.rect(11, 33 - e, 13, 33 - e, "F")
        p.rect(13, 31, 14, 32, "s")
        p.rect(13, 33, 15, 33, "F")
        return
    p.rect(7, 26, 16, 27, "K")
    p.rect(6, 28, 17, 30, "K")
    for x in (9, 14):
        p.rect(x, 27, x, 30, "k")
    sobe_e = 1 if passo == 1 else 0
    sobe_d = 1 if passo == 2 else 0
    p.rect(8, 31, 9, 32 - sobe_e, "S")
    p.rect(7, 33 - sobe_e, 9, 33 - sobe_e, "F")
    p.rect(14, 31, 15, 32 - sobe_d, "S")
    p.rect(14, 33 - sobe_d, 16, 33 - sobe_d, "F")


def papel_no_alto(p: Pose) -> None:
    p.rect(16, 3, 21, 7, "P")
    p.rect(17, 4, 20, 4, "p")
    p.rect(17, 6, 19, 6, "p")


# -------------------------------------------------------------------- poses

def frente(passo: int = 0, braco_d: str = "baixo", papel: bool = False) -> Pose:
    p = Pose()
    balanco = {0: (0, 0), 1: (1, -1), 2: (-1, 1)}[passo]
    braco(p, "e", "baixo", balanco[0] if passo else 0)
    braco(p, "d", braco_d, balanco[1] if passo and braco_d == "baixo" else 0)
    corpo(p, "frente")
    saia_pernas(p, passo)
    cabeca(p, "frente")
    if papel:
        papel_no_alto(p)
    p.contorno()
    return p


def costas(escrevendo: bool = False) -> Pose:
    p = Pose()
    braco(p, "e", "baixo")
    braco(p, "d", "cima" if escrevendo else "baixo")
    corpo(p, "costas")
    saia_pernas(p, 0, "costas")
    cabeca(p, "costas")
    p.contorno()
    return p


def lado(apontando: bool = False, passo: int = 0) -> Pose:
    p = Pose()
    corpo(p, "lado")
    saia_pernas(p, passo, "lado")
    if apontando:
        p.rect(13, 19, 20, 20, "C")
        p.rect(13, 20, 20, 20, "c")
        p.rect(21, 19, 22, 20, "S")
    else:
        p.rect(11, 18, 12, 24, "C")
        p.rect(11, 18, 11, 24, "c")
        p.rect(11, 25, 12, 26, "S")
    cabeca(p, "lado")
    p.contorno()
    return p


POSES = {
    "frente": frente(),
    "frente_passo_1": frente(1),
    "frente_passo_2": frente(2),
    "frente_papel": frente(braco_d="cima", papel=True),
    "costas": costas(),
    "costas_escrevendo": costas(True),
    "direita": lado(),
    "direita_aponta": lado(True),
}


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    imagens = {nome: pose.imagem() for nome, pose in POSES.items()}
    for nome, img in imagens.items():
        img.save(OUT / f"{nome}.png")
        print(nome, img.size)
    if "--preview" in sys.argv:
        destino = Path(sys.argv[sys.argv.index("--preview") + 1])
        larg = sum(i.width for i in imagens.values()) + 24 * (len(imagens) + 1)
        folha = Image.new("RGBA", (larg, 190), (251, 245, 236, 255))
        x = 24
        jogador = Image.open(ROOT / "assets/sprites/jogador/idle_down_0.png").convert("RGBA")
        for img in imagens.values():
            folha.alpha_composite(img, (x, 170 - img.height))
            x += img.width + 24
        folha = folha.resize((folha.width * 2, folha.height * 2), Image.NEAREST)
        comparacao = Image.new("RGBA", (folha.width, folha.height + 340), (251, 245, 236, 255))
        comparacao.alpha_composite(folha, (0, 0))
        mae = Image.open(ROOT / "assets/sprites/mae/idle_down_0.png").convert("RGBA")
        base = folha.height + 320
        for i, img in enumerate([jogador, imagens["frente"], mae]):
            img2 = img.resize((img.width * 2, img.height * 2), Image.NEAREST)
            comparacao.alpha_composite(img2, (60 + i * 260, base - img2.height))
        comparacao.save(destino)
        print("preview:", destino)


if __name__ == "__main__":
    main()
