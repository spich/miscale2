"""Crta ikonu aplikacije — vaga odozgo, bijelo na tirkiznom.

Pokretanje: python3 tool/generate_icon.py
Zatim: dart run flutter_launcher_icons
"""

from PIL import Image, ImageDraw

SIZE = 1024
TEAL = (46, 125, 111, 255)
TEAL_DARK = (33, 95, 84, 255)
WHITE = (255, 255, 255, 255)


def rounded_outline(draw, box, radius, width, color):
    draw.rounded_rectangle(box, radius=radius, outline=color, width=width)


def draw_scale(draw, size, color=WHITE):
    """Vaga odozgo: kvadratna ploča s brojčanikom u sredini."""
    unit = size / 1024
    center = size / 2

    # Ploča vage.
    margin = 196 * unit
    rounded_outline(
        draw,
        (margin, margin, size - margin, size - margin),
        radius=round(120 * unit),
        width=round(52 * unit),
        color=color,
    )

    # Zaslon: tri znamenke svedene na točke, da ostanu čitljive i sitne.
    dot_r = 46 * unit
    spacing = 132 * unit
    for offset in (-1, 0, 1):
        cx = center + offset * spacing
        draw.ellipse(
            (cx - dot_r, center - dot_r, cx + dot_r, center + dot_r),
            fill=color,
        )


def gradient_background(size):
    image = Image.new("RGBA", (size, size))
    draw = ImageDraw.Draw(image)
    for y in range(size):
        ratio = y / (size - 1)
        draw.line(
            [(0, y), (size, y)],
            fill=tuple(
                round(a + (b - a) * ratio) for a, b in zip(TEAL, TEAL_DARK)
            ),
        )
    return image


def main():
    # Puna ikona (iOS, stari Android).
    icon = gradient_background(SIZE)
    draw_scale(ImageDraw.Draw(icon), SIZE)
    icon.save("assets/icon/icon.png")

    # Adaptivni slojevi. Android na foreground dodaje inset od 16 % i tek
    # onda reže masku, pa je motiv razmjeran tako da završi na ~60 dp od
    # 108 dp platna — Material keyline za kvadratni oblik.
    for name, color in (
        ("icon_foreground.png", WHITE),
        ("icon_monochrome.png", WHITE),
    ):
        motif = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
        draw_scale(ImageDraw.Draw(motif), SIZE, color)
        motif = motif.crop(motif.getbbox())

        target = round(SIZE * 0.81)
        layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
        scaled = motif.resize((target, target))
        offset = (SIZE - target) // 2
        layer.paste(scaled, (offset, offset), scaled)
        layer.save(f"assets/icon/{name}")

    print("Ikone spremljene u assets/icon/")


if __name__ == "__main__":
    main()
