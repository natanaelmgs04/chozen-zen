"""Poses de sentar e comer do jogador e da mãe, feitas a partir dos sprites em pé.

Uso: python tools/make_sentado.py [--preview caminho.png]

Para cada personagem: mantém a parte de cima do sprite (cabeça e tronco), redesenha as pernas
pixel a pixel na pose sentada (com as cores e o contorno do próprio sprite) e acrescenta o
braço levando o garfo à boca. Também escreve as animações novas no SpriteFrames do personagem.

Saída: assets/sprites/<personagem>/{sit,eat}_<direcao>_<0|1>.png
  sit_down  sentado de frente (sofá, cadeiras do fundo)   sit_up    de costas
  sit_left / sit_right  de lado (cabeceiras da mesa)      eat_left / eat_right  comendo, de lado
"""
import re
import sys
from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
SPR = ROOT / "assets" / "sprites"

PERSONAGENS = {
    "jogador": {
        "cintura": 94, "pes": 122,
        "calca": (4, 72, 188), "calca_s": (17, 53, 116), "calca_l": (40, 105, 215),
        "sapato": (59, 28, 7), "sapato_s": (32, 11, 2),
        "camisa": (6, 163, 47), "camisa_s": (4, 120, 36), "pele": (246, 142, 99),
        "contorno": (7, 18, 41), "boca_y": 66,
    },
    "mae": {
        "cintura": 106, "pes": 130,
        "calca": (43, 67, 157), "calca_s": (39, 48, 91), "calca_l": (70, 95, 185),
        "sapato": (69, 37, 25), "sapato_s": (43, 16, 5),
        "camisa": (192, 90, 130), "camisa_s": (150, 64, 100), "pele": (247, 148, 104),
        "contorno": (10, 15, 41), "boca_y": 74,
    },
}


def carregar(nome: str, quadro: str) -> np.ndarray:
    return np.array(Image.open(SPR / nome / f"{quadro}.png").convert("RGBA")).copy()


class Pintor:
    def __init__(self, img: np.ndarray, cfg: dict) -> None:
        self.img = img
        self.cfg = cfg
        self.novo = np.zeros(img.shape[:2], dtype=bool)

    def rect(self, x0, y0, x1, y1, cor) -> None:
        h, w = self.img.shape[:2]
        x0, x1 = max(0, int(x0)), min(w - 1, int(x1))
        y0, y1 = max(0, int(y0)), min(h - 1, int(y1))
        if x1 < x0 or y1 < y0:
            return
        self.img[y0:y1 + 1, x0:x1 + 1] = (*cor, 255)
        self.novo[y0:y1 + 1, x0:x1 + 1] = True

    def linha(self, a, b, espessura, cor) -> None:
        passos = int(max(abs(b[0] - a[0]), abs(b[1] - a[1]))) + 1
        for i in range(passos + 1):
            t = i / max(1, passos)
            x = a[0] + (b[0] - a[0]) * t
            y = a[1] + (b[1] - a[1]) * t
            self.rect(x - espessura // 2, y - espessura // 2, x + espessura // 2, y + espessura // 2, cor)

    def contornar(self) -> None:
        """Contorno de 2 px em volta só do que foi desenhado agora (como o resto do sprite)."""
        alfa = self.img[:, :, 3] > 0
        borda = np.zeros_like(alfa)
        for dy, dx in ((-2, 0), (2, 0), (0, -2), (0, 2), (-1, -1), (1, 1), (-1, 1), (1, -1), (-1, 0), (1, 0), (0, -1), (0, 1)):
            borda |= np.roll(np.roll(self.novo, dy, 0), dx, 1)
        alvo = borda & ~alfa
        self.img[alvo] = (*self.cfg["contorno"], 255)


def topo(img: np.ndarray, ate: int, dy: int) -> np.ndarray:
    """Copia as linhas [0, ate) do sprite deslocadas `dy` para baixo numa tela vazia."""
    nova = np.zeros_like(img)
    nova[dy:ate + dy] = img[:ate]
    return nova


def extensao(img: np.ndarray, y: int) -> tuple:
    xs = np.where(img[y, :, 3] > 0)[0]
    return int(xs.min()), int(xs.max())


def sentado_frente(nome: str, cfg: dict, quadro: str) -> np.ndarray:
    base = carregar(nome, quadro)
    c, pes = cfg["cintura"], cfg["pes"]
    dy = 3
    img = topo(base, c, dy)
    p = Pintor(img, cfg)
    l, r = extensao(base, c - 2)
    l, r = l + 3, r - 3
    colo0 = c + dy
    # colo (coxas vindo para a frente, encurtadas pela perspectiva)
    p.rect(l - 2, colo0, r + 2, colo0 + 9, cfg["calca"])
    p.rect(l - 2, colo0, r + 2, colo0 + 2, cfg["calca_l"])
    meio = (l + r) // 2
    p.rect(meio - 1, colo0 + 5, meio + 1, colo0 + 9, cfg["calca_s"])
    # canelas penduradas e sapatos
    largura = (r - l) // 2 - 4
    for x0 in (l + 1, r - 1 - largura):
        p.rect(x0, colo0 + 10, x0 + largura, pes - 6, cfg["calca_s"])
        p.rect(x0 - 1, pes - 5, x0 + largura + 1, pes, cfg["sapato"])
        p.rect(x0 - 1, pes - 1, x0 + largura + 1, pes, cfg["sapato_s"])
    p.contornar()
    return img


def sentado_lado(nome: str, cfg: dict, quadro: str) -> tuple:
    """Sentado virado para a direita. Devolve a imagem e a frente do tronco (para o braço)."""
    base = carregar(nome, quadro)
    c, pes = cfg["cintura"], cfg["pes"]
    canela, sapato, coxa = 9, 5, 9
    coxa_topo = pes - sapato - canela - coxa
    dy = coxa_topo - c
    img = topo(base, c, dy)
    p = Pintor(img, cfg)
    l, r = extensao(base, c - 2)
    l, r = l + 2, r - 2
    joelho = r + 16
    # quadril e coxa na horizontal, apontando para a frente
    p.rect(l - 3, coxa_topo, joelho, coxa_topo + coxa, cfg["calca"])
    p.rect(l - 3, coxa_topo, joelho, coxa_topo + 2, cfg["calca_l"])
    # canela descendo do joelho e sapato apontando para a frente
    p.rect(joelho - 9, coxa_topo + coxa, joelho, pes - sapato, cfg["calca_s"])
    p.rect(joelho - 9, pes - sapato + 1, joelho + 5, pes, cfg["sapato"])
    p.rect(joelho - 9, pes - 1, joelho + 5, pes, cfg["sapato_s"])
    p.contornar()
    frente = extensao(img, c + dy - 10)[1]
    return img, frente, dy


def comendo(nome: str, cfg: dict, quadro: str, mao_na_boca: bool) -> np.ndarray:
    img, frente, dy = sentado_lado(nome, cfg, quadro)
    p = Pintor(img, cfg)
    ombro = (frente - 8, cfg["cintura"] + dy - 22)
    if mao_na_boca:
        mao = (extensao(img, cfg["boca_y"] + dy)[1] - 3, cfg["boca_y"] + dy)
    else:
        mao = (frente + 10, cfg["cintura"] + dy - 2)
    p.linha(ombro, mao, 5, cfg["camisa"])
    p.linha((ombro[0], ombro[1] + 2), (mao[0], mao[1] + 2), 2, cfg["camisa_s"])
    p.rect(mao[0] - 2, mao[1] - 2, mao[0] + 3, mao[1] + 3, cfg["pele"])
    # garfo
    p.rect(mao[0] + 3, mao[1] - 5, mao[0] + 4, mao[1] + 1, (190, 196, 204))
    p.contornar()
    return img


def de_costas(nome: str, cfg: dict, quadro: str) -> np.ndarray:
    base = carregar(nome, quadro)
    c = cfg["cintura"]
    dy = 3
    img = topo(base, c, dy)
    p = Pintor(img, cfg)
    l, r = extensao(base, c - 2)
    p.rect(l + 2, c + dy, r - 2, c + dy + 8, cfg["calca"])
    p.rect(l + 2, c + dy + 6, r - 2, c + dy + 8, cfg["calca_s"])
    p.contornar()
    return img


def salvar(nome: str, arquivo: str, img: np.ndarray) -> Image.Image:
    im = Image.fromarray(img)
    im.save(SPR / nome / f"{arquivo}.png")
    return im


ANIMACOES = {  # nome: (quadros, velocidade)
    "sit_down": 2, "sit_up": 2, "sit_left": 2, "sit_right": 2, "eat_left": 2, "eat_right": 2,
}


def atualizar_spriteframes(nome: str) -> None:
    caminho = SPR / nome / f"{nome}_frames.tres"
    texto = caminho.read_text(encoding="utf-8")
    # remove animações geradas antes (para rodar o script de novo sem duplicar)
    for anim in ANIMACOES:
        texto = re.sub(r'\{\n"frames": \[[^\]]*\],\n"loop": true,\n"name": &"%s",\n"speed": [\d.]+\n\}, ?' % anim, "", texto)
        texto = re.sub(r', \{\n"frames": \[[^\]]*\],\n"loop": true,\n"name": &"%s",\n"speed": [\d.]+\n\}' % anim, "", texto)
    texto = re.sub(r'\[ext_resource type="Texture2D" path="res://assets/sprites/%s/(sit|eat)_[^"]+" id="\d+"\]\n' % nome, "", texto)
    ids = [int(i) for i in re.findall(r'id="(\d+)"', texto)]
    proximo = max(ids) + 1
    novos_recursos = []
    novas_anim = []
    for anim, quadros in ANIMACOES.items():
        lista = []
        for q in range(quadros):
            novos_recursos.append(f'[ext_resource type="Texture2D" path="res://assets/sprites/{nome}/{anim}_{q}.png" id="{proximo}"]')
            lista.append('{\n"duration": 1.0,\n"texture": ExtResource("%d")\n}' % proximo)
            proximo += 1
        velocidade = 2.5 if anim.startswith("eat") else 1.2
        novas_anim.append('{\n"frames": [%s],\n"loop": true,\n"name": &"%s",\n"speed": %s\n}' % (", ".join(lista), anim, velocidade))
    texto = texto.replace("\n[resource]", "\n".join(novos_recursos) + "\n\n[resource]", 1)
    fim = texto.rstrip().rfind("}]")
    texto = texto[:fim] + "}, " + ", ".join(novas_anim) + "]" + texto[fim + 2:]
    total = len(re.findall(r"\[ext_resource", texto)) + 1
    texto = re.sub(r"load_steps=\d+", f"load_steps={total}", texto, count=1)
    texto = texto.replace("\n\n\n", "\n\n")
    caminho.write_text(texto, encoding="utf-8")


def main() -> None:
    previa = []
    for nome, cfg in PERSONAGENS.items():
        linha = []
        for q, quadro in enumerate(("0", "2")):
            linha.append(salvar(nome, f"sit_down_{q}", sentado_frente(nome, cfg, f"idle_down_{quadro}")))
            direita = sentado_lado(nome, cfg, f"idle_right_{quadro}")[0]
            linha.append(salvar(nome, f"sit_right_{q}", direita))
            salvar(nome, f"sit_left_{q}", direita[:, ::-1].copy())
            linha.append(salvar(nome, f"sit_up_{q}", de_costas(nome, cfg, f"idle_up_{quadro}")))
            comer = comendo(nome, cfg, "idle_right_0", mao_na_boca=(q == 1))
            linha.append(salvar(nome, f"eat_right_{q}", comer))
            salvar(nome, f"eat_left_{q}", comer[:, ::-1].copy())
        atualizar_spriteframes(nome)
        previa.append(linha)
    print("poses geradas e SpriteFrames atualizados")
    if "--preview" in sys.argv:
        destino = Path(sys.argv[sys.argv.index("--preview") + 1])
        largura = max(len(l) for l in previa) * 110
        folha = Image.new("RGBA", (largura, 150 * len(previa)), (200, 200, 200, 255))
        for i, linha in enumerate(previa):
            for j, im in enumerate(linha):
                folha.alpha_composite(im, (j * 110 + 5, i * 150 + 5))
        folha.resize((folha.width * 2, folha.height * 2), Image.NEAREST).save(destino)


if __name__ == "__main__":
    main()
