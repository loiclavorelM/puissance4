"""YouTube thumbnail (1280x720), drawn at 1920x1080 with the video's assets."""
import os
import sys

from PIL import Image, ImageDraw, ImageFilter

import render as R

W, H = R.W, R.H
img = R.draw_background(None, 3.0)
d = ImageDraw.Draw(img)

# Big glow behind the phones.
glow = R.blob(1300, R.RED, 120)
img.paste(glow, (1050, -120), glow)
glow2 = R.blob(1000, R.YELLOW, 60)
img.paste(glow2, (1250, 300), glow2)

# Two tilted phones: the Expert winning, and the assistant's charts.
def tilted(name, height, angle):
    sp, pad = R.phone_sprite(name, height)
    return sp.rotate(angle, resample=Image.BICUBIC, expand=True)

back = tilted('40_dashboard_chart', 820, -8)
front = tilted(sys.argv[1] if len(sys.argv) > 1 else '07_normal_expert_win', 900, 7)
img.alpha_composite(back, (1370, 20))
img.alpha_composite(front, (1010, 40))

# Falling discs around the title.
for x, y, s, c in [(120, 70, 150, R.YELLOW), (300, 40, 110, R.RED), (770, 820, 140, R.YELLOW),
                   (930, 600, 90, R.RED), (60, 860, 120, R.RED)]:
    sp, pad = R.shadowed(R.disc(s, c), blur=18, offset=(0, 12), opacity=160, pad=40)
    img.alpha_composite(sp, (x - pad, y - pad))

# Title block.
f_big = R.font(R.F_TITLE, 232)
f_mid = R.font(R.F_TITLE, 120)
kick = R.text_sprite('I TRAINED ALPHAZERO TO PLAY', R.font(R.F_KICK, 46), R.YELLOW, spacing=5)
img.alpha_composite(kick, (90, 250))
conn = R.text_sprite('CONNECT', f_big, R.WHITE)
four = R.text_sprite('4', f_big, R.RED)
# Thick outline for legibility at small sizes.
def outlined(sp, width=10):
    a = sp.split()[3].filter(ImageFilter.MaxFilter(width * 2 + 1))
    out = Image.new('RGBA', sp.size, (6, 7, 18, 0))
    out.putalpha(a)
    out = Image.alpha_composite(out, sp)
    return out
pad = 14
for sp, x in ((conn, 80), (four, 80 + conn.width + 10)):
    big = Image.new('RGBA', (sp.width + 2 * pad, sp.height + 2 * pad), (0, 0, 0, 0))
    big.alpha_composite(sp, (pad, pad))
    img.alpha_composite(outlined(big), (x - pad, 300 - pad))

# Badge.
badge_text = 'FLUTTER + SERVERPOD'
fb = R.font(R.F_TITLE, 64)
bw = int(fb.getlength(badge_text)) + 70
badge = Image.new('RGBA', (bw, 100), (0, 0, 0, 0))
bd = ImageDraw.Draw(badge)
bd.rounded_rectangle((0, 0, bw - 1, 99), 24, fill=R.GREEN + (255,))
bd.text((35, 12), badge_text, font=fb, fill=(6, 7, 18))
badge = badge.rotate(3, resample=Image.BICUBIC, expand=True)
sp, p = R.shadowed(badge, blur=20, offset=(0, 14), opacity=170, pad=40)
img.alpha_composite(sp, (90 - p, 610 - p))

hack = R.text_sprite('SERVERPOD HACKATHON DEMO', R.font(R.F_KICK, 40), R.MUTED, spacing=5)
img.alpha_composite(hack, (100, 790))

out = img.convert('RGB').resize((1280, 720), Image.LANCZOS)
path = os.path.join(R.OUT, 'thumbnail.png')
out.save(path)
print(path)
