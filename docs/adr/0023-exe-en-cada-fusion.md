# ADR 0023: generar el `.exe` en cada fusión a `main` (10-nov)

Estado: decidido por el director el 10-nov-2026.

## Contexto
El flujo vigente (`AGENTS.md`, `CLAUDE.md`) exige, al fusionar una fase en `main`:
actualizar `docs/03_ESTADO.md` y avisar de que hay que cambiar de conversación. La
exportación local del `.exe` de Windows estaba verificada (`HERRAMIENTAS.md` §5 y
`docs/03_ESTADO.md`), pero no formaba parte del cierre de fase, así que el binario de
`build/` podía quedarse desactualizado respecto a `main`.

## Decisión
Cada vez que se vaya a fusionar en `main` (siempre con aprobación del director) se genera
también el `.exe` de Windows en `build/`, con el preset «Windows»:

```
cmd /c "C:\Users\usuario\opencode_projects\godot\Godot_v4.7.2-stable_win64_console.exe --headless --export-release Windows build/bug_de_familia.exe < NUL"
```

En PowerShell con `cmd /c`, el preset va sin comillas internas (con `"Windows"` se
pierden y Godot recibe `.`). Es una operación local: `build/` no va a git, no se sube
nada a servicios externos y no sustituye al workflow `exportar.yml` de CI, que sigue
exportando al fusionar.

## Procedimiento de fusión (10-nov)
El director añadió el mismo día: **siempre por rama y Pull Request**, nunca una fusión
directa en local. `merge --ff-only` queda solo para el caso excepcional autorizado.
Secuencia: rama de fase → commit → push de la rama → PR → CI verde → aprobación del
director → fusión. Como crear el PR implica subir la rama a GitHub, `git push` y la
apertura del PR se confirman con el director en el momento (`AGENTS.md`: no subir
código ni recursos a servicios externos sin autorización). El `.exe` y la actualización
de `03_ESTADO.md` se preparan **antes de pedir la fusión del PR**, no después.

## Consecuencias
- El cierre de fase pasa a tener, antes de pedir la fusión del PR: exportar el `.exe`,
  actualizar `docs/03_ESTADO.md` y dejar el CI verde. Tras la fusión aprobada se avisa
  del cambio de conversación.
- Regla reflejada en `AGENTS.md`, `CLAUDE.md`, `HERRAMIENTAS.md`,
  `docs/02_DECISIONES.md` y `docs/03_ESTADO.md`.
- Se corrige `HERRAMIENTAS.md` §11, que listaba la exportación como «sin ejecutar» pese
  a estar verificada el 10-nov.
- Requiere las plantillas de exportación 4.7.2 instaladas (comprobado en este clon).
- **No ejecutado aún en esta fase**: no hay fusión aprobada. La regla se aplicará cuando
  el director apruebe la fusión.
