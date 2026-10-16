"""Gera a capa do itch.io e copia logos/ícone para o press kit.

Uso: python tools/make_store_art.py   (rodar depois de prepare_map.py e prepare_logos.py)
Saída: ../presskit/capa_itch_630x500.png, ../presskit/banner_1920x480.png, ../presskit/logos/*
"""
import shutil
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
PRESSKIT = ROOT.parent / "presskit"
CREAM = (251, 245, 236)


def house_background(size: tuple[int, int]) -> Image.Image:
    interior = Image.open(ROOT / "assets/maps/fase1_casa.png").convert("RGB").crop((137, 0, 1390, 887))
    scale = max(size[0] / interior.width, size[1] / interior.height)
    big = interior.resize((round(interior.width * scale), round(interior.height * scale)), Image.NEAREST)
    left = (big.width - size[0]) // 2
    return big.crop((left, 0, left + size[0], size[1]))


def paper_gradient(size: tuple[int, int], solid_until: float, fade_until: float) -> Image.Image:
    grad = Image.new("RGBA", size, CREAM + (0,))
    px = grad.load()
    for x in range(size[0]):
        t = x / size[0]
        a = 245 if t < solid_until else max(0, int(245 * (1 - (t - solid_until) / (fade_until - solid_until))))
        for y in range(size[1]):
            px[x, y] = CREAM + (a,)
    return grad


def characters(scale: int) -> tuple[Image.Image, Image.Image]:
    mae = Image.open(ROOT / "assets/sprites/mae/idle_right_0.png")
    filho = Image.open(ROOT / "assets/sprites/jogador/idle_left_0.png")
    return (mae.resize((mae.width * scale, mae.height * scale), Image.NEAREST),
            filho.resize((filho.width * scale, filho.height * scale), Image.NEAREST))


def compose(size: tuple[int, int], logo_width: int, logo_pos: tuple[int, int], char_scale: int,
            char_x: int, solid: float, fade: float) -> Image.Image:
    canvas = house_background(size).convert("RGBA")
    canvas.alpha_composite(paper_gradient(size, solid, fade))
    mae, filho = characters(char_scale)
    feet_y = size[1] - 8
    canvas.alpha_composite(mae, (char_x, feet_y - mae.height))
    canvas.alpha_composite(filho, (char_x + mae.width - 12 * char_scale, feet_y - filho.height))
    logo = Image.open(ROOT / "assets/ui/logo_chosenzen.png")
    logo = logo.resize((logo_width, round(logo.height * logo_width / logo.width)), Image.LANCZOS)
    canvas.alpha_composite(logo, logo_pos)
    return canvas.convert("RGB")


def main() -> None:
    (PRESSKIT / "logos").mkdir(parents=True, exist_ok=True)
    compose((630, 500), 340, (14, 90), 2, 318, 0.40, 0.70).save(PRESSKIT / "capa_itch_630x500.png")
    compose((1920, 480), 520, (90, 50), 3, 1300, 0.30, 0.60).save(PRESSKIT / "banner_1920x480.png")
    shutil.copy(ROOT / "assets/ui/logo_chosenzen.png", PRESSKIT / "logos/logo_chosenzen_transparente.png")
    shutil.copy(ROOT / "assets/ui/logo_vivido.png", PRESSKIT / "logos/logo_estudio_vivido_transparente.png")
    shutil.copy(ROOT / "assets/ui/icon.png", PRESSKIT / "logos/icone_256.png")
    print("capa, banner e logos gerados em", PRESSKIT)


if __name__ == "__main__":
    main()
