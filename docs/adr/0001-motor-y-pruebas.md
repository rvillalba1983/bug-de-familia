# ADR 0001: versión del motor y marco de pruebas

Fecha: 2026-11-08 · Estado: aceptada

## Decisión
- **Godot 4.7.2 estable**, la última versión estable publicada en la fecha de la decisión. Suma de comprobación SHA-512 verificada contra la publicación oficial.
- **Renderizador Compatibility (OpenGL)**: el juego es 2D y así funciona en más equipos, incluidas gráficas integradas.
- **GdUnit4 6.2.3** para pruebas. Su documentación lista compatibilidad hasta Godot 4.7.1; se ha comprobado ejecutándolo en 4.7.2.
- Identificadores de código en inglés y textos del juego en español, separados del código.

## Consecuencias
No se cambia de versión principal del motor sin revisar compatibilidad y ejecutar las pruebas.
