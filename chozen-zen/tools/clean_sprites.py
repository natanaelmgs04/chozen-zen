"""Limpa os frames recortados dos spritesheets (que vieram de JPG).

Uso: python tools/clean_sprites.py   (rodar depois de tools/slice_spritesheets.py)

Cada personagem ganha uma paleta própria e limitada (cores compartilhadas entre
todos os frames, sem dithering) e bordas sem semitransparência. Remove o ruído de
compressão e o aspecto borrado típico de pixel art gerada por IA, sem mover
nenhum pixel de lugar (os frames continuam alinhados entre si).
"""
from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
SPRITES = ROOT / "assets" / "sprites"
COLORS_PER_CHARACTER = 32
ALPHA_CUTOFF = 128


def clean_character(folder: Path) -> None:
    frames = {p: np.asarray(Image.open(p).convert("RGBA")) for p in sorted(folder.glob("*.png"))}
    opaque = np.concatenate([f[f[..., 3] >= ALPHA_CUTOFF][:, :3] for f in frames.values()])
    sample = Image.fromarray(opaque.reshape(-1, 1, 3))
    palette = sample.quantize(colors=COLORS_PER_CHARACTER, method=Image.Quantize.MEDIANCUT, kmeans=8)

    for path, rgba in frames.items():
        rgb = Image.fromarray(np.ascontiguousarray(rgba[..., :3]))
        mapped = np.asarray(rgb.quantize(palette=palette, dither=Image.Dither.NONE).convert("RGB"))
        alpha = np.where(rgba[..., 3] >= ALPHA_CUTOFF, 255, 0).astype(np.uint8)
        Image.fromarray(np.dstack([mapped, alpha]), "RGBA").save(path)
    print(f"[{folder.name}] {len(frames)} frames, paleta de {COLORS_PER_CHARACTER} cores")


if __name__ == "__main__":
    for character in sorted(p for p in SPRITES.iterdir() if p.is_dir()):
        clean_character(character)
