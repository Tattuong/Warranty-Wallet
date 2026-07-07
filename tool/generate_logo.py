"""Generate Warranty Wallet logos — modern wallet + shield mark, 1024x1024 square."""
from __future__ import annotations

import math
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter

SIZE = 1024
OUT = Path(__file__).resolve().parents[1] / "assets" / "logo.png"
OUT_ICON = Path(__file__).resolve().parents[1] / "assets" / "logo_icon.png"

NAVY = (15, 23, 42)
BLUE = (37, 99, 235)
SKY = (56, 189, 248)
WHITE = (255, 255, 255)
GOLD = (250, 204, 21)
MINT = (16, 185, 129)


def lerp(a: float, b: float, t: float) -> float:
    return a + (b - a) * t


def lerp_color(c1, c2, t):
    return tuple(int(lerp(c1[i], c2[i], t)) for i in range(3))


def radial_bg(size: int) -> Image.Image:
    img = Image.new("RGB", (size, size))
    px = img.load()
    cx = cy = size / 2
    max_r = math.hypot(cx, cy)
    for y in range(size):
        for x in range(size):
            t = math.hypot(x - cx, y - cy) / max_r
            t = min(1.0, t * 1.15)
            inner = lerp_color(BLUE, SKY, t * 0.55)
            outer = lerp_color(NAVY, BLUE, t)
            mix = lerp_color(inner, outer, t)
            px[x, y] = mix
    return img


def draw_soft_glow(base: Image.Image) -> Image.Image:
    glow = Image.new("RGBA", base.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(glow)
    cx, cy = SIZE // 2, SIZE // 2
    draw.ellipse((cx - 360, cy - 360, cx + 360, cy + 360), fill=(255, 255, 255, 28))
    glow = glow.filter(ImageFilter.GaussianBlur(40))
    return Image.alpha_composite(base.convert("RGBA"), glow)


def rounded_wallet(draw: ImageDraw.ImageDraw, cx: int, cy: int, scale: float, fill, outline=None):
    s = scale
    w, h = int(250 * s), int(190 * s)
    x0, y0 = cx - w // 2, cy - h // 2 + int(20 * s)
    x1, y1 = x0 + w, y0 + h
    r = int(42 * s)
    draw.rounded_rectangle((x0, y0, x1, y1), radius=r, fill=fill, outline=outline, width=max(2, int(4 * s)))
    flap_h = int(58 * s)
    draw.rounded_rectangle((x0 + int(18 * s), y0 - int(8 * s), x1 - int(18 * s), y0 + flap_h), radius=int(24 * s), fill=fill, outline=outline, width=max(2, int(4 * s)))
    clasp_w, clasp_h = int(72 * s), int(48 * s)
    cx0 = x1 - int(48 * s) - clasp_w
    cy0 = cy - clasp_h // 2 + int(8 * s)
    draw.rounded_rectangle((cx0, cy0, cx0 + clasp_w, cy0 + clasp_h), radius=int(16 * s), fill=GOLD)
    draw.ellipse((cx0 + clasp_w // 2 - int(10 * s), cy0 + clasp_h // 2 - int(10 * s), cx0 + clasp_w // 2 + int(10 * s), cy0 + clasp_h // 2 + int(10 * s)), fill=NAVY)


def draw_shield_check(draw: ImageDraw.ImageDraw, cx: int, cy: int, scale: float):
    s = scale
    top = cy - int(95 * s)
    bottom = cy + int(95 * s)
    left = cx - int(78 * s)
    right = cx + int(78 * s)
    mid = cy + int(8 * s)
    draw.polygon([(cx, top), (right, top + int(42 * s)), (right, mid), (cx, bottom), (left, mid), (left, top + int(42 * s))], fill=MINT)
    t = max(int(10 * s), 8)
    draw.line([(cx - int(28 * s), cy + int(2 * s)), (cx - int(8 * s), cy + int(24 * s)), (cx + int(34 * s), cy - int(20 * s))], fill=WHITE, width=t, joint="curve")


def draw_receipt_lines(draw: ImageDraw.ImageDraw, cx: int, cy: int, scale: float):
    s = scale
    x0 = cx - int(58 * s)
    for i, w in enumerate([0.75, 0.55, 0.65, 0.45]):
        y = cy - int(20 * s) + i * int(18 * s)
        draw.rounded_rectangle((x0, y, x0 + int(116 * w * s), y + int(8 * s)), radius=int(4 * s), fill=(226, 232, 240))


def compose(on_bg: bool) -> Image.Image:
    if on_bg:
        img = draw_soft_glow(radial_bg(SIZE))
    else:
        img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))

    draw = ImageDraw.Draw(img)
    cx, cy = SIZE // 2, SIZE // 2 + 10

    rounded_wallet(draw, cx, cy, 1.35, fill=WHITE, outline=(191, 219, 254))
    draw_receipt_lines(draw, cx - 8, cy - 10, 1.0)
    draw_shield_check(draw, cx + 92, cy - 72, 0.95)

    return img


def main() -> None:
    OUT.parent.mkdir(parents=True, exist_ok=True)
    store = compose(on_bg=True).convert("RGB")
    store = store.filter(ImageFilter.UnsharpMask(radius=1.0, percent=60, threshold=2))
    store.save(OUT, format="PNG", optimize=True)
    print(f"Saved store logo: {OUT}")

    icon = compose(on_bg=False)
    icon.save(OUT_ICON, format="PNG", optimize=True)
    print(f"Saved transparent icon: {OUT_ICON}")


if __name__ == "__main__":
    main()
