"""Render the ForestOS app icon and launch mark for every platform.

A sunlit fern leaf on deep forest with a warm low-sun glow and a gold glint,
matching the in-app brand medallion and palette (lib/theme/forest_theme.dart).

Usage (from the project root):
    python3 design/tools/make_icons.py
"""

import json
import math
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageFilter

ROOT = Path(__file__).resolve().parents[2]
SS = 2048  # supersampled canvas; everything is downscaled from here

DEEP_FOREST = (11, 29, 21)
CANOPY = (31, 61, 44)
MORNING_GOLD = (233, 194, 125)
FERN_LIGHT = (224, 245, 176)
FERN = (163, 197, 133)
FERN_DARK = (134, 172, 105)


def lerp(a, b, t):
    return tuple(round(x + (y - x) * t) for x, y in zip(a, b))


def linear_gradient(size, start, end, angle_deg=135):
    """Diagonal gradient across a square of `size` (rendered small, upscaled
    smoothly — a gradient has no detail to lose)."""
    w = 256
    grad = Image.new("RGB", (w, w))
    px = grad.load()
    a = math.radians(angle_deg)
    dx, dy = math.cos(a), math.sin(a)
    for y in range(w):
        for x in range(w):
            t = ((x / w - 0.5) * dx + (y / w - 0.5) * dy) / math.sqrt(0.5) + 0.5
            px[x, y] = lerp(start, end, min(max(t, 0), 1))
    return grad.resize((size, size), Image.BICUBIC)


def radial_glow(size, center, radius, color, strength):
    """Additive radial glow layer (RGB) to screen over a background."""
    glow = Image.new("L", (size, size), 0)
    d = ImageDraw.Draw(glow)
    cx, cy = center
    d.ellipse((cx - radius, cy - radius, cx + radius, cy + radius), fill=255)
    glow = glow.filter(ImageFilter.GaussianBlur(radius * 0.45))
    glow = glow.point(lambda v: int(v * strength))
    layer = Image.new("RGB", (size, size), color)
    black = Image.new("RGB", (size, size), (0, 0, 0))
    return Image.composite(layer, black, glow)


def leaf_mask(size, scale=1.0):
    """Vesica leaf (intersection of two circles), tilted 45 degrees."""
    s = size
    m = Image.new("L", (s, s), 0)
    r = s * 0.42 * scale
    offset = r * 0.62
    c = s / 2
    a = Image.new("L", (s, s), 0)
    b = Image.new("L", (s, s), 0)
    ImageDraw.Draw(a).ellipse((c - offset - r, c - r, c - offset + r, c + r), fill=255)
    ImageDraw.Draw(b).ellipse((c + offset - r, c - r, c + offset + r, c + r), fill=255)
    m = ImageChops.multiply(a, b)
    # Negative = clockwise: tips land bottom-left and top-right.
    return m.rotate(-45, resample=Image.BICUBIC, center=(c, c))


def leaf_layer(size, scale=1.0):
    """RGBA fern leaf with gradient fill, midrib and veins."""
    s = size
    mask = leaf_mask(s, scale)
    fill = linear_gradient(s, FERN_LIGHT, FERN_DARK, angle_deg=45)
    leaf = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    leaf.paste(fill, (0, 0), mask)

    # Midrib and veins in deep forest, clipped to the leaf. The leaf's axis
    # runs from bottom-left to top-right after the 45 degree tilt.
    veins = Image.new("L", (s, s), 0)
    d = ImageDraw.Draw(veins)
    c = s / 2
    half = s * 0.42 * scale * 0.62
    axis = (1 / math.sqrt(2), -1 / math.sqrt(2))
    w = max(2, int(s * 0.012 * scale))
    d.line((c - axis[0] * half, c - axis[1] * half,
            c + axis[0] * half * 0.92, c + axis[1] * half * 0.92), fill=255, width=w)
    for t in (-0.45, -0.05, 0.35):  # positions along the midrib
        ox, oy = c + axis[0] * half * t, c + axis[1] * half * t
        length = half * 0.5 * (1 - abs(t) * 0.5)
        for turn in (50, -50):  # veins sweep toward the tip on both sides
            r = math.radians(turn)
            vx = axis[0] * math.cos(r) - axis[1] * math.sin(r)
            vy = axis[0] * math.sin(r) + axis[1] * math.cos(r)
            d.line((ox, oy, ox + vx * length, oy + vy * length),
                   fill=255, width=max(1, int(w * 0.6)))
    veins = ImageChops.multiply(veins, mask.filter(ImageFilter.MinFilter(9)))
    rib = Image.new("RGBA", (s, s), DEEP_FOREST + (0,))
    rib.putalpha(veins.point(lambda v: int(v * 0.55)))
    leaf = Image.alpha_composite(leaf, rib)

    # A short stem curling out of the bottom-left tip.
    stem = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    tip = (c - axis[0] * half * 1.02, c - axis[1] * half * 1.02)
    ImageDraw.Draw(stem).line(
        (tip[0], tip[1], tip[0] - s * 0.06 * scale, tip[1] + s * 0.07 * scale),
        fill=FERN_DARK + (255,), width=int(w * 1.3))
    return Image.alpha_composite(stem, leaf), mask


def sparkle(size, center, radius):
    """Four-point gold glint (RGBA)."""
    s = size
    layer = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    cx, cy = center
    r, n = radius, radius * 0.18
    d.polygon(
        [(cx, cy - r), (cx + n, cy - n), (cx + r, cy), (cx + n, cy + n),
         (cx, cy + r), (cx - n, cy + n), (cx - r, cy), (cx - n, cy - n)],
        fill=MORNING_GOLD + (255,),
    )
    halo = layer.filter(ImageFilter.GaussianBlur(radius * 0.5))
    return Image.alpha_composite(halo, layer)


def render_icon(full_bleed=True):
    """1024px icon. full_bleed=False adds a squircle mask (Android legacy)."""
    s = SS
    bg = linear_gradient(s, CANOPY, DEEP_FOREST, angle_deg=120)
    bg = ImageChops.add(bg, radial_glow(s, (s * 0.84, s * 0.14), s * 0.4, MORNING_GOLD, 0.42))
    bg = ImageChops.add(bg, radial_glow(s, (s * 0.2, s * 0.95), s * 0.4, FERN_DARK, 0.25))
    icon = bg.convert("RGBA")

    leaf, mask = leaf_layer(s, scale=1.0)
    shadow = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    shadow.putalpha(mask.filter(ImageFilter.GaussianBlur(s * 0.03)).point(lambda v: int(v * 0.55)))
    icon = Image.alpha_composite(icon, ImageChops.offset(shadow, 0, int(s * 0.02)))
    glow = Image.new("RGBA", (s, s), FERN + (0,))
    glow.putalpha(mask.filter(ImageFilter.GaussianBlur(s * 0.05)).point(lambda v: int(v * 0.35)))
    icon = Image.alpha_composite(icon, glow)
    icon = Image.alpha_composite(icon, leaf)
    icon = Image.alpha_composite(icon, sparkle(s, (s * 0.78, s * 0.22), s * 0.065))

    icon = icon.resize((1024, 1024), Image.LANCZOS)
    if full_bleed:
        return icon.convert("RGB")  # iOS forbids alpha
    rounded = Image.new("L", (1024 * 4, 1024 * 4), 0)
    ImageDraw.Draw(rounded).rounded_rectangle((0, 0, 4095, 4095), radius=4096 * 0.22, fill=255)
    icon.putalpha(rounded.resize((1024, 1024), Image.LANCZOS))
    return icon


def render_mark(px):
    """Transparent leaf + glint for launch screens."""
    s = SS
    leaf, _ = leaf_layer(s, scale=1.0)
    mark = Image.alpha_composite(leaf, sparkle(s, (s * 0.82, s * 0.18), s * 0.07))
    return mark.resize((px, px), Image.LANCZOS)


def main():
    ios_icon = render_icon(full_bleed=True)
    android_icon = render_icon(full_bleed=False)

    # iOS app icons: every size listed in the asset catalog.
    iconset = ROOT / "ios/Runner/Assets.xcassets/AppIcon.appiconset"
    contents = json.loads((iconset / "Contents.json").read_text())
    for image in contents["images"]:
        points = float(image["size"].split("x")[0])
        scale = int(image["scale"].rstrip("x"))
        px = round(points * scale)
        ios_icon.resize((px, px), Image.LANCZOS).save(iconset / image["filename"])

    # Android legacy launcher icons.
    for folder, px in {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}.items():
        android_icon.resize((px, px), Image.LANCZOS).save(
            ROOT / f"android/app/src/main/res/mipmap-{folder}/ic_launcher.png")

    # Web icons + favicon.
    web = ROOT / "web"
    for name, px in {"Icon-192.png": 192, "Icon-512.png": 512}.items():
        android_icon.resize((px, px), Image.LANCZOS).save(web / "icons" / name)
    for name, px in {"Icon-maskable-192.png": 192, "Icon-maskable-512.png": 512}.items():
        ios_icon.resize((px, px), Image.LANCZOS).save(web / "icons" / name)
    android_icon.resize((32, 32), Image.LANCZOS).save(web / "favicon.png")

    # Launch marks: iOS 1x/2x/3x at 96pt, Android at xxxhdpi (96dp * 4).
    launch = ROOT / "ios/Runner/Assets.xcassets/LaunchImage.imageset"
    for suffix, scale in {"": 1, "@2x": 2, "@3x": 3}.items():
        render_mark(96 * scale).save(launch / f"LaunchImage{suffix}.png")
    nodpi = ROOT / "android/app/src/main/res/drawable-nodpi"
    nodpi.mkdir(exist_ok=True)
    render_mark(384).save(nodpi / "launch_mark.png")

    ios_icon.save(ROOT / "design/app_icon_1024.png")
    print("Icons and launch marks written.")


if __name__ == "__main__":
    main()
