"""
Genera mockup de pantallas de la app para la presentación académica.
Crea una imagen compuesta con 5 pantallas simuladas en marcos de teléfono.
"""

from PIL import Image, ImageDraw, ImageFont
import os

# ── Paleta de colores de la app ──────────────────────────────────────────────
BG_DARK    = (18, 30, 50)       # fondo general
GREEN_1    = (27, 94, 32)       # verde oscuro primario
GREEN_2    = (46, 125, 50)      # verde medio
GREEN_3    = (76, 175, 80)      # verde claro
ACCENT_YLW = (255, 214, 0)      # amarillo acento
ACCENT_BLU = (66, 165, 245)     # azul claro
WHITE      = (255, 255, 255)
LIGHT_GRAY = (236, 239, 241)
MID_GRAY   = (144, 164, 174)
DARK_GRAY  = (55, 71, 79)
CARD_BG    = (30, 45, 65)       # fondo tarjeta
CARD_BG2   = (22, 38, 55)
GRAD_TOP   = (27, 94, 32)
GRAD_BOT   = (13, 71, 161)

# ── Dimensiones ──────────────────────────────────────────────────────────────
PHONE_W    = 320
PHONE_H    = 580
CORNER_R   = 32
SCREEN_PAD = 14        # padding entre borde del teléfono y pantalla
SCREEN_W   = PHONE_W - 2 * SCREEN_PAD
SCREEN_H   = PHONE_H - 2 * SCREEN_PAD - 30   # reservar espacio para botón home

# Composición: 5 teléfonos en fila
N_PHONES   = 5
GAP        = 30
CANVAS_W   = N_PHONES * PHONE_W + (N_PHONES + 1) * GAP
CANVAS_H   = PHONE_H + 120     # margen superior e inferior

# ── Fuentes (usa fuentes del sistema, fallback a default) ────────────────────
def get_font(size, bold=False):
    candidates = [
        "C:/Windows/Fonts/segoeui.ttf",
        "C:/Windows/Fonts/calibri.ttf",
        "C:/Windows/Fonts/arial.ttf",
    ]
    bold_candidates = [
        "C:/Windows/Fonts/segoeuib.ttf",
        "C:/Windows/Fonts/calibrib.ttf",
        "C:/Windows/Fonts/arialbd.ttf",
    ]
    pool = bold_candidates if bold else candidates
    for path in pool:
        if os.path.exists(path):
            try:
                return ImageFont.truetype(path, size)
            except:
                pass
    return ImageFont.load_default()

# ── Helper: rectángulo redondeado ────────────────────────────────────────────
def rounded_rect(draw, xy, radius, fill=None, outline=None, width=1):
    x0, y0, x1, y1 = xy
    draw.rounded_rectangle([x0, y0, x1, y1], radius=radius, fill=fill,
                           outline=outline, width=width)

# ── Helper: degradado vertical ───────────────────────────────────────────────
def vertical_gradient(img, x0, y0, x1, y1, color_top, color_bot):
    draw = ImageDraw.Draw(img)
    h = y1 - y0
    if h <= 0: return
    for i in range(h):
        t = i / h
        r = int(color_top[0] + (color_bot[0] - color_top[0]) * t)
        g = int(color_top[1] + (color_bot[1] - color_top[1]) * t)
        b = int(color_top[2] + (color_bot[2] - color_top[2]) * t)
        draw.line([(x0, y0 + i), (x1, y0 + i)], fill=(r, g, b))

# ── Helper: texto centrado ───────────────────────────────────────────────────
def draw_text_centered(draw, text, cx, y, font, fill):
    bbox = draw.textbbox((0, 0), text, font=font)
    tw = bbox[2] - bbox[0]
    draw.text((cx - tw // 2, y), text, font=font, fill=fill)

# ── Helper: texto con wrap ───────────────────────────────────────────────────
def draw_wrapped(draw, text, x, y, max_w, font, fill, line_spacing=4):
    words = text.split()
    lines, line = [], []
    for w in words:
        test = ' '.join(line + [w])
        bbox = draw.textbbox((0, 0), test, font=font)
        if bbox[2] - bbox[0] <= max_w:
            line.append(w)
        else:
            if line: lines.append(' '.join(line))
            line = [w]
    if line: lines.append(' '.join(line))
    for ln in lines:
        draw.text((x, y), ln, font=font, fill=fill)
        bbox = draw.textbbox((0, 0), ln, font=font)
        y += (bbox[3] - bbox[1]) + line_spacing
    return y

# ── Dibujar marco de teléfono ────────────────────────────────────────────────
def draw_phone_frame(canvas, ox, oy):
    """Dibuja el cuerpo del teléfono sobre el canvas."""
    draw = ImageDraw.Draw(canvas)
    # Sombra
    for s in range(8, 0, -1):
        alpha = int(80 * (1 - s / 9))
        rounded_rect(draw, [ox + s, oy + s, ox + PHONE_W + s, oy + PHONE_H + s],
                     CORNER_R + 2, fill=(0, 0, 0, alpha))
    # Cuerpo
    rounded_rect(draw, [ox, oy, ox + PHONE_W, oy + PHONE_H],
                 CORNER_R, fill=(30, 30, 35), outline=(80, 90, 100), width=2)
    # Notch / cámara frontal
    draw.ellipse([ox + PHONE_W // 2 - 5, oy + 8, ox + PHONE_W // 2 + 5, oy + 18],
                 fill=(50, 50, 55))
    # Botón home
    draw.rounded_rectangle([ox + PHONE_W // 2 - 20, oy + PHONE_H - 20,
                             ox + PHONE_W // 2 + 20, oy + PHONE_H - 8],
                            radius=6, outline=(80, 90, 100), width=1)

# ── Pantalla de la app ────────────────────────────────────────────────────────
def screen_area(ox, oy):
    """Devuelve (sx, sy, sw, sh) del área de pantalla dentro del teléfono."""
    sx = ox + SCREEN_PAD
    sy = oy + SCREEN_PAD + 22   # espacio para notch
    sw = SCREEN_W
    sh = SCREEN_H - 10
    return sx, sy, sw, sh

# ════════════════════════════════════════════════════════════════════════════
# PANTALLA 1 — Home Screen (Panel Principal)
# ════════════════════════════════════════════════════════════════════════════
def draw_home(canvas, ox, oy):
    draw = ImageDraw.Draw(canvas)
    sx, sy, sw, sh = screen_area(ox, oy)

    # Fondo de pantalla
    vertical_gradient(canvas, sx, sy, sx + sw, sy + sh,
                      (27, 94, 32), (13, 40, 80))

    f_big   = get_font(14, bold=True)
    f_med   = get_font(11, bold=False)
    f_small = get_font(9,  bold=False)
    f_icon  = get_font(16, bold=True)

    # Header
    draw.rectangle([sx, sy, sx + sw, sy + 55], fill=(20, 70, 25))
    draw_text_centered(draw, "🌿 Ciencias Naturales", sx + sw // 2, sy + 8, f_big, WHITE)
    draw_text_centered(draw, "¡Hola, Estudiante!", sx + sw // 2, sy + 28, f_med, ACCENT_YLW)
    draw_text_centered(draw, "⭐ 250 XP  |  Nivel 3", sx + sw // 2, sy + 44, f_small, LIGHT_GRAY)

    # Tarjetas de características (2×3 grid)
    items = [
        ("📚", "Guía",    GREEN_2),
        ("🤖", "Chatbot", (13, 71, 161)),
        ("🔍", "Escáner", (74, 20, 140)),
        ("🏆", "Logros",  (230, 81, 0)),
        ("📖", "Glosario",(0, 96, 100)),
        ("🎯", "Quiz",    (136, 14, 79)),
    ]
    card_w = (sw - 6) // 2
    card_h = 52
    gx, gy = sx + 2, sy + 62
    for i, (icon, label, color) in enumerate(items):
        col, row = i % 2, i // 2
        cx0 = gx + col * (card_w + 4)
        cy0 = gy + row * (card_h + 4)
        rounded_rect(draw, [cx0, cy0, cx0 + card_w, cy0 + card_h],
                     10, fill=color)
        draw_text_centered(draw, icon,  cx0 + card_w // 2, cy0 + 8,  f_icon,  WHITE)
        draw_text_centered(draw, label, cx0 + card_w // 2, cy0 + 32, f_small, WHITE)

    # Barra inferior
    draw.rectangle([sx, sy + sh - 24, sx + sw, sy + sh], fill=(20, 30, 45))
    for i, lbl in enumerate(["🏠", "👤", "⚙️"]):
        lx = sx + (i + 1) * sw // 4
        draw_text_centered(draw, lbl, lx, sy + sh - 20, f_med, MID_GRAY)


# ════════════════════════════════════════════════════════════════════════════
# PANTALLA 2 — Chatbot
# ════════════════════════════════════════════════════════════════════════════
def draw_chat(canvas, ox, oy):
    draw = ImageDraw.Draw(canvas)
    sx, sy, sw, sh = screen_area(ox, oy)

    # Fondo
    draw.rectangle([sx, sy, sx + sw, sy + sh], fill=(15, 22, 40))

    f_big   = get_font(13, bold=True)
    f_med   = get_font(10)
    f_small = get_font(9)

    # Header
    draw.rectangle([sx, sy, sx + sw, sy + 42], fill=(13, 71, 161))
    draw_text_centered(draw, "🤖 Asistente IA", sx + sw // 2, sy + 8,  f_big,  WHITE)
    draw_text_centered(draw, "Ciencias Naturales", sx + sw // 2, sy + 26, f_small, LIGHT_GRAY)

    # Mensajes del chat
    msgs = [
        ("Bot", "¡Hola! Soy tu asistente de Ciencias Naturales. ¿En qué puedo ayudarte hoy?", (20, 60, 100)),
        ("Tú",  "¿Qué es la mitocondria?", (27, 94, 32)),
        ("Bot", "La mitocondria es el organelo encargado de producir energía (ATP) para la célula. Se le llama 'central energética' 🔋", (20, 60, 100)),
        ("Tú",  "¿Y cómo lo hace?", (27, 94, 32)),
    ]
    my = sy + 50
    for sender, text, color in msgs:
        is_me = sender == "Tú"
        bw = int(sw * 0.72)
        # Calcula altura aprox
        lines = max(1, len(text) // 28)
        bh = 14 + lines * 14
        bx = (sx + sw - bw - 4) if is_me else (sx + 4)
        rounded_rect(draw, [bx, my, bx + bw, my + bh], 8, fill=color)
        draw_wrapped(draw, text, bx + 5, my + 4, bw - 10, f_small, WHITE)
        my += bh + 6

    # Input
    rounded_rect(draw, [sx + 4, sy + sh - 30, sx + sw - 30, sy + sh - 8],
                 10, fill=(30, 40, 60), outline=ACCENT_BLU, width=1)
    draw.text((sx + 10, sy + sh - 26), "Escribe o habla...", font=f_small, fill=MID_GRAY)
    # Botón micrófono
    draw.ellipse([sx + sw - 28, sy + sh - 32, sx + sw - 4, sy + sh - 6],
                 fill=(13, 71, 161))
    draw_text_centered(draw, "🎙", sx + sw - 16, sy + sh - 30, f_small, WHITE)


# ════════════════════════════════════════════════════════════════════════════
# PANTALLA 3 — Escáner de Imágenes
# ════════════════════════════════════════════════════════════════════════════
def draw_scanner(canvas, ox, oy):
    draw = ImageDraw.Draw(canvas)
    sx, sy, sw, sh = screen_area(ox, oy)

    # Fondo tipo visor de cámara
    draw.rectangle([sx, sy, sx + sw, sy + sh], fill=(8, 12, 20))

    f_big   = get_font(13, bold=True)
    f_med   = get_font(10)
    f_small = get_font(9)

    # Header
    draw.rectangle([sx, sy, sx + sw, sy + 38], fill=(50, 0, 80))
    draw_text_centered(draw, "🔍 Reconocimiento IA", sx + sw // 2, sy + 6,  f_big,  WHITE)
    draw_text_centered(draw, "Apunta la cámara a un organismo", sx + sw // 2, sy + 24, f_small, LIGHT_GRAY)

    # Área de cámara simulada
    cam_y = sy + 44
    cam_h = int(sh * 0.44)
    draw.rectangle([sx, cam_y, sx + sw, cam_y + cam_h], fill=(20, 25, 35))
    # Grid de visor
    for i in range(1, 3):
        draw.line([(sx + i * sw // 3, cam_y), (sx + i * sw // 3, cam_y + cam_h)],
                  fill=(255, 255, 255, 60), width=1)
        draw.line([(sx, cam_y + i * cam_h // 3), (sx + sw, cam_y + i * cam_h // 3)],
                  fill=(255, 255, 255, 60), width=1)
    # Marco de detección
    mx, my2 = sx + sw // 4, cam_y + cam_h // 5
    mw, mh = sw // 2, cam_h * 3 // 5
    for corner_len in [20]:
        # Esquinas del marco
        pts = [(mx, my2), (mx + mw, my2), (mx, my2 + mh), (mx + mw, my2 + mh)]
        dirs = [(1, 1), (-1, 1), (1, -1), (-1, -1)]
        for (px, py), (dx, dy) in zip(pts, dirs):
            draw.line([(px, py), (px + dx * corner_len, py)], fill=ACCENT_YLW, width=2)
            draw.line([(px, py), (px, py + dy * corner_len)], fill=ACCENT_YLW, width=2)

    # Icono planta en el centro del visor
    draw_text_centered(draw, "🌿", sx + sw // 2, cam_y + cam_h // 2 - 12, get_font(28), WHITE)

    # Resultado
    res_y = cam_y + cam_h + 6
    rounded_rect(draw, [sx + 4, res_y, sx + sw - 4, res_y + 30], 8, fill=(0, 77, 64))
    draw_text_centered(draw, "✅  Helecho común  •  98%", sx + sw // 2, res_y + 8, f_med, WHITE)

    # Tarjeta info
    info_y = res_y + 36
    rounded_rect(draw, [sx + 4, info_y, sx + sw - 4, info_y + 82], 8, fill=CARD_BG)
    draw.text((sx + 10, info_y + 6),  "Nombre científico:", font=f_small, fill=MID_GRAY)
    draw.text((sx + 10, info_y + 18), "Pteridium aquilinum", font=get_font(10, bold=True), fill=WHITE)
    draw.text((sx + 10, info_y + 34), "Hábitat:", font=f_small, fill=MID_GRAY)
    draw.text((sx + 10, info_y + 46), "Bosques y zonas húmedas", font=f_small, fill=LIGHT_GRAY)
    draw.text((sx + 10, info_y + 60), "🌱 Dato curioso:", font=f_small, fill=ACCENT_YLW)
    draw.text((sx + 10, info_y + 72), "Planta vascular sin semillas", font=f_small, fill=LIGHT_GRAY)

    # Botón tomar foto
    btn_y = sy + sh - 28
    rounded_rect(draw, [sx + sw // 2 - 24, btn_y - 2, sx + sw // 2 + 24, btn_y + 22],
                 14, fill=(74, 20, 140))
    draw_text_centered(draw, "📷 Capturar", sx + sw // 2, btn_y + 3, f_small, WHITE)


# ════════════════════════════════════════════════════════════════════════════
# PANTALLA 4 — Guía / Subtema
# ════════════════════════════════════════════════════════════════════════════
def draw_guide(canvas, ox, oy):
    draw = ImageDraw.Draw(canvas)
    sx, sy, sw, sh = screen_area(ox, oy)

    vertical_gradient(canvas, sx, sy, sx + sw, sy + sh, (15, 30, 55), (10, 20, 38))

    f_big   = get_font(13, bold=True)
    f_med   = get_font(10)
    f_small = get_font(9)

    # Header
    draw.rectangle([sx, sy, sx + sw, sy + 38], fill=GREEN_1)
    draw_text_centered(draw, "📚 Guía Didáctica", sx + sw // 2, sy + 6,  f_big,  WHITE)
    draw_text_centered(draw, "Biología Celular", sx + sw // 2, sy + 24, f_small, ACCENT_YLW)

    # Subtemas
    subtemas = [
        ("1", "La Célula y sus Características",  "✅", (27, 94, 32), "100%"),
        ("2", "Organelos Celulares",               "✅", (27, 94, 32), "100%"),
        ("3", "Célula Eucariota vs Procariota",    "🔄", (13, 71, 161), "60%"),
        ("4", "División Celular y Reproducción",   "🔒", DARK_GRAY, "0%"),
    ]
    cy = sy + 46
    for num, title, icon, color, pct in subtemas:
        rounded_rect(draw, [sx + 4, cy, sx + sw - 4, cy + 46], 8, fill=CARD_BG)
        # Color lateral
        draw.rectangle([sx + 4, cy, sx + 12, cy + 46], fill=color)
        draw_text_centered(draw, icon, sx + 22, cy + 14, get_font(14), WHITE)
        draw.text((sx + 34, cy + 6),  f"Subtema {num}", font=f_small, fill=MID_GRAY)
        draw.text((sx + 34, cy + 18), title, font=f_small, fill=WHITE)
        # Barra de progreso
        bar_x, bar_y = sx + 34, cy + 34
        bar_w = sw - 55
        draw.rounded_rectangle([bar_x, bar_y, bar_x + bar_w, bar_y + 6],
                                radius=3, fill=(40, 55, 75))
        fill_w = int(bar_w * int(pct[:-1]) / 100)
        if fill_w > 0:
            draw.rounded_rectangle([bar_x, bar_y, bar_x + fill_w, bar_y + 6],
                                    radius=3, fill=color)
        draw.text((bar_x + bar_w + 3, bar_y - 1), pct, font=f_small, fill=MID_GRAY)
        cy += 52

    # Sabías que
    rounded_rect(draw, [sx + 4, cy + 4, sx + sw - 4, cy + 44], 8,
                 fill=(230, 81, 0, 180))
    draw.text((sx + 10, cy + 8),  "💡 ¿Sabías que...?", font=f_med, fill=ACCENT_YLW)
    draw.text((sx + 10, cy + 24), "El cuerpo humano tiene ~37 billones", font=f_small, fill=WHITE)
    draw.text((sx + 10, cy + 36), "de células.", font=f_small, fill=WHITE)


# ════════════════════════════════════════════════════════════════════════════
# PANTALLA 5 — Perfil / Gamificación
# ════════════════════════════════════════════════════════════════════════════
def draw_profile(canvas, ox, oy):
    draw = ImageDraw.Draw(canvas)
    sx, sy, sw, sh = screen_area(ox, oy)

    vertical_gradient(canvas, sx, sy, sx + sw, sy + sh, (10, 25, 50), (5, 15, 35))

    f_big   = get_font(13, bold=True)
    f_med   = get_font(11, bold=True)
    f_small = get_font(9)
    f_xp    = get_font(10)

    # Header con avatar
    draw.rectangle([sx, sy, sx + sw, sy + 80], fill=(18, 55, 90))
    draw.ellipse([sx + sw // 2 - 22, sy + 8, sx + sw // 2 + 22, sy + 52],
                 fill=(46, 125, 50), outline=ACCENT_YLW, width=2)
    draw_text_centered(draw, "👤", sx + sw // 2, sy + 16, get_font(22), WHITE)
    draw_text_centered(draw, "Estudiante", sx + sw // 2, sy + 56, f_big,  WHITE)
    draw_text_centered(draw, "Nivel 3 · Biólogo Junior", sx + sw // 2, sy + 70, f_small, ACCENT_YLW)

    # Barra XP
    xp_y = sy + 88
    draw.text((sx + 8, xp_y), "XP: 250 / 300", font=f_small, fill=MID_GRAY)
    draw.rounded_rectangle([sx + 8, xp_y + 14, sx + sw - 8, xp_y + 24],
                            radius=5, fill=(30, 45, 65))
    draw.rounded_rectangle([sx + 8, xp_y + 14, sx + 8 + int((sw - 16) * 0.83), xp_y + 24],
                            radius=5, fill=ACCENT_YLW)

    # Estadísticas en tarjetas
    stats = [
        ("🎯", "4/4",  "Subtemas"),
        ("✅", "12",   "Quizzes"),
        ("🔥", "5",    "Racha días"),
        ("💬", "28",   "Preguntas"),
    ]
    st_y = xp_y + 32
    sw2 = (sw - 10) // 2
    for i, (icon, val, label) in enumerate(stats):
        col, row = i % 2, i // 2
        cx0 = sx + 4 + col * (sw2 + 4)
        cy0 = st_y + row * 46
        rounded_rect(draw, [cx0, cy0, cx0 + sw2, cy0 + 40], 8, fill=CARD_BG)
        draw_text_centered(draw, icon + " " + val, cx0 + sw2 // 2, cy0 + 5,  f_med,  WHITE)
        draw_text_centered(draw, label,             cx0 + sw2 // 2, cy0 + 25, f_small, MID_GRAY)

    # Logros
    log_y = st_y + 100
    draw.text((sx + 8, log_y), "🏆 Logros desbloqueados", font=f_small, fill=ACCENT_YLW)
    achievements = [("🥇","Primer Quiz",""), ("⚡","Racha 5 días",""), ("🌟","100% Guía","")]
    ax = sx + 6
    for icon, name, _ in achievements:
        rounded_rect(draw, [ax, log_y + 14, ax + 80, log_y + 52], 8, fill=(40, 60, 30))
        draw_text_centered(draw, icon, ax + 40, log_y + 16, get_font(14), WHITE)
        draw_text_centered(draw, name, ax + 40, log_y + 36, get_font(8),  LIGHT_GRAY)
        ax += 86


# ════════════════════════════════════════════════════════════════════════════
# MAIN — Composición final
# ════════════════════════════════════════════════════════════════════════════
def build_mockup():
    canvas = Image.new("RGB", (CANVAS_W, CANVAS_H), color=(12, 18, 32))
    draw_canvas = ImageDraw.Draw(canvas)

    # Título superior
    f_title = get_font(22, bold=True)
    f_sub   = get_font(13)
    draw_text_centered(draw_canvas, "Prototipo Funcional — Pantallas Principales",
                       CANVAS_W // 2, 18, f_title, WHITE)
    draw_text_centered(draw_canvas, "Aplicación Móvil Educativa · Flutter · Android",
                       CANVAS_W // 2, 48, f_sub, (144, 164, 174))

    # Etiquetas de pantallas
    labels = ["Inicio", "Chatbot IA", "Escáner IA", "Guía Didáctica", "Perfil / Logros"]
    painters = [draw_home, draw_chat, draw_scanner, draw_guide, draw_profile]

    f_label = get_font(12, bold=True)
    f_desc  = get_font(10)

    for i, (label, painter) in enumerate(zip(labels, painters)):
        ox = GAP + i * (PHONE_W + GAP)
        oy = 76

        draw_phone_frame(canvas, ox, oy)
        painter(canvas, ox, oy)

        # Etiqueta inferior
        lx = ox + PHONE_W // 2
        ly = oy + PHONE_H + 10
        draw_text_centered(draw_canvas, label, lx, ly, f_label, ACCENT_YLW)

    # Línea decorativa inferior
    draw_canvas.rectangle([GAP, CANVAS_H - 8, CANVAS_W - GAP, CANVAS_H - 4],
                           fill=GREEN_3)

    output = "C:/mi_app/assets/mockup_pantallas.png"
    canvas.save(output, "PNG", quality=95)
    print(f"[OK] Mockup guardado: {output}")
    print(f"     Dimensiones: {canvas.width} x {canvas.height} px")
    return output


if __name__ == "__main__":
    build_mockup()
