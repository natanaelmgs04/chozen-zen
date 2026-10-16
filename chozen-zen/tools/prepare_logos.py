"""Gera os logos com fundo transparente, recortados e no tamanho de exibição.

Uso: python tools/prepare_logos.py
Entrada: assets/source/logo_chosenzen.png, assets/source/logo_estudio_vivido.png
Saída:   assets/ui/logo_chosenzen.png, assets/ui/logo_vivido.png
"""
from pathlib import Path

import numpy as np
from PIL import Image
from scipy import ndimage

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "assets" / "source"
OUT = ROOT / "assets" / "ui"

CREAM = (251, 245, 236)

# (arquivo, recorte opcional (x0, y0, x1, y1) na imagem original, largura final)
LOGOS = {
    "logo_chosenzen.png": ("logo_chosenzen.png", None, 520),
    # A arte do estúdio tem um pedaço do logo do jogo na borda direita; corta antes.
    "logo_vivido.png": ("logo_estudio_vivido.png", (60, 140, 680, 840), 420),
}


def remove_white(rgb: np.ndarray) -> np.ndarray:
    darkness = 255 - rgb.min(axis=2).astype(np.int16)
    labels, _ = ndimage.label(darkness < 18)
    border = np.unique(np.concatenate([labels[0], labels[-1], labels[:, 0], labels[:, -1]]))
    outside = np.isin(labels, border[border != 0])
    # Borda suave: perto do fundo, a opacidade acompanha o quão escuro é o pixel.
    ring = ndimage.binary_dilation(outside, iterations=3) & ~outside
    alpha = np.full(darkness.shape, 255, np.uint8)
    alpha[outside] = 0
    alpha[ring] = np.clip(darkness[ring] * 4, 0, 255).astype(np.uint8)
    return alpha


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    for out_name, (src_name, crop, width) in LOGOS.items():
        img = Image.open(SRC / src_name).convert("RGB")
        if crop:
            img = img.crop(crop)
        rgb = np.asarray(img).copy()
        alpha = remove_white(rgb)
        # Brancos internos (miolo das letras) viram o creme da interface.
        rgb[rgb.min(axis=2) > 245] = CREAM
        rgba = Image.fromarray(np.dstack([rgb, alpha]), "RGBA")
        rgba = rgba.crop(rgba.getbbox())
        height = round(rgba.height * width / rgba.width)
        rgba.resize((width, height), Image.LANCZOS).save(OUT / out_name)
        print(f"{out_name}: {width}x{height}")
    make_icon()


def make_icon() -> None:
    """Ícone 256x256: o emblema (sol, montanhas e rio) sobre um círculo creme."""
    crop = np.asarray(Image.open(SRC / "logo_chosenzen.png").convert("RGB").crop((230, 190, 610, 470)))
    emblem = Image.fromarray(np.dstack([crop, remove_white(crop)]), "RGBA")
    size = 256
    icon = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    mask = Image.new("L", (size, size), 0)
    from PIL import ImageDraw
    ImageDraw.Draw(mask).ellipse((0, 0, size - 1, size - 1), fill=255)
    disc = Image.new("RGBA", (size, size), (251, 245, 236, 255))
    emblem = emblem.resize((216, round(216 * emblem.height / emblem.width)), Image.LANCZOS)
    disc.alpha_composite(emblem, ((size - emblem.width) // 2, (size - emblem.height) // 2))
    icon.paste(disc, (0, 0), mask)
    icon.save(OUT / "icon.png")
    print("icon.png: 256x256")


if __name__ == "__main__":
    main()
