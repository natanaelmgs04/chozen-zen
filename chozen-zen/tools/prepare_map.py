"""Converte a arte do mapa (JPG, fundo branco) em PNG com o exterior transparente.

Uso: python tools/prepare_map.py
Entrada: assets/source/fase1_casa_mapa.jpg
Saída:   assets/maps/fase1_casa.png

Só remove o branco conectado às bordas da imagem (flood fill), para não apagar
brancos internos como a luz do abajur ou o piso da cozinha.
"""
from pathlib import Path

import numpy as np
from PIL import Image
from scipy import ndimage

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "assets" / "source" / "fase1_casa_mapa.jpg"
OUT = ROOT / "assets" / "maps" / "fase1_casa.png"

WHITE_THRESHOLD = 225


def main() -> None:
    rgb = np.asarray(Image.open(SRC).convert("RGB"))
    near_white = (rgb >= WHITE_THRESHOLD).all(axis=2)

    labels, _ = ndimage.label(near_white)
    border_labels = np.unique(np.concatenate([
        labels[0, :], labels[-1, :], labels[:, 0], labels[:, -1]
    ]))
    border_labels = border_labels[border_labels != 0]
    outside = np.isin(labels, border_labels)
    # Absorve o halo de compressão JPG em volta da casa
    outside = ndimage.binary_dilation(outside, iterations=1) & (rgb.min(axis=2) > 170)
    outside |= np.isin(labels, border_labels)

    alpha = np.where(outside, 0, 255).astype(np.uint8)
    OUT.parent.mkdir(parents=True, exist_ok=True)
    Image.fromarray(np.dstack([rgb, alpha]), "RGBA").save(OUT)
    print(f"{OUT.relative_to(ROOT)}: {rgb.shape[1]}x{rgb.shape[0]}, {outside.mean():.1%} transparente")


if __name__ == "__main__":
    main()
