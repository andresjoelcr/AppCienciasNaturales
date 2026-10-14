"""
Script para crear la presentación de ponencia académica
Tema: Aplicación Móvil Educativa Basada en Chatbot Conversacional y
Reconocimiento de Imágenes para la Enseñanza de Ciencias Naturales
"""

import zipfile
import shutil
import os
import re
from lxml import etree

# --- Rutas ---
TEMPLATE_PATH = "C:/mi_app/assets/Presentacion.pptx"
OUTPUT_PATH   = "C:/mi_app/assets/Ponencia_CienciasNaturales.pptx"
WORK_DIR      = "C:/mi_app/assets/tmp_build"

# Namespace map
NS = {
    'a':  'http://schemas.openxmlformats.org/drawingml/2006/main',
    'r':  'http://schemas.openxmlformats.org/officeDocument/2006/relationships',
    'p':  'http://schemas.openxmlformats.org/presentationml/2006/main',
    'p14':'http://schemas.microsoft.com/office/powerpoint/2010/main',
    'a16':'http://schemas.microsoft.com/office/drawing/2014/main',
}
for prefix, uri in NS.items():
    etree.register_namespace(prefix, uri)

# ─────────────────────────────────────────────
# Helpers para construir XML de texto
# ─────────────────────────────────────────────

def make_txBody(paragraphs, font_size=1800, bold=False, color_hex="FFFFFF",
                font_face="Roboto Condensed", align='l', wrap=True):
    """
    paragraphs: lista de str   → cada elemento es un párrafo
                o lista de (str, dict)  donde dict puede tener keys:
                  size, bold, color, align, font, indent_level
    """
    A = 'http://schemas.openxmlformats.org/drawingml/2006/main'
    bodyPr = etree.Element(f'{{{A}}}bodyPr')
    bodyPr.set('wrap', 'square' if wrap else 'none')
    bodyPr.set('rtlCol', '0')
    spAF = etree.SubElement(bodyPr, f'{{{A}}}spAutoFit')

    lstStyle = etree.Element(f'{{{A}}}lstStyle')

    para_elems = []
    for item in paragraphs:
        if isinstance(item, tuple):
            text, opts = item
        else:
            text, opts = item, {}

        sz   = opts.get('size', font_size)
        bd   = opts.get('bold', bold)
        clr  = opts.get('color', color_hex)
        al   = opts.get('align', align)
        face = opts.get('font', font_face)
        lvl  = opts.get('level', 0)

        p_elem = etree.Element(f'{{{A}}}p')
        pPr = etree.SubElement(p_elem, f'{{{A}}}pPr')
        pPr.set('algn', al)
        if lvl > 0:
            pPr.set('indent', '-342900')
            pPr.set('marL', str(342900 + lvl * 342900))

        if text == '':
            # empty paragraph (spacer)
            para_elems.append(p_elem)
            continue

        r_elem = etree.SubElement(p_elem, f'{{{A}}}r')
        rPr = etree.SubElement(r_elem, f'{{{A}}}rPr')
        rPr.set('lang', 'es-CO')
        rPr.set('sz', str(sz))
        rPr.set('b', '1' if bd else '0')
        rPr.set('dirty', '0')

        solidFill = etree.SubElement(rPr, f'{{{A}}}solidFill')
        srgbClr   = etree.SubElement(solidFill, f'{{{A}}}srgbClr')
        srgbClr.set('val', clr)

        lat = etree.SubElement(rPr, f'{{{A}}}latin')
        lat.set('typeface', face)
        ea = etree.SubElement(rPr, f'{{{A}}}ea')
        ea.set('typeface', face)

        t_elem = etree.SubElement(r_elem, f'{{{A}}}t')
        t_elem.text = text
        para_elems.append(p_elem)

    txBody = etree.Element(f'{{{A}}}txBody')
    txBody.append(bodyPr)
    txBody.append(lstStyle)
    for pe in para_elems:
        txBody.append(pe)
    return txBody


def make_sp(sp_id, name, x, y, cx, cy, txBody_elem):
    """Crea un elemento <p:sp> con textbox."""
    P = 'http://schemas.openxmlformats.org/presentationml/2006/main'
    A = 'http://schemas.openxmlformats.org/drawingml/2006/main'

    sp = etree.Element(f'{{{P}}}sp')

    # nvSpPr
    nvSpPr = etree.SubElement(sp, f'{{{P}}}nvSpPr')
    cNvPr  = etree.SubElement(nvSpPr, f'{{{P}}}cNvPr')
    cNvPr.set('id', str(sp_id))
    cNvPr.set('name', name)
    cNvSpPr = etree.SubElement(nvSpPr, f'{{{P}}}cNvSpPr')
    cNvSpPr.set('txBox', '1')
    etree.SubElement(nvSpPr, f'{{{P}}}nvPr')

    # spPr
    spPr = etree.SubElement(sp, f'{{{P}}}spPr')
    xfrm  = etree.SubElement(spPr, f'{{{A}}}xfrm')
    off   = etree.SubElement(xfrm, f'{{{A}}}off')
    off.set('x', str(x)); off.set('y', str(y))
    ext   = etree.SubElement(xfrm, f'{{{A}}}ext')
    ext.set('cx', str(cx)); ext.set('cy', str(cy))
    prstGeom = etree.SubElement(spPr, f'{{{A}}}prstGeom')
    prstGeom.set('prst', 'rect')
    etree.SubElement(prstGeom, f'{{{A}}}avLst')
    etree.SubElement(spPr, f'{{{A}}}noFill')

    sp.append(txBody_elem)
    return sp


# ─────────────────────────────────────────────
# Construcción del XML de cada slide
# ─────────────────────────────────────────────

SLD_W = 12192000   # EMU
SLD_H = 6858000    # EMU

def base_slide_xml(bg_image_rId):
    """Crea la estructura base de un slide con fondo de imagen."""
    P  = 'http://schemas.openxmlformats.org/presentationml/2006/main'
    A  = 'http://schemas.openxmlformats.org/drawingml/2006/main'
    P14= 'http://schemas.microsoft.com/office/powerpoint/2010/main'

    sld = etree.Element(f'{{{P}}}sld',
        nsmap={'a': A, 'r': 'http://schemas.openxmlformats.org/officeDocument/2006/relationships',
               'p': P})

    cSld = etree.SubElement(sld, f'{{{P}}}cSld')

    # Background
    bg    = etree.SubElement(cSld, f'{{{P}}}bg')
    bgPr  = etree.SubElement(bg,   f'{{{P}}}bgPr')
    blipFill = etree.SubElement(bgPr, f'{{{A}}}blipFill')
    blipFill.set('dpi', '0')
    blipFill.set('rotWithShape', '1')
    blip = etree.SubElement(blipFill, f'{{{A}}}blip')
    blip.set('{http://schemas.openxmlformats.org/officeDocument/2006/relationships}embed', bg_image_rId)
    etree.SubElement(blip, f'{{{A}}}lum')
    etree.SubElement(blipFill, f'{{{A}}}srcRect')
    stretch = etree.SubElement(blipFill, f'{{{A}}}stretch')
    etree.SubElement(stretch, f'{{{A}}}fillRect')
    etree.SubElement(bgPr, f'{{{A}}}effectLst')

    # spTree
    spTree = etree.SubElement(cSld, f'{{{P}}}spTree')
    nvGrpSpPr = etree.SubElement(spTree, f'{{{P}}}nvGrpSpPr')
    cNvPr_g   = etree.SubElement(nvGrpSpPr, f'{{{P}}}cNvPr')
    cNvPr_g.set('id', '1'); cNvPr_g.set('name', '')
    etree.SubElement(nvGrpSpPr, f'{{{P}}}cNvGrpSpPr')
    etree.SubElement(nvGrpSpPr, f'{{{P}}}nvPr')
    grpSpPr = etree.SubElement(spTree, f'{{{P}}}grpSpPr')
    xfrm = etree.SubElement(grpSpPr, f'{{{A}}}xfrm')
    for tag, attrs in [('off',{'x':'0','y':'0'}),('ext',{'cx':'0','cy':'0'}),
                       ('chOff',{'x':'0','y':'0'}),('chExt',{'cx':'0','cy':'0'})]:
        el = etree.SubElement(xfrm, f'{{{A}}}{tag}')
        for k, v in attrs.items(): el.set(k, v)

    # extLst
    extLst = etree.SubElement(sld, f'{{{P}}}extLst')
    ext_el = etree.SubElement(extLst, f'{{{P}}}ext')
    ext_el.set('uri', '{BB962C8B-B14F-4D97-AF65-F5344CB8AC3E}')
    creationId = etree.SubElement(ext_el, f'{{{P14}}}creationId')
    creationId.set('val', '1234567890')

    # clrMapOvr
    clrMapOvr = etree.SubElement(sld, f'{{{P}}}clrMapOvr')
    etree.SubElement(clrMapOvr, f'{{{A}}}masterClrMapping')

    return sld, spTree


def rels_xml(layout_target, image_target):
    return (
        '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
        f'<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideLayout" Target="{layout_target}"/>'
        f'<Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="{image_target}"/>'
        '</Relationships>'
    )


# ─────────────────────────────────────────────
# Definición de cada diapositiva
# ─────────────────────────────────────────────

# image1.jpg = portada decorativa (slide 1)
# image2.jpg = portada con título y autores (slide 2)
# image3.jpg = diapositiva de contenido (slide 3)
# image4.jpg = diapositiva de cierre (slide 4)

# Colors
WHITE   = "FFFFFF"
YELLOW  = "FFD600"
LBLUE   = "B3E5FC"
LGRAY   = "F5F5F5"
DARKBG  = "1A1A2E"

# Fonts
F_TITLE  = "Roboto Condensed"
F_BODY   = "Bricolage Grotesque 18pt Conden"
F_LABEL  = "Roboto Condensed Light"

# ── Posiciones estándar para slides de contenido (image3.jpg) ──
# Etiqueta de sección (top-left pequeño)
LABEL_X, LABEL_Y, LABEL_CX, LABEL_CY = 896233, 563174, 4000000, 420000
# Título principal de la sección
TITLE_X, TITLE_Y, TITLE_CX, TITLE_CY = 896233, 980000, 10500000, 550000
# Divisor visual (línea ficticia via altura reducida)
CONT_X,  CONT_Y,  CONT_CX,  CONT_CY  = 896233, 1620000, 10500000, 4900000

# ── Slide 2: Portada ── (image2.jpg)
# Posiciones originales del template de portada
PORT_TITLE_X  = 3066068; PORT_TITLE_Y  = 1900000
PORT_TITLE_CX = 5900000; PORT_TITLE_CY = 1100000
PORT_SUB_X    = 3066068; PORT_SUB_Y    = 3100000
PORT_SUB_CX   = 5900000; PORT_SUB_CY   = 600000
PORT_AUTH_X   = 3246046; PORT_AUTH_Y   = 4200000
PORT_AUTH_CX  = 5699907; PORT_AUTH_CY  = 1100000
PORT_INST_X   = 3246046; PORT_INST_Y   = 5350000
PORT_INST_CX  = 5699907; PORT_INST_CY  = 700000

# ─────────────────────────────────────────────

def build_portada():
    """Slide 1 (decorativo) — solo imagen de fondo, sin texto."""
    sld, spTree = base_slide_xml('rId2')
    return sld

def build_cover():
    """Slide 2 — Portada con título, autores e institución."""
    sld, spTree = base_slide_xml('rId2')

    # Título de la ponencia
    title_paragraphs = [
        ("Aplicación Móvil Educativa Basada en", {'size': 2400, 'bold': True, 'color': WHITE,
                                                    'font': F_TITLE, 'align': 'ctr'}),
        ("Chatbot Conversacional y Reconocimiento de Imágenes", {'size': 2400, 'bold': True,
                                                    'color': YELLOW, 'font': F_TITLE, 'align': 'ctr'}),
        ("para la Enseñanza de Ciencias Naturales", {'size': 2400, 'bold': True, 'color': WHITE,
                                                    'font': F_TITLE, 'align': 'ctr'}),
    ]
    sp_title = make_sp(10, 'Titulo', PORT_TITLE_X, PORT_TITLE_Y, PORT_TITLE_CX, PORT_TITLE_CY,
                       make_txBody(title_paragraphs))
    spTree.append(sp_title)

    # Subtítulo/evento
    sub_paragraphs = [
        ("Ponencia — Evento Universitario Internacional", {'size': 1400, 'bold': False,
                                                           'color': LBLUE, 'font': F_BODY, 'align': 'ctr'}),
        ("Abril 2026", {'size': 1400, 'bold': False, 'color': LBLUE, 'font': F_BODY, 'align': 'ctr'}),
    ]
    sp_sub = make_sp(11, 'Subtitulo', PORT_SUB_X, PORT_SUB_Y, PORT_SUB_CX, PORT_SUB_CY,
                     make_txBody(sub_paragraphs))
    spTree.append(sp_sub)

    # Autores
    auth_paragraphs = [
        ("[Nombre Completo del Autor/a]", {'size': 1500, 'bold': True, 'color': WHITE,
                                            'font': F_BODY, 'align': 'ctr'}),
        ("Facultad de Ciencias de la Educación", {'size': 1200, 'bold': False, 'color': LBLUE,
                                                    'font': F_BODY, 'align': 'ctr'}),
    ]
    sp_auth = make_sp(12, 'Autores', PORT_AUTH_X, PORT_AUTH_Y, PORT_AUTH_CX, PORT_AUTH_CY,
                      make_txBody(auth_paragraphs))
    spTree.append(sp_auth)

    # Institución
    inst_paragraphs = [
        ("[Universidad / Institución]", {'size': 1200, 'bold': False, 'color': LBLUE,
                                          'font': F_BODY, 'align': 'ctr'}),
    ]
    sp_inst = make_sp(13, 'Institucion', PORT_INST_X, PORT_INST_Y, PORT_INST_CX, PORT_INST_CY,
                      make_txBody(inst_paragraphs))
    spTree.append(sp_inst)
    return sld


def build_content_slide(section_label, slide_title, bullets):
    """
    Slide de contenido con image3.jpg.
    bullets: lista de str o (str, dict) — soporta niveles con 'level' key.
    """
    sld, spTree = base_slide_xml('rId2')

    # Etiqueta de sección (top-left, pequeño)
    lbl = make_sp(5, 'Seccion', LABEL_X, LABEL_Y, LABEL_CX, LABEL_CY,
                  make_txBody([(section_label, {'size': 1400, 'bold': False, 'color': YELLOW,
                                                 'font': F_LABEL})]))
    spTree.append(lbl)

    # Título
    tit = make_sp(6, 'Titulo', TITLE_X, TITLE_Y, TITLE_CX, TITLE_CY,
                  make_txBody([(slide_title, {'size': 2800, 'bold': True, 'color': WHITE,
                                               'font': F_TITLE})]))
    spTree.append(tit)

    # Cuerpo de contenido
    content_paras = []
    for b in bullets:
        if isinstance(b, tuple):
            text, opts = b
        else:
            text, opts = b, {}

        lvl   = opts.get('level', 0)
        sz    = opts.get('size', 1600 if lvl == 0 else 1400)
        bd    = opts.get('bold', lvl == 0)
        clr   = opts.get('color', WHITE if lvl == 0 else LBLUE)
        font  = opts.get('font', F_BODY)
        bullet_char = "• " if lvl == 0 else "  – "
        content_paras.append((bullet_char + text, {'size': sz, 'bold': bd, 'color': clr,
                                                     'font': font, 'level': 0}))

    body = make_sp(7, 'Contenido', CONT_X, CONT_Y, CONT_CX, CONT_CY,
                   make_txBody(content_paras, font_size=1600, color_hex=WHITE, font_face=F_BODY))
    spTree.append(body)
    return sld


def build_two_column_slide(section_label, slide_title, col1_title, col1_items, col2_title, col2_items):
    """Slide con dos columnas de contenido."""
    sld, spTree = base_slide_xml('rId2')

    lbl = make_sp(5, 'Seccion', LABEL_X, LABEL_Y, LABEL_CX, LABEL_CY,
                  make_txBody([(section_label, {'size': 1400, 'bold': False, 'color': YELLOW,
                                                 'font': F_LABEL})]))
    spTree.append(lbl)

    tit = make_sp(6, 'Titulo', TITLE_X, TITLE_Y, TITLE_CX, TITLE_CY,
                  make_txBody([(slide_title, {'size': 2800, 'bold': True, 'color': WHITE,
                                               'font': F_TITLE})]))
    spTree.append(tit)

    # Columna izquierda
    col1_paras = [(col1_title, {'size': 1800, 'bold': True, 'color': YELLOW, 'font': F_TITLE})]
    for item in col1_items:
        col1_paras.append(("• " + item, {'size': 1500, 'bold': False, 'color': WHITE, 'font': F_BODY}))

    c1 = make_sp(7, 'Col1', CONT_X, CONT_Y, 4900000, CONT_CY,
                 make_txBody(col1_paras))
    spTree.append(c1)

    # Columna derecha
    col2_paras = [(col2_title, {'size': 1800, 'bold': True, 'color': YELLOW, 'font': F_TITLE})]
    for item in col2_items:
        col2_paras.append(("• " + item, {'size': 1500, 'bold': False, 'color': WHITE, 'font': F_BODY}))

    c2 = make_sp(8, 'Col2', CONT_X + 5300000, CONT_Y, 5100000, CONT_CY,
                 make_txBody(col2_paras))
    spTree.append(c2)
    return sld


def build_closing():
    """Diapositiva de cierre con image4.jpg."""
    sld, spTree = base_slide_xml('rId2')

    msg_paras = [
        ("¡Gracias!", {'size': 4400, 'bold': True, 'color': WHITE, 'font': F_TITLE, 'align': 'ctr'}),
        ("", {}),
        ("Preguntas y comentarios", {'size': 2000, 'bold': False, 'color': LBLUE, 'font': F_BODY, 'align': 'ctr'}),
        ("", {}),
        ("[correo@universidad.edu]", {'size': 1600, 'bold': False, 'color': YELLOW, 'font': F_BODY, 'align': 'ctr'}),
    ]
    sp = make_sp(5, 'Cierre', 1000000, 2000000, 10200000, 3000000,
                 make_txBody(msg_paras))
    spTree.append(sp)
    return sld


# ─────────────────────────────────────────────
# Definición de TODAS las diapositivas
# ─────────────────────────────────────────────

# (tipo, args)
SLIDES = [
    # 1. Portada decorativa (image1.jpg)
    ("portada_deco", None),

    # 2. Portada con título y autores (image2.jpg)
    ("cover", None),

    # 3. Agenda
    ("content", ("Estructura de la Presentación", "Agenda",
        ["Contexto y Problemática",
         "Objetivo de Investigación",
         "Marco Teórico: IA en Educación",
         "Arquitectura del Sistema",
         "Módulo Chatbot Conversacional",
         "Módulo Reconocimiento de Imágenes",
         "Funcionalidades Adicionales",
         "Prototipo Funcional",
         "Metodología de Evaluación",
         "Resultados Esperados y Conclusiones"])),

    # 4. Contexto y Problemática
    ("content", ("Contexto y Problemática", "¿Por qué esta investigación?",
        ["La educación secundaria enfrenta desafíos en la enseñanza de ciencias naturales",
         "Escasez de materiales interactivos y personalizados para biología celular",
         "Los estudiantes demandan experiencias de aprendizaje digitales e inmersivas",
         "La IA generativa ofrece oportunidades sin precedentes en educación",
         ("Los chatbots educativos mejoran la interacción y retroalimentación", {'level': 1}),
         ("El reconocimiento visual facilita el aprendizaje contextualizado", {'level': 1}),
         "Necesidad de herramientas que funcionen en entornos con conectividad variable"])),

    # 5. Objetivo
    ("content", ("Objetivo de Investigación", "Objetivo General",
        ["Diseñar y desarrollar una aplicación móvil educativa que integre:",
         ("Un chatbot conversacional con inyección de contexto curricular", {'level': 1}),
         ("Un sistema de reconocimiento de imágenes para estructuras biológicas", {'level': 1}),
         "Orientada a la enseñanza de biología celular en educación secundaria",
         "Evaluar la usabilidad y experiencia de usuario mediante estudio de caso",
         "Contribuir al diseño de soluciones móviles inteligentes centradas en el estudiante"])),

    # 6. Marco Teórico
    ("two_col", ("Marco Teórico", "Fundamentos Conceptuales",
        "IA en Educación",
        ["Tecnología Educativa y m-Learning",
         "Sistemas de Tutoría Inteligente (ITS)",
         "Modelos de Lenguaje Grande (LLM)",
         "Gamificación en contextos educativos",
         "Aprendizaje personalizado con IA"],
        "Reconocimiento Visual",
        ["Visión por Computador aplicada a educación",
         "Redes Neuronales Convolucionales (CNN)",
         "Transfer Learning con MobileNet V2",
         "Gemini Vision API para análisis multimodal",
         "Realidad Aumentada en educación STEM"])),

    # 7. Arquitectura del Sistema
    ("content", ("Arquitectura del Sistema", "Diseño Tecnológico",
        ["Flutter (Dart) — Framework multiplataforma Android/iOS",
         "Firebase Authentication — Autenticación con Google Sign-In",
         "Cloud Firestore — Base de datos en tiempo real",
         ("Perfiles de usuario, progreso, logros, sesiones de chat", {'level': 1}),
         "Groq API (llama-3.3-70b) — Generación de quizzes y chatbot",
         "Gemini Vision API — Reconocimiento de imágenes primario",
         "TFLite MobileNet V2 — Reconocimiento local (modo offline)",
         "Material 3 + Google Fonts (Poppins) — Diseño visual"])),

    # 8. Chatbot Conversacional
    ("content", ("Módulo IA", "Chatbot Conversacional",
        ["Basado en modelos de lenguaje de gran escala (LLM)",
         "Integración con Groq API — Modelo llama-3.3-70b-versatile",
         "Técnica clave: Inyección de Contexto Curricular (RAG simplificado)",
         ("El chatbot recibe el contenido del subtema activo como contexto", {'level': 1}),
         ("Respuestas limitadas a ciencias naturales (guardrails educativos)", {'level': 1}),
         "Soporte de voz: speech-to-text integrado en la interfaz",
         "Historial persistente de sesiones de chat en Firestore",
         "Sistema prompt diseñado para respetar el nivel educativo del estudiante"])),

    # 9. Reconocimiento de Imágenes
    ("content", ("Módulo IA", "Reconocimiento de Imágenes",
        ["Sistema multi-modelo con fallback automático",
         ("Primario: Gemini Vision API — Mayor precisión", {'level': 1, 'color': YELLOW}),
         ("Secundario: TFLite MobileNet V2 — Local/offline", {'level': 1, 'color': YELLOW}),
         ("Terciario: Groq API — Generación de descripciones", {'level': 1, 'color': YELLOW}),
         "Tipos detectados: animal, planta, insecto, hongo, objeto",
         "Información retornada por organismo identificado:",
         ("Nombre común y científico, descripción, hábitat, dato curioso", {'level': 1}),
         "Confianza del modelo expresada en porcentaje"])),

    # 10. Funcionalidades Adicionales
    ("two_col", ("Funcionalidades", "Componentes del Sistema",
        "Aprendizaje Interactivo",
        ["Guía de estudio: 4 subtemas de biología celular",
         "Contenido multimedia: texto, imágenes, videos",
         "Secciones '¿Sabías que?' para motivación",
         "Glosario interactivo con 5 categorías",
         "Realidad Aumentada (AR) con marcadores"],
        "Gamificación y Evaluación",
        ["Sistema de XP y niveles de progreso",
         "5 logros desbloqueables por hitos",
         "Racha de estudio diaria",
         "Quizzes generados por IA (3 niveles)",
         "Perfil con estadísticas de aprendizaje"])),

    # 11. Prototipo Funcional
    ("content", ("Estado Actual", "Prototipo Funcional",
        ["La aplicación cuenta con un prototipo funcional desarrollado en Flutter",
         "Plataforma objetivo: Android (probado en Infinix X6728)",
         "Módulos implementados y operativos:",
         ("Autenticación con Google y perfiles en Firestore", {'level': 1}),
         ("Guía de estudio con 4 subtemas y contenido curricular", {'level': 1}),
         ("Chatbot con contexto curricular y speech-to-text", {'level': 1}),
         ("Escáner de imágenes con pipeline multi-modelo", {'level': 1}),
         ("Sistema de gamificación: XP, logros, racha de estudio", {'level': 1}),
         ("Glosario, quizzes con IA y realidad aumentada", {'level': 1}),
         "Próxima fase: validación con estudiantes de educación secundaria"])),

    # 12. Metodología de Evaluación
    ("content", ("Metodología", "Evaluación y Validación",
        ["Diseño: Estudio de caso con estudiantes de educación secundaria",
         "Paradigma: Mixto (cuantitativo + cualitativo)",
         "Criterios de evaluación principales:",
         ("Usabilidad — Escala SUS (System Usability Scale)", {'level': 1}),
         ("Experiencia de usuario — Cuestionario UEQ", {'level': 1}),
         ("Aceptación tecnológica — Modelo TAM adaptado", {'level': 1}),
         ("Utilidad percibida e intención de uso", {'level': 1}),
         "Instrumentos: cuestionarios, entrevistas semiestructuradas, observación",
         "Análisis: estadística descriptiva + análisis de contenido cualitativo"])),

    # 13. Resultados Esperados
    ("two_col", ("Resultados y Aportes", "Proyecciones de la Investigación",
        "Resultados Esperados",
        ["Alta usabilidad percibida (SUS > 70)",
         "Actitud positiva hacia el uso de IA educativa",
         "Mejora de la motivación e interacción",
         "Aceptación del chatbot como apoyo pedagógico",
         "Validación del enfoque multi-modelo de IA"],
        "Contribuciones Científicas",
        ["Modelo de app educativa con IA dual",
         "Framework de inyección de contexto curricular",
         "Pipeline de reconocimiento visual offline-first",
         "Evidencia empírica de IA en m-learning",
         "Guía para diseño de apps educativas inteligentes"])),

    # 14. Conclusiones
    ("content", ("Conclusiones", "Reflexiones Finales y Trabajo Futuro",
        ["La integración de LLMs y visión por computador amplía las posibilidades del m-learning",
         "El chatbot con contexto curricular garantiza alineación pedagógica",
         "El enfoque multi-modelo asegura funcionalidad en conectividad variable",
         "La gamificación potencia la motivación y permanencia del estudiante",
         "Trabajo Futuro:",
         ("Ampliar contenidos a otras unidades del currículo de ciencias", {'level': 1}),
         ("Desarrollar funcionalidades offline completas", {'level': 1}),
         ("Evaluación longitudinal con grupos control y experimental", {'level': 1}),
         ("Publicar resultados en revistas de tecnología educativa", {'level': 1})])),

    # 15. Cierre
    ("closing", None),
]

# ─────────────────────────────────────────────
# Mapeo de image por tipo de slide
# ─────────────────────────────────────────────

IMAGE_MAP = {
    "portada_deco": "../media/image1.jpg",
    "cover":        "../media/image2.jpg",
    "content":      "../media/image3.jpg",
    "two_col":      "../media/image3.jpg",
    "closing":      "../media/image4.jpg",
}

LAYOUT_MAP = {
    "portada_deco": "../slideLayouts/slideLayout1.xml",
    "cover":        "../slideLayouts/slideLayout2.xml",
    "content":      "../slideLayouts/slideLayout2.xml",
    "two_col":      "../slideLayouts/slideLayout2.xml",
    "closing":      "../slideLayouts/slideLayout2.xml",
}

# ─────────────────────────────────────────────
# Ensamblado del PPTX
# ─────────────────────────────────────────────

def build_presentation():
    # 1. Copiar template como base
    shutil.copy2(TEMPLATE_PATH, OUTPUT_PATH)

    # 2. Leer todo el contenido del template
    with zipfile.ZipFile(TEMPLATE_PATH, 'r') as z:
        template_files = {name: z.read(name) for name in z.namelist()}

    # 3. Generar XMLs de slides
    slide_xmls  = []
    slide_rels  = []

    for idx, (stype, args) in enumerate(SLIDES):
        # Construir XML del slide
        if stype == "portada_deco":
            sld = build_portada()
        elif stype == "cover":
            sld = build_cover()
        elif stype == "content":
            sld = build_content_slide(*args)
        elif stype == "two_col":
            sld = build_two_column_slide(*args)
        elif stype == "closing":
            sld = build_closing()
        else:
            raise ValueError(f"Tipo desconocido: {stype}")

        xml_bytes = b'<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n' + \
                    etree.tostring(sld, xml_declaration=False, encoding='unicode').encode('utf-8')
        slide_xmls.append(xml_bytes)

        # Construir rels
        rel = rels_xml(LAYOUT_MAP[stype], IMAGE_MAP[stype]).encode('utf-8')
        slide_rels.append(rel)

    n = len(SLIDES)

    # 4. Construir presentation.xml actualizado con referencias a todos los slides
    prs_xml = template_files['ppt/presentation.xml'].decode('utf-8')

    # 5. Construir presentation.xml.rels actualizado
    prs_rels = template_files['ppt/_rels/presentation.xml.rels'].decode('utf-8')
    rels_root = etree.fromstring(prs_rels.encode('utf-8'))
    REL_NS = 'http://schemas.openxmlformats.org/package/2006/relationships'
    SLIDE_TYPE = 'http://schemas.openxmlformats.org/officeDocument/2006/relationships/slide'

    # Recolectar relaciones no-slide y sus IDs
    non_slide_entries = []
    used_ids = set()
    for rel in rels_root:
        if rel.get('Type', '') != SLIDE_TYPE:
            rid = rel.get('Id', '')
            non_slide_entries.append({
                'Id': rid,
                'Type': rel.get('Type', ''),
                'Target': rel.get('Target', ''),
            })
            used_ids.add(rid)

    # Asignar IDs a los nuevos slides que no colisionen (usar sS1, sS2 ...)
    slide_rids = [f'sldRId{i+1}' for i in range(n)]

    # Actualizar sldIdLst en presentation.xml para usar los nuevos IDs
    new_sldIdLst = '<p:sldIdLst>'
    for i, rid in enumerate(slide_rids):
        new_sldIdLst += f'<p:sldId id="{256+i}" r:id="{rid}"/>'
    new_sldIdLst += '</p:sldIdLst>'
    prs_xml = re.sub(r'<p:sldIdLst>.*?</p:sldIdLst>', new_sldIdLst, prs_xml, flags=re.DOTALL)

    # Reconstruir rels xml limpio (sin slides duplicados)
    new_prs_rels = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
    new_prs_rels += f'<Relationships xmlns="{REL_NS}">'
    for e in non_slide_entries:
        new_prs_rels += (f'<Relationship Id="{e["Id"]}" Type="{e["Type"]}" Target="{e["Target"]}"/>')
    for i, rid in enumerate(slide_rids):
        new_prs_rels += (f'<Relationship Id="{rid}" Type="{SLIDE_TYPE}" '
                         f'Target="slides/slide{i+1}.xml"/>')
    new_prs_rels += '</Relationships>'

    # 6. Escribir nuevo PPTX
    with zipfile.ZipFile(OUTPUT_PATH, 'w', zipfile.ZIP_DEFLATED) as zout:
        for name, data in template_files.items():
            # Saltar slides existentes y sus rels
            if re.match(r'ppt/slides/slide\d+\.xml$', name):
                continue
            if re.match(r'ppt/slides/_rels/slide\d+\.xml\.rels$', name):
                continue

            if name == 'ppt/presentation.xml':
                zout.writestr(name, prs_xml.encode('utf-8'))
            elif name == 'ppt/_rels/presentation.xml.rels':
                zout.writestr(name, new_prs_rels.encode('utf-8'))
            elif name == '[Content_Types].xml':
                # Actualizar Content_Types para incluir todos los slides
                ct_xml = data.decode('utf-8')
                # Eliminar entradas de slides existentes
                ct_xml = re.sub(
                    r'<Override PartName="/ppt/slides/slide\d+\.xml"[^>]*/>', '', ct_xml)
                # Insertar nuevas entradas antes de </Types>
                new_entries = ''
                SLIDE_CT = 'application/vnd.openxmlformats-officedocument.presentationml.slide+xml'
                for i in range(n):
                    new_entries += (f'<Override PartName="/ppt/slides/slide{i+1}.xml" '
                                    f'ContentType="{SLIDE_CT}"/>')
                ct_xml = ct_xml.replace('</Types>', new_entries + '</Types>')
                zout.writestr(name, ct_xml.encode('utf-8'))
            else:
                zout.writestr(name, data)

        # Escribir nuevos slides y rels
        for i, (xml_bytes, rel_bytes) in enumerate(zip(slide_xmls, slide_rels)):
            zout.writestr(f'ppt/slides/slide{i+1}.xml', xml_bytes)
            zout.writestr(f'ppt/slides/_rels/slide{i+1}.xml.rels', rel_bytes)

    print(f"[OK] Presentación generada: {OUTPUT_PATH}")
    print(f"     Total diapositivas: {n}")

if __name__ == '__main__':
    build_presentation()
