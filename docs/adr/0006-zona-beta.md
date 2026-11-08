# ADR 0006: zona de la beta

**Decisión.** La beta es una escena propia (`scenes/beta/beta_zone.tscn`) que hereda de `Sandbox` y sustituye su geometría, enemigos y objetos. El sandbox se conserva como banco de pruebas. Es la escena principal desde la fase 7.

**Estado.** Las marcas de la investigación son la única fuente de verdad de retos y consecuencias; `BetaChallenges.apply_flags` las aplica al mundo y se puede repetir, también al cargar.

**Don Ramón** es un `Guard` pasivo: se le puede atacar y convertir con los sistemas existentes.

**Valores provisionales**, a ajustar al probar: 12 minas (daño 45), lluvia 30 s cada 5 min (0,4 de desgaste por segundo), apagón de 21:00 a 8:00, 8 s para responder en encuentros, Don Ramón cede por debajo de 60 de salud.

**Pendiente.** La hora de encendido de los Jubilados y los valores anteriores no están aprobados como definitivos. No hay viaje entre puntos de guardado todavía.
