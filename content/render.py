#!/usr/bin/env python3
"""
Converte HTML com slides .slide em PNG(s).

Uso:
  python3 content/render.py <arquivo.html>

  - 1 slide  → <nome>.png
  - N slides → <nome>-01.png, <nome>-02.png, ...
  - Sem .slide → screenshot da página inteira

Exemplos:
  python3 content/render.py content/2026-04-01-sequoia-services/img.html
  python3 content/render.py content/2026-04-01-sequoia-services/instagram-carousel.html
  python3 content/render.py content/2026-04-01-sequoia-services/instagram-stories.html
"""
import sys
from pathlib import Path
from playwright.sync_api import sync_playwright

html_arg = sys.argv[1] if len(sys.argv) > 1 else None
if not html_arg:
    print("Uso: python3 content/render.py <arquivo.html>")
    print("Exemplos:")
    print("  python3 content/render.py content/2026-04-01-sequoia-services/img.html")
    print("  python3 content/render.py content/2026-04-01-sequoia-services/instagram-carousel.html")
    sys.exit(1)

html = Path(html_arg)
if not html.exists():
    print(f"Arquivo não encontrado: {html}")
    sys.exit(1)

stem   = html.stem
folder = html.parent

with sync_playwright() as p:
    browser = p.chromium.launch()
    page = browser.new_page(viewport={"width": 1080, "height": 1920})
    page.goto(f"file://{html.resolve()}")
    page.wait_for_load_state("networkidle")

    slides = page.query_selector_all(".slide")

    if len(slides) == 0:
        png = folder / f"{stem}.png"
        page.screenshot(path=str(png), full_page=False)
        print(f"Imagem salva: {png}")
    elif len(slides) == 1:
        png = folder / f"{stem}.png"
        slides[0].screenshot(path=str(png))
        print(f"Imagem salva: {png}")
    else:
        for i, slide in enumerate(slides, 1):
            png = folder / f"{stem}-{i:02d}.png"
            slide.screenshot(path=str(png))
            print(f"Imagem salva: {png}")

    browser.close()
