# ADR 0021: herramientas del proyecto al iniciar cada sesión

Estado: fusionado en `main` el 10-nov, con aprobación del director.

## Problema

Cada sesión nueva tenía que redescubrir las herramientas del proyecto. Godot, Python,
ffmpeg e Inkscape están en el PATH del usuario, pero una sesión de OpenCode no ve los
cambios de PATH posteriores a su arranque. Faltaba Playwright para
`tools/art/ground_gen.py`, `docs/DEPENDENCIAS.md` solo registraba Godot y GdUnit4, y
`AGENTS.md` describía un Godot sin extraer que ya no era cierto.

## Decisión

1. `HERRAMIENTAS.md` (raíz) reúne rutas, versiones, comandos probados y limitaciones.
2. `opencode.jsonc` lo declara en `instructions`. OpenCode lo carga al empezar cada
   sesión, junto a `AGENTS.md` (documentación V2, *Instructions*).
3. `AGENTS.md` y `CLAUDE.md` lo citan, para que Claude Code lo lea también.
4. `docs/DEPENDENCIAS.md` registra cada dependencia instalada con versión, origen y
   licencia.
5. Instalaciones del 10-nov: Playwright 1.65.0 con Chromium 158.0.8127.18 (pip y
   `playwright install`); Krita 5.3.4.1 y Audacity 4.0.2 con winget. La CLI de OpenCode
   2.2.7 ya venía con la aplicación de escritorio; se expone con el atajo
   `opencode_projects\opencode\opencode.cmd`, añadido al PATH del usuario.

## Consecuencias

- Cada sesión carga el archivo completo: debe mantenerse breve.
- Quien cambie una herramienta, una ruta o un comando actualiza `HERRAMIENTAS.md` en el
  mismo cambio.
- La instrucción vive en el proyecto y no afecta a otros proyectos del usuario. Llevarla
  a la configuración global exige una decisión aparte.

## Alternativas consideradas

- Solo `AGENTS.md`: descartado. Obliga a cada sesión a decidir si lee más archivos.
- Configuración global (`~/.config/opencode/opencode.json`): descartado por ahora.
  Afectaría a todos los proyectos y necesita aprobación del director.
- Skill propia: descartada. Una skill se carga cuando encaja con la tarea; aquí se quiere
  lectura en cada sesión.
