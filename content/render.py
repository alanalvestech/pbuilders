#!/usr/bin/env python3
"""
Converte img.html de uma pasta de conteúdo em img.png.
Uso: python3 content/render.py content/2026-04-01-sequoia-services
"""
import sys
from pathlib import Path
from playwright.sync_api import sync_playwright

folder_arg = sys.argv[1] if len(sys.argv) > 1 else None
if not folder_arg:
    print("Uso: python3 content/render.py <pasta>")
    print("Exemplo: python3 content/render.py content/2026-04-01-sequoia-services")
    sys.exit(1)

folder = Path(folder_arg)
html = folder / "img.html"
png  = folder / "img.png"

if not html.exists():
    print(f"Arquivo não encontrado: {html}")
    sys.exit(1)

with sync_playwright() as p:
    browser = p.chromium.launch()
    page = browser.new_page(viewport={"width": 1080, "height": 1080})
    page.goto(f"file://{html.resolve()}")
    page.screenshot(path=str(png), full_page=False)
    browser.close()

print(f"Imagem salva: {png}")
