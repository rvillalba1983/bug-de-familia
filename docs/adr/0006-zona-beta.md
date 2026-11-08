# ADR 0006: zona de la beta

**Decisión.** La beta es una escena propia (`scenes/beta/beta_zone.tscn`) que hereda de `Sandbox` y sustituye su geometría, enemigos y objetos. El sandbox se conserva como banco de pruebas. Es la escena principal desde la fase 7.

**Estado.** Las marcas de la investigación son la única fuente de verdad de retos y consecuencias; `BetaChallenges.apply_flags` las aplica al mundo y se puede repetir, también al cargar.

**Don Ramón** es un `Guard` pasivo: se le puede atacar y convertir con los sistemas existentes.

**Valores provisionales**, a ajustar al probar: 12 minas (daño 45), lluvia de 30 s a intervalos irregulares de 2 a 8 min (0,4 de desgaste por segundo), de 5 a 10 s al azar para responder en encuentros, Don Ramón cede por debajo de 30 de salud.

**Pendiente.** Los valores anteriores no están aprobados como definitivos. No hay viaje entre puntos de guardado todavía.
