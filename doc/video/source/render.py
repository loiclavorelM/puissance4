"""Connect Four demo video: frames drawn with Pillow, piped to ffmpeg.

python render.py [--preview SECONDS ...]   # still frames for a quick look
python render.py                           # full video -> out/connect4_demo.mp4
"""
import json
import math
import os
import random
import subprocess
import sys
import wave

import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
SHOTS = '/home/loicl/Documents/Master/A02-MA-AdvMob/project/doc/video'
FONTS = os.path.join(HERE, '..', 'fonts')
OUT = os.path.join(HERE, 'out')
VO_DIR = os.environ.get('VO_DIR', HERE)
os.makedirs(OUT, exist_ok=True)

W, H, FPS = 1920, 1080, 30

# Palette: the app's own colours on a game-trailer navy/purple ground.
NAVY = (11, 13, 34)
PURPLE = (42, 27, 92)
RED = (224, 73, 60)
YELLOW = (255, 214, 10)
GREEN = (52, 211, 153)
WHITE = (240, 242, 255)
MUTED = (160, 166, 210)
FRAME = (6, 7, 18)


def font(name, size):
    return ImageFont.truetype(os.path.join(FONTS, name + '.ttf'), size)


F_TITLE = 'BarlowCondensed-ExtraBoldItalic'
F_KICK = 'Barlow-SemiBold'
F_CAP = 'Barlow-Medium'
F_CHIP = 'Barlow-SemiBold'


# ----------------------------------------------------------------- easing
def clamp(x, a=0.0, b=1.0):
    return max(a, min(b, x))


def ease_out_cubic(t):
    t = clamp(t)
    return 1 - (1 - t) ** 3


def ease_in_out(t):
    t = clamp(t)
    return 4 * t * t * t if t < 0.5 else 1 - (-2 * t + 2) ** 3 / 2


def ease_out_back(t, s=1.7):
    t = clamp(t)
    return 1 + (s + 1) * (t - 1) ** 3 + s * (t - 1) ** 2


def ease_in(t):
    t = clamp(t)
    return t * t


def bounce(t):
    """Disc landing: fall, then two small bounces."""
    t = clamp(t)
    n1, d1 = 7.5625, 2.75
    if t < 1 / d1:
        return n1 * t * t
    if t < 2 / d1:
        t -= 1.5 / d1
        return n1 * t * t + 0.75
    if t < 2.5 / d1:
        t -= 2.25 / d1
        return n1 * t * t + 0.9375
    t -= 2.625 / d1
    return n1 * t * t + 0.984375


# ---------------------------------------------------------------- sprites
def rounded_mask(size, radius):
    m = Image.new('L', size, 0)
    ImageDraw.Draw(m).rounded_rectangle((0, 0, size[0] - 1, size[1] - 1), radius, fill=255)
    return m


def shadowed(sprite, blur=28, offset=(0, 22), opacity=170, glow=None, pad=70):
    """Sprite with a soft drop shadow (and an optional coloured glow)."""
    w, h = sprite.size
    out = Image.new('RGBA', (w + 2 * pad, h + 2 * pad), (0, 0, 0, 0))
    alpha = sprite.split()[3]
    if glow:
        g = Image.new('RGBA', out.size, glow + (0,))
        ga = Image.new('L', out.size, 0)
        ga.paste(alpha.point(lambda a: a * 90 // 255), (pad, pad))
        g.putalpha(ga.filter(ImageFilter.GaussianBlur(40)))
        out = Image.alpha_composite(out, g)
    sh = Image.new('L', out.size, 0)
    sh.paste(alpha.point(lambda a: a * opacity // 255), (pad + offset[0], pad + offset[1]))
    shadow = Image.new('RGBA', out.size, (0, 0, 0, 0))
    shadow.putalpha(sh.filter(ImageFilter.GaussianBlur(blur)))
    out = Image.alpha_composite(out, shadow)
    out.alpha_composite(sprite, (pad, pad))
    return out, pad


_shot_cache = {}


def shot(name):
    if name not in _shot_cache:
        _shot_cache[name] = Image.open(os.path.join(SHOTS, name + '.png')).convert('RGB')
    return _shot_cache[name]


def phone_sprite(name, height=790):
    """A screenshot in a dark phone bezel, with shadow. Returns (img, pad)."""
    img = shot(name)
    sw = round(img.width * height / img.height)
    screen = img.resize((sw, height), Image.LANCZOS).convert('RGBA')
    bez = 12
    pw, ph = sw + 2 * bez, height + 2 * bez
    body = Image.new('RGBA', (pw, ph), (0, 0, 0, 0))
    ImageDraw.Draw(body).rounded_rectangle((0, 0, pw - 1, ph - 1), 54, fill=FRAME + (255,))
    # Thin highlight on the bezel edge.
    ImageDraw.Draw(body).rounded_rectangle((1, 1, pw - 2, ph - 2), 53, outline=(70, 74, 120, 255), width=2)
    body.paste(screen, (bez, bez), rounded_mask(screen.size, 42))
    return shadowed(body)


class ClipPhone:
    """A phone whose screen plays a screen recording (frames in clip/)."""

    def __init__(self, folder, height=790):
        self.frames = sorted(os.path.join(folder, f) for f in os.listdir(folder))
        first = Image.open(self.frames[0])
        sw, sh = first.size
        bez = 12
        pw, ph = sw + 2 * bez, sh + 2 * bez
        body = Image.new('RGBA', (pw, ph), (0, 0, 0, 0))
        d = ImageDraw.Draw(body)
        d.rounded_rectangle((0, 0, pw - 1, ph - 1), 54, fill=FRAME + (255,))
        d.rounded_rectangle((1, 1, pw - 2, ph - 2), 53, outline=(70, 74, 120, 255), width=2)
        self.template, self.pad = shadowed(body)
        self.mask = rounded_mask((sw, sh), 42)
        self.offset = (self.pad + bez, self.pad + bez)
        self.width, self.height = self.template.size
        self._cache = (None, None)

    def at(self, seconds):
        i = int(clamp(seconds * FPS, 0, len(self.frames) - 1))
        if self._cache[0] != i:
            img = self.template.copy()
            img.paste(Image.open(self.frames[i]).convert('RGB'), self.offset, self.mask)
            self._cache = (i, img)
        return self._cache[1], self.pad


def callout_sprite(name, box, width, accent=YELLOW):
    """A magnified crop of a screenshot: rounded card with an accent border."""
    img = shot(name).crop(box)
    h = round(img.height * width / img.width)
    img = img.resize((width, h), Image.LANCZOS).convert('RGBA')
    b = 6
    card = Image.new('RGBA', (width + 2 * b, h + 2 * b), (0, 0, 0, 0))
    ImageDraw.Draw(card).rounded_rectangle((0, 0, card.width - 1, card.height - 1), 30, fill=accent + (255,))
    card.paste(img, (b, b), rounded_mask(img.size, 25))
    return shadowed(card, blur=30, offset=(0, 18), opacity=200, glow=accent)


def text_sprite(text, fnt, fill, spacing=0):
    """Text on a transparent layer, with optional letter spacing."""
    bbox = fnt.getbbox(text)
    if spacing:
        widths = [fnt.getlength(c) + spacing for c in text]
        w = int(sum(widths)) + 4
    else:
        w = bbox[2] + 8
    hgt = fnt.getbbox('ÀgjpqyÉ')[3] + 6
    im = Image.new('RGBA', (w, hgt), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    if spacing:
        x = 0
        for c in text:
            d.text((x, 0), c, font=fnt, fill=fill)
            x += fnt.getlength(c) + spacing
    else:
        d.text((0, 0), text, font=fnt, fill=fill)
    return im


def chip_sprite(text, color):
    f = font(F_CHIP, 26)
    tw = f.getlength(text)
    w, h = int(tw) + 44, 50
    im = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    d.rounded_rectangle((0, 0, w - 1, h - 1), 25, fill=(255, 255, 255, 18), outline=color + (200,), width=2)
    d.ellipse((16, 20, 26, 30), fill=color + (255,))
    d.text((34, 9), text, font=f, fill=WHITE)
    return im


def caption_sprite(text):
    f = font(F_CAP, 38)
    tw = f.getlength(text)
    w, h = int(tw) + 64, 68
    im = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    d.rounded_rectangle((0, 0, w - 1, h - 1), 34, fill=(6, 7, 20, 200))
    d.text((32, 12), text, font=f, fill=WHITE)
    return im


def disc(d, color, ring=True):
    im = Image.new('RGBA', (d, d), (0, 0, 0, 0))
    dr = ImageDraw.Draw(im)
    dr.ellipse((0, 0, d - 1, d - 1), fill=color + (255,))
    if ring:
        k = d // 7
        dark = tuple(int(c * 0.82) for c in color)
        dr.ellipse((k, k, d - 1 - k, d - 1 - k), outline=dark + (255,), width=max(2, d // 30))
    return im


# ------------------------------------------------------------- background
def make_background():
    y, x = np.mgrid[0:H, 0:W].astype(np.float32)
    t = (x / W * 0.55 + y / H * 0.45)
    a, b = np.array(NAVY, np.float32), np.array(PURPLE, np.float32)
    img = a[None, None] * (1 - t[..., None]) + b[None, None] * t[..., None]
    # Vignette.
    r = np.sqrt(((x - W / 2) / W) ** 2 + ((y - H / 2) / H) ** 2)
    img *= (1 - 0.55 * np.clip(r - 0.25, 0, 1))[..., None]
    base = Image.fromarray(np.clip(img, 0, 255).astype(np.uint8)).convert('RGBA')
    # Faint board holes on the right, like a Connect Four grid.
    grid = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    g = ImageDraw.Draw(grid)
    for i in range(22):
        for j in range(13):
            cx, cy = 40 + i * 90, 20 + j * 90
            g.ellipse((cx - 30, cy - 30, cx + 30, cy + 30), outline=(255, 255, 255, 10), width=2)
    return Image.alpha_composite(base, grid)


def blob(size, color, alpha):
    im = Image.new('RGBA', (size, size), color + (0,))
    m = Image.new('L', (size, size), 0)
    ImageDraw.Draw(m).ellipse((size * 0.2, size * 0.2, size * 0.8, size * 0.8), fill=alpha)
    im.putalpha(m.filter(ImageFilter.GaussianBlur(size // 8)))
    return im


BG = make_background()
BLOBS = [(blob(900, RED, 70), 0.0), (blob(1000, (120, 80, 255), 80), 2.0), (blob(700, YELLOW, 35), 4.0)]


def draw_background(frame, t):
    img = BG.copy()
    for i, (b, ph) in enumerate(BLOBS):
        cx = W * (0.25 + 0.5 * (0.5 + 0.5 * math.sin(t * 0.12 + ph + i)))
        cy = H * (0.3 + 0.4 * (0.5 + 0.5 * math.cos(t * 0.09 + ph * 1.3)))
        img.paste(b, (int(cx - b.width / 2), int(cy - b.height / 2)), b)
    return img


# ---------------------------------------------------------------- scenes
def caption_chunks(text, maxlen=58):
    import re
    out = []
    for sent in re.split(r'(?<=[.?!])\s+|(?<=[.?!]”)\s+', text.strip()):
        pieces = [sent]
        while any(len(p) > maxlen for p in pieces):
            p = next(p for p in pieces if len(p) > maxlen)
            i = pieces.index(p)
            # Prefer the comma closest to the middle, else the middle space.
            cuts = [m.end() for m in re.finditer(r'[,:]\s', p)] or [m.end() for m in re.finditer(r'\s', p)]
            c = min(cuts, key=lambda k: abs(k - len(p) / 2))
            pieces[i:i + 1] = [p[:c].strip(), p[c:].strip()]
        out += pieces
    merged = []
    for p in out:
        if merged and len(p) < 16 and len(merged[-1]) + len(p) < 72:
            merged[-1] += ' ' + p
        else:
            merged.append(p)
    return merged


SCENES = {
    'guest': dict(kicker='SERVERPOD NATIVE AUTH', title=['PLAY FIRST.', 'SIGN UP LATER.'],
                  chips=[('Email sign-in', GREEN), ('JWT sessions', YELLOW), ('Guest keeps everything', RED)],
                  beats=[(0.3, ['01_home_guest', '02_settings_guest', '04_account_created'])],
                  callouts=[(4.2, '04_account_created', (0, 2150, 1080, 2300), 760, (1130, 770), GREEN)]),
    'profile': dict(kicker='PROFILE · CAMERA', title=['SNAP YOUR', 'PROFILE PHOTO.'],
                    chips=[('Camera', YELLOW), ('Serverpod file uploads', GREEN), ('Cloud storage', RED)],
                    beats=[(0.3, ['38_edit_profile', '39_photo_picker', '28_leaderboard'])],
                    callouts=[(2.6, '39_photo_picker', (0, 1990, 1080, 2300), 640, (1120, 760), YELLOW)]),
    'normal': dict(kicker='NORMAL MODE · ON-DEVICE AI', title=['FIVE BOTS.', 'ZERO LAG.'],
                   chips=[('5 RL networks', YELLOW), ('MCTS × 800', RED), ('TFLite on device', GREEN)],
                   beats=[(0.3, ['05_normal_levels', 'clip:clip'])],
                   callouts=[(5.0, '05_normal_levels', (56, 1750, 1024, 2066), 620, (1010, 770), YELLOW)]),
    'offline': dict(kicker='OFFLINE FIRST', title=['WORKS ON', 'A PLANE.'],
                    chips=[('database: sync', GREEN), ('SQLite to Postgres', YELLOW), ('Synced on reconnect', RED)],
                    beats=[(0.3, ['33_offline_normal_game', '34_offline_win', '35_history_synced'])],
                    callouts=[(3.6, '35_history_synced', (56, 466, 1024, 676), 700, (1160, 760), GREEN)]),
    'ranked': dict(kicker='RANKED · SERVER-AUTHORITATIVE', title=['NO WAY', 'TO CHEAT.'],
                   chips=[('Every move validated', RED), ('Elo · K = 32', YELLOW), ('Same net in pure Dart', GREEN)],
                   beats=[(0.3, ['10_ranked_lobby', '12_ranked_result'])],
                   callouts=[(3.4, '10_ranked_lobby', (56, 276, 1024, 700), 640, (1300, 600), YELLOW)]),
    'multi': dict(kicker='MULTIPLAYER · REAL TIME', title=['PLAY FRIENDS', 'LIVE.'],
                  chips=[('Serverpod streams', GREEN), ('6-letter rooms', YELLOW), ('QR · shake to add', RED)],
                  beats=[(0.3, ['13_multi_code', '14_multi_game', '15_multi_win']),
                         (4.8, ['17_friends_qr', '36_shake', '19_friends_list'])],
                  callouts=[]),
    'review': dict(kicker='REPLAY & REVIEW', title=['KNOW WHY', 'YOU LOST.'],
                   chips=[('Exact negamax', YELLOW), ('LLM coach', GREEN)],
                   beats=[(0.3, ['08_history', '09_review_llm'])],
                   callouts=[(2.0, '09_review_llm', (56, 1500, 1024, 2084), 680, (1110, 630), GREEN)]),
    'assistant': dict(kicker='AI ASSISTANT · MCP', title=['JUST ASK.', 'IT BUILDS IT.'],
                      chips=[('MCP tools in Serverpod', GREEN), ('Charts · crossed tables', YELLOW), ('PDF · CSV export', RED)],
                      beats=[(0.3, ['22_assistant_prompt', '24_assistant_pivot']),
                             (7.4, ['40_dashboard_chart', '41_dashboard_heatmap', '27_export_pdf_share'])],
                      callouts=[(3.6, '24_assistant_pivot', (40, 770, 1040, 1500), 560, (1500, 600), YELLOW)]),
    'flat': dict(kicker='CONTEXT-AWARE', title=['LAY IT FLAT.', 'PLAY FACE TO FACE.'],
                 chips=[('Accelerometer', YELLOW), ('Two players, one phone', RED)],
                 beats=[(0.3, ['32_home_upright', '29_face_to_face'])],
                 swaps=[(1.6, 0, '00_home')],
                 callouts=[]),
    'themes': dict(kicker='EVERYWHERE', title=['YOUR LANGUAGE.', 'YOUR THEME.'],
                   chips=[('English · Français', GREEN), ('Dark · Light', YELLOW)],
                   beats=[(0.3, ['00_home', '30_settings_fr_light'])],
                   swaps=[(1.2, 0, '31_home_fr_light')],
                   callouts=[]),
}

PHONE_AREA = (730, 1870)
PHONE_CY = 500


class Scene:
    def __init__(self, sid, start, dur, vo_len, vo_text):
        self.id, self.start, self.dur = sid, start, dur
        self.vo_start = start + (1.9 if sid == 'intro' else 0.5)
        self.vo_len = vo_len
        self.cfg = SCENES.get(sid)
        self.captions = []
        chunks = caption_chunks(vo_text)
        total = sum(len(c) for c in chunks)
        t = self.vo_start
        for c in chunks:
            d = vo_len * len(c) / total
            self.captions.append((t, t + d, caption_sprite(c)))
            t += d
        if self.cfg:
            self._build()

    def _build(self):
        c = self.cfg
        ks = 30
        while font(F_KICK, ks).getlength(c['kicker']) + len(c['kicker']) * 4 > 500:
            ks -= 1
        self.kicker = text_sprite(c['kicker'], font(F_KICK, ks), YELLOW, spacing=4)
        size = 128
        while max(font(F_TITLE, size).getlength(l) for l in c['title']) > 540:
            size -= 4
        f = font(F_TITLE, size)
        self.title_words = []  # (sprite, x, line)
        for li, line in enumerate(c['title']):
            x = 0
            for wi, word in enumerate(line.split(' ')):
                sp = text_sprite(word, f, WHITE if li == 0 else RED)
                self.title_words.append((sp, x, li))
                x += f.getlength(word + ' ')
        self.title_lh = int(size * 0.98)
        self.chips = [chip_sprite(t, col) for t, col in c['chips']]
        self.beats = []
        for bt, names in c['beats']:
            sprites = [ClipPhone(os.path.join(HERE, n[5:])) if n.startswith('clip:')
                       else phone_sprite(n, 700 if len(names) >= 3 else 790) for n in names]
            self.beats.append((bt, names, sprites))
        hs = 700 if len(c['beats'][0][1]) >= 3 else 790
        self.swaps = [(st, slot, phone_sprite(n, hs)) for st, slot, n in c.get('swaps', [])]
        self.callouts = [(ct, callout_sprite(n, box, w, col), pos) for ct, n, box, w, pos, col in c['callouts']]

    # Phone x positions for n phones in the right area.
    @staticmethod
    def slots(n, pw):
        a, b = PHONE_AREA
        gap = 46
        total = n * pw + (n - 1) * gap
        x0 = a + (b - a - total) / 2
        return [x0 + i * (pw + gap) for i in range(n)]

    def draw(self, img, t):
        lt = t - self.start
        if self.id == 'intro':
            draw_intro(img, lt, self.dur)
        elif self.id == 'outro':
            draw_outro(img, lt, self.dur)
        else:
            self.draw_text(img, lt)
            self.draw_phones(img, lt)
            for ct, (sp, pad), (cx, cy) in self.callouts:
                k = lt - ct
                # Gone before the next set of phones arrives.
                later = [bt for bt, _, _ in self.beats if bt > ct]
                life = min(4.6, (later[0] - 0.5 - ct) if later else 4.6)
                if k < 0 or k > life:
                    continue
                s = 0.6 + 0.4 * ease_out_back(k / 0.45) if k < 0.45 else 1.0
                fade = clamp((life - k) / 0.35)
                paste_scaled(img, sp, cx, cy, s, min(clamp(k / 0.2), fade))
        self.draw_caption(img, t)

    def draw_text(self, img, lt):
        x0, y0 = 110, 300
        k = ease_out_cubic(lt / 0.5)
        # Accent bar + kicker slide in from the left.
        bar_w = int(70 * k)
        d = ImageDraw.Draw(img)
        if bar_w > 0:
            d.rounded_rectangle((x0, y0 + 14, x0 + bar_w, y0 + 22), 4, fill=RED)
        paste_alpha(img, self.kicker, x0 + 90 - int(40 * (1 - k)), y0, clamp(lt / 0.4))
        ty = y0 + 60
        for i, (sp, x, li) in enumerate(self.title_words):
            kk = (lt - 0.15 - i * 0.09) / 0.45
            e = ease_out_back(kk, 1.4)
            paste_alpha(img, sp, x0 + int(x), ty + li * self.title_lh + int(70 * (1 - e)), clamp(kk * 1.6))
        cy = ty + len(self.cfg['title']) * self.title_lh + 40
        cx = x0
        for i, sp in enumerate(self.chips):
            kk = (lt - 0.7 - i * 0.12) / 0.4
            if kk <= 0:
                continue
            if cx + sp.width > 700:
                cx, cy = x0, cy + 64
            paste_scaled(img, sp, cx + sp.width / 2, cy + sp.height / 2, 0.7 + 0.3 * ease_out_back(kk), clamp(kk * 2))
            cx += sp.width + 14

    def draw_phones(self, img, lt):
        cur = [b for b in self.beats if lt >= b[0]]
        if not cur:
            return
        idx = len(cur) - 1
        bt, names, sprites = cur[-1]
        nxt = self.beats[idx + 1][0] if idx + 1 < len(self.beats) else None
        first = sprites[0]
        pw = (first.width - 2 * first.pad) if isinstance(first, ClipPhone) else first[0].width - 2 * first[1]
        xs = self.slots(len(sprites), pw)
        for i, entry in enumerate(sprites):
            # A screen recording starts once its phone has landed.
            sp, pad = entry.at(lt - bt - 0.5) if isinstance(entry, ClipPhone) else entry
            k = (lt - bt - i * 0.12) / 0.6
            e = ease_out_back(k, 1.2)
            y = PHONE_CY - (sp.height - 2 * pad) / 2 + 260 * (1 - e)
            a = clamp(k * 2)
            if nxt is not None:
                ko = (lt - (nxt - 0.45) - i * 0.06) / 0.4
                if ko > 0:
                    y -= 240 * ease_in(ko)
                    a *= 1 - clamp(ko)
            # Gentle float.
            y += 6 * math.sin(lt * 1.6 + i)
            sprite = sp
            for st, slot, (sw, spad) in self.swaps:
                if slot == i and lt >= st:
                    m = clamp((lt - st) / 0.5)
                    if m >= 1:
                        sprite = sw
                    else:
                        sprite = Image.blend(sp, sw, ease_in_out(m))
            paste_alpha(img, sprite, int(xs[i] - pad), int(y - pad), a)

    def draw_caption(self, img, t):
        # One caption at a time: fade in over 0.15 s, out over the last 0.12 s.
        for a, b, sp in self.captions:
            if a <= t < b:
                fade = min(clamp((t - a) / 0.15), clamp((b - t) / 0.12))
                paste_alpha(img, sp, int(W / 2 - sp.width / 2), 975 + int(10 * (1 - fade)), fade)
                break


def paste_alpha(img, sp, x, y, a):
    if a <= 0:
        return
    if a < 1:
        sp = sp.copy()
        sp.putalpha(sp.split()[3].point(lambda v: int(v * a)))
    img.alpha_composite(sp, (int(x), int(y))) if 0 <= x and 0 <= y and x + sp.width <= W and y + sp.height <= H \
        else img.paste(sp, (int(x), int(y)), sp)


def paste_scaled(img, sp, cx, cy, s, a):
    if a <= 0 or s <= 0.01:
        return
    if abs(s - 1) > 0.004:
        sp = sp.resize((max(1, int(sp.width * s)), max(1, int(sp.height * s))), Image.BILINEAR)
    paste_alpha(img, sp, int(cx - sp.width / 2), int(cy - sp.height / 2), a)


# ------------------------------------------------------------ intro/outro
LOGO_Y = disc(230, YELLOW)
LOGO_R = disc(230, RED)
BRAND = None


def brand_sprites():
    global BRAND
    if BRAND is None:
        f = font(F_TITLE, 190)
        BRAND = (text_sprite('CONNECT', f, WHITE), text_sprite('4', f, RED),
                 text_sprite('Neural-net bots  ·  LLM coach  ·  Serverpod', font(F_KICK, 34), MUTED, spacing=2),
                 [phone_sprite('37_welcome_release', 700), phone_sprite('00_home', 700)])
    return BRAND


def draw_logo(img, lt, cx, cy, scale=1.0):
    for i, (sp, dx, dy) in enumerate(((LOGO_Y, -55, -30), (LOGO_R, 55, 30))):
        k = (lt - 0.15 - i * 0.28) / 0.9
        if k <= 0:
            continue
        y = cy + dy * scale - (1 - bounce(k)) * 700
        s = sp if scale == 1 else sp.resize((int(sp.width * scale), int(sp.height * scale)), Image.LANCZOS)
        paste_alpha(img, s, cx + dx * scale - s.width / 2, y - s.height / 2, 1)


def draw_intro(img, lt, dur):
    conn, four, tag, phones = brand_sprites()
    # 0-2.2 s: logo centre stage; then it moves left and the phones arrive.
    m = ease_in_out((lt - 2.4) / 0.9)
    lx = (W / 2 - 520) * (1 - m) + 330 * m
    ly = 380 * (1 - m) + 330 * m
    sc = 1.0 - 0.35 * m
    draw_logo(img, lt, int(lx), int(ly), sc)
    k = ease_out_cubic((lt - 1.2) / 0.6)
    tx = (W / 2 - 300) * (1 - m) + 110 * m
    ty = (300 * (1 - m) + 470 * m)
    s = 1 - 0.3 * m
    c2 = conn if s == 1 else conn.resize((int(conn.width * s), int(conn.height * s)), Image.LANCZOS)
    f2 = four if s == 1 else four.resize((int(four.width * s), int(four.height * s)), Image.LANCZOS)
    if k > 0:
        paste_alpha(img, c2, int(tx + 60 * (1 - k)), int(ty), k)
        paste_alpha(img, f2, int(tx + c2.width + 6 + 60 * (1 - k)), int(ty), k)
        kt = clamp((lt - 1.8) / 0.5)
        paste_alpha(img, tag, int(tx + 8), int(ty + c2.height + 4), kt)
    for i, (sp, pad) in enumerate(phones):
        kk = (lt - 3.0 - i * 0.2) / 0.7
        if kk <= 0:
            continue
        e = ease_out_back(kk, 1.2)
        x = 1020 + i * 400
        y = 160 + 300 * (1 - e) + 8 * math.sin(lt * 1.5 + i)
        paste_alpha(img, sp, x - pad, y - pad, clamp(kk * 2))


def draw_outro(img, lt, dur):
    conn, four, tag, _ = brand_sprites()
    draw_logo(img, lt, W // 2, 300, 0.8)
    k = ease_out_cubic((lt - 0.9) / 0.6)
    tw = conn.width + four.width + 6
    x = W / 2 - tw / 2
    if k > 0:
        paste_alpha(img, conn, int(x), int(470 + 40 * (1 - k)), k)
        paste_alpha(img, four, int(x + conn.width + 6), int(470 + 40 * (1 - k)), k)
    lines = [('PLAY IT ON THE WEB', 'puissance4.serverpod.space', YELLOW),
             ('ANDROID APK', 'github.com/loiclavorelM/puissance4', GREEN)]
    for i, (label, url, col) in enumerate(lines):
        kk = clamp((lt - 1.6 - i * 0.25) / 0.5)
        if kk <= 0:
            continue
        lab = text_sprite(label, font(F_KICK, 26), col, spacing=4)
        u = text_sprite(url, font(F_CAP, 40), WHITE)
        cx = W / 2 + (i * 2 - 1) * 380
        paste_alpha(img, lab, int(cx - lab.width / 2), int(735 + 20 * (1 - kk)), kk)
        paste_alpha(img, u, int(cx - u.width / 2), int(775 + 20 * (1 - kk)), kk)
    kk = clamp((lt - 2.4) / 0.6)
    b = text_sprite('BUILT WITH FLUTTER + SERVERPOD  ·  SERVERPOD HACKATHON', font(F_KICK, 24), MUTED, spacing=4)
    paste_alpha(img, b, int(W / 2 - b.width / 2), 880, kk)


# ------------------------------------------------------------- transition
COLS = 16
CW = W // COLS
random.seed(4)
COLUMN_SPRITES = []
for i in range(COLS):
    col = Image.new('RGBA', (CW, H), (24, 28, 70, 255))
    d = ImageDraw.Draw(col)
    d.line((CW - 1, 0, CW - 1, H), fill=(14, 16, 44, 255), width=2)
    for j in range(9):
        cy = 60 + j * 120
        colr = random.choice([RED, YELLOW, RED, YELLOW, (14, 16, 44)])
        col.alpha_composite(disc(100, colr, colr != (14, 16, 44)), (CW // 2 - 50, cy - 50))
    COLUMN_SPRITES.append(col)
TRANS = 0.85  # seconds


def draw_transition(img, k):
    """k in [0,1]: columns fall in (0-0.5), then fall out downwards (0.5-1)."""
    for i, sp in enumerate(COLUMN_SPRITES):
        order = i if (i % 2 == 0) else COLS - i
        d = (order / COLS) * 0.18
        if k < 0.5:
            kk = (k / 0.5 - d) / (1 - 0.18)
            if kk <= 0:
                continue
            y = -H + H * bounce(kk)
        else:
            kk = ((k - 0.5) / 0.5 - d) / (1 - 0.18)
            y = H * ease_in(kk)
            if y >= H:
                continue
        img.paste(sp, (i * CW, int(y)))


# ---------------------------------------------------------------- timeline
def build_timeline():
    script = json.load(open(os.path.join(HERE, 'script.json')))
    scenes, t = [], 0.0
    for s in script:
        with wave.open(os.path.join(VO_DIR, f"vo_{s['id']}.wav")) as w:
            vo = w.getnframes() / w.getframerate()
        lead = 1.9 if s['id'] == 'intro' else 0.5
        tail = {'intro': 1.2, 'outro': 3.2, 'themes': 1.4, 'flat': 1.4}.get(s['id'], 0.8)
        dur = lead + vo + tail
        if s['id'] == 'assistant':
            dur = max(dur, 12.6)
        scenes.append(Scene(s['id'], t, dur, vo, s['vo']))
        t += dur + (TRANS if s['id'] != 'outro' else 0)
    return scenes, t


def frame_at(scenes, t):
    img = draw_background(None, t)
    for i, s in enumerate(scenes):
        end = s.start + s.dur
        if s.start <= t < end:
            s.draw(img, t)
            break
        if end <= t < end + TRANS and i + 1 < len(scenes):
            k = (t - end) / TRANS
            (s if k < 0.5 else scenes[i + 1]).draw(img, end if k < 0.5 else scenes[i + 1].start)
            draw_transition(img, k)
            break
    else:
        scenes[-1].draw(img, t)
    return img.convert('RGB')


# -------------------------------------------------------------------- audio
def build_audio(scenes, total, sr=22050):
    n = int(total * sr) + sr
    vo = np.zeros(n, np.float32)
    for s in scenes:
        with wave.open(os.path.join(VO_DIR, f'vo_{s.id}.wav')) as w:
            data = np.frombuffer(w.readframes(w.getnframes()), np.int16).astype(np.float32) / 32768
            assert w.getframerate() == sr
        a = int(s.vo_start * sr)
        vo[a:a + len(data)] += data * 0.95
    t = np.arange(n) / sr
    # Soft pad, Am - F - C - G, two bars each at 100 bpm.
    chords = [[57, 60, 64], [53, 57, 60], [48, 52, 55], [55, 59, 62]]
    bar = 60 / 100 * 4
    pad = np.zeros(n, np.float32)
    for ci in range(int(total / (2 * bar)) + 2):
        notes = chords[ci % 4]
        a, b = int(ci * 2 * bar * sr), int((ci + 1) * 2 * bar * sr)
        seg = t[a:b] - t[a] if a < n else None
        if seg is None or len(seg) == 0:
            continue
        env = np.minimum(1, seg / 0.8) * np.minimum(1, (2 * bar - seg) / 0.8)
        for m in notes:
            f = 440 * 2 ** ((m - 69) / 12)
            pad[a:a + len(seg)] += (np.sin(2 * np.pi * f * seg) + 0.3 * np.sin(2 * np.pi * 2 * f * seg)) * env * 0.05
    # Plucked arpeggio on eighth notes.
    arp = np.zeros(n, np.float32)
    step = 60 / 100 / 2
    for k in range(int(total / step)):
        ci = int(k * step / (2 * bar)) % 4
        m = chords[ci][k % 3] + 12
        f = 440 * 2 ** ((m - 69) / 12)
        a = int(k * step * sr)
        ln = int(0.35 * sr)
        seg = np.arange(ln) / sr
        tone = np.sin(2 * np.pi * f * seg) * np.exp(-seg * 9) * 0.06
        arp[a:a + ln] += tone[:max(0, min(ln, n - a))]
    music = pad + arp
    # Duck the music under the voice.
    env = np.convolve(np.abs(vo), np.ones(int(0.25 * sr)) / (0.25 * sr), 'same')
    duck = 1 - 0.6 * np.clip(env * 25, 0, 1)
    music *= duck
    # Fade music in/out.
    music *= np.clip(t / 2, 0, 1) * np.clip((total - t) / 2.5, 0, 1)
    # Soft plastic "toc" taps on each transition: a few tonal, quickly
    # decaying hits (no noise), like discs dropping into a column.
    sfx = np.zeros(n, np.float32)
    for s in scenes[:-1]:
        end = s.start + s.dur
        for j, frac in enumerate((0.12, 0.22, 0.31, 0.39)):
            a = int((end + TRANS * frac) * sr)
            ln = int(0.12 * sr)
            seg = np.arange(ln) / sr
            f = 520 - j * 40
            tap = (np.sin(2 * np.pi * f * seg) + 0.4 * np.sin(2 * np.pi * 2.7 * f * seg)) * np.exp(-seg * 45)
            tap *= np.minimum(1, seg / 0.002) * 0.035
            sfx[a:a + ln] += tap[:max(0, min(ln, n - a))]
    mix = vo + music + sfx
    mix /= max(1.0, np.abs(mix).max() / 0.95)
    path = os.path.join(OUT, os.environ.get('AUDIO_NAME', 'audio.wav'))
    with wave.open(path, 'wb') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(sr)
        w.writeframes((mix * 32767).astype(np.int16).tobytes())
    return path


# --------------------------------------------------------------------- main
def main():
    scenes, total = build_timeline()
    print('total', round(total, 1), 's')
    for s in scenes:
        print(f'  {s.id:10s} {s.start:6.1f} +{s.dur:5.1f}')
    if '--preview' in sys.argv:
        for a in sys.argv[sys.argv.index('--preview') + 1:]:
            frame_at(scenes, float(a)).save(os.path.join(OUT, f'preview_{a}.png'))
        return
    if '--range' in sys.argv:
        i = sys.argv.index('--range')
        a, b, path = float(sys.argv[i + 1]), float(sys.argv[i + 2]), sys.argv[i + 3]
    else:
        a, b, path = 0, total, None
    if path is None:
        audio = build_audio(scenes, total)
        path = os.path.join(OUT, 'video.mp4')
    ff = subprocess.Popen(['ffmpeg', '-loglevel', 'error', '-y', '-f', 'rawvideo', '-pix_fmt', 'rgb24',
                           '-s', f'{W}x{H}', '-r', str(FPS), '-i', '-', '-c:v', 'libx264', '-preset', 'medium',
                           '-crf', '18', '-pix_fmt', 'yuv420p', path], stdin=subprocess.PIPE)
    f0, f1 = int(a * FPS), int(b * FPS)
    for f in range(f0, f1):
        ff.stdin.write(frame_at(scenes, f / FPS).tobytes())
        if f % 150 == 0:
            print('frame', f, '/', f1, flush=True)
    ff.stdin.close()
    ff.wait()


if __name__ == '__main__':
    main()
