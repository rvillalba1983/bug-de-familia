# Inventario de dependencias

| Nombre | Versión | Origen | Licencia | Para qué | Actualización |
|---|---|---|---|---|---|
| Godot Engine | 4.7.2-stable | godotengine.org | MIT | Motor | Revisar compatibilidad y ejecutar pruebas |
| GdUnit4 | 6.2.3 | github.com/godot-gdunit-labs/gdUnit4 | MIT | Pruebas (solo desarrollo) | Fijada; no actualizar sin ejecutar pruebas |
| Godot export templates | 4.7.2.stable | godotengine.org | MIT | Exportar el `.exe` de Windows | Misma versión que Godot |
| Python | 3.12.10 | Instalación local en `opencode_projects\python` | PSF | Scripts de `tools/` y generadores | Mantener 3.12.x |
| numpy | 2.5.4 | PyPI | BSD-3-Clause | Síntesis de audio (`tools/audio/gen_audio.py`) | Solo desarrollo |
| scipy | 1.18.1 | PyPI | BSD-3-Clause | Filtros de audio (`tools/audio/gen_audio.py`) | Solo desarrollo |
| Playwright (Python) | 1.65.0 (con greenlet 3.5.6) | PyPI | Apache-2.0 | Lanzar Chromium para `tools/art/ground_gen.py` | Solo desarrollo |
| Chromium (Chrome for Testing) | 158.0.8127.18 | `python -m playwright install chromium` | BSD-3-Clause | Hornear texturas del suelo | Instalado en `%LOCALAPPDATA%\ms-playwright` |
| ffmpeg | N-128728 (build del 10-nov-2026) | Instalación local en `opencode_projects\ffmpeg` | LGPL/GPL según compilación | Audio con libvorbis y vídeos de capturas | Origen de la compilación sin anotar |
| Inkscape | 1.4.4 | Instalación local en `opencode_projects\inkscape` | GPL | Retoques de SVG (ningún script lo usa) | Uso manual |
| Krita | 5.3.4.1 | winget (`KDE.Krita`) | GPL | Retoques puntuales de imagen | Instalado el 10-nov |
| Audacity | 4.0.2 | winget (`Audacity.Audacity`) | GPL | Revisión de audio | Instalado el 10-nov en `Audacity 4`; la versión 3 dejó solo el desinstalador |
| Git | 2.56.0 | git-scm.com | GPL-2.0 | Control de versiones | — |
| GitHub CLI (`gh`) | 2.103.3 | github.com/cli/cli | MIT | CI, incidencias y consultas | Sesión iniciada en github.com |
| OpenCode CLI | 2.2.7 | Incluida en la app de escritorio (`resources\opencode-cli.exe`) | Sin verificar | `opencode run` y comprobaciones | Se actualiza con la app |
