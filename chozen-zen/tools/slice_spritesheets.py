"""Recorta os spritesheets (JPG, fundo preto) em frames PNG transparentes.

Uso: python tools/slice_spritesheets.py
Entrada: assets/source/{mae,jogador}_spritesheet.jpg
Saída:   assets/sprites/<personagem>/<anim>_<direcao>_<n>.png

Layout esperado da folha: 5 linhas (parado, andando, correndo, pulando, caindo)
e 4 grupos por linha (direita, esquerda, frente, costas).
"""
from pathlib import Path

import numpy as np
from PIL import Image
from scipy import ndimage

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "assets" / "source"
OUT = ROOT / "assets" / "sprites"

ANIMS = ["idle", "walk", "run", "jump", "fall"]
DIRS = ["right", "left", "down", "up"]  # down = frente, up = costas
# Limites x entre os grupos de direção (folha 1536 px de largura)
DIR_SPLITS = [375, 770, 1170]

SHEETS = {"mae": "mae_spritesheet.jpg", "jogador": "jogador_spritesheet.jpg"}


def dir_index(cx: float) -> int:
    for i, split in enumerate(DIR_SPLITS):
        if cx < split:
            return i
    return len(DIR_SPLITS)


def slice_sheet(name: str, filename: str) -> None:
    img = np.asarray(Image.open(SRC / filename).convert("RGB")).astype(np.int16)
    brightness = img.max(axis=2)
    mask = brightness > 28

    # Junta pedaços do mesmo sprite (cabelo/corpo separados por contorno escuro)
    grown = ndimage.binary_dilation(mask, iterations=2)
    labels, _ = ndimage.label(grown)
    boxes = ndimage.find_objects(labels)

    sprites = []
    for i, box in enumerate(boxes):
        ys, xs = box
        h, w = ys.stop - ys.start, xs.stop - xs.start
        if h < 55 or w < 30:  # descarta títulos e legendas
            continue
        sprites.append((ys, xs, i + 1))

    # Agrupa em linhas pela base (pés) do sprite
    sprites.sort(key=lambda s: s[0].stop)
    rows: list[list] = []
    for s in sprites:
        if rows and abs(s[0].stop - rows[-1][-1][0].stop) < 60:
            rows[-1].append(s)
        else:
            rows.append([s])

    if len(rows) != len(ANIMS):
        print(f"[{name}] aviso: {len(rows)} linhas detectadas (esperado {len(ANIMS)})")

    frames: dict[tuple[str, str], list[Image.Image]] = {}
    for anim, row in zip(ANIMS, rows):
        row.sort(key=lambda s: s[1].start)
        for ys, xs, label in row:
            cx = (xs.start + xs.stop) / 2
            direction = DIRS[dir_index(cx)]
            region = img[ys, xs].astype(np.uint8)
            alpha = ((labels[ys, xs] == label) & mask[ys, xs]).astype(np.uint8) * 255
            alpha = ndimage.binary_closing(alpha > 0, iterations=1).astype(np.uint8) * 255
            rgba = np.dstack([region, alpha])
            frames.setdefault((anim, direction), []).append(Image.fromarray(rgba, "RGBA"))

    # Canvas único por personagem, pés alinhados na base e centralizados
    all_frames = [f for fl in frames.values() for f in fl]
    cw = max(f.width for f in all_frames) + 4
    ch = max(f.height for f in all_frames) + 4

    out_dir = OUT / name
    out_dir.mkdir(parents=True, exist_ok=True)
    for old in out_dir.glob("*.png"):
        old.unlink()
    for (anim, direction), fl in sorted(frames.items()):
        for n, frame in enumerate(fl):
            canvas = Image.new("RGBA", (cw, ch), (0, 0, 0, 0))
            canvas.paste(frame, ((cw - frame.width) // 2, ch - frame.height - 2))
            canvas.save(out_dir / f"{anim}_{direction}_{n}.png")
        print(f"[{name}] {anim}_{direction}: {len(fl)} frames")
    print(f"[{name}] canvas {cw}x{ch}")


if __name__ == "__main__":
    for character, file in SHEETS.items():
        slice_sheet(character, file)
