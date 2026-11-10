# Próximos Pasos de Desarrollo - Bug de Familia

## Estado Actual del Proyecto

### 📊 Fase Actual
Según `docs/03_ESTADO.md`:
- **Fase 1**: Implementación básica completada
- **Fase 2**: Mecánicas de sigilo y combate en desarrollo
- **Fase 3**: Sistema de investigación y conversaciones en desarrollo
- **Fase 4**: Zonas y mundo en desarrollo

### 🎯 Tareas Pendientes Prioritarias

#### 1. **Sistema de IAs (20 IAs implementadas)**
- **Estado**: 20 IAs creadas, falta integración completa
- **Tarea**: Implementar comportamiento emergente entre IAs
- **Agente sugerido**: `gameplay` + `ingeniero-godot`

#### 2. **Sistema de Investigación**
- **Estado**: Motor de conversaciones offline implementado
- **Tarea**: Integrar con sistema de conocimiento
- **Agente sugerido**: `arquitecto` + `gameplay`

#### 3. **Zonas y Contenido**
- **Estado**: Zonas fijas definidas, contenido variable en desarrollo
- **Tarea**: Implementar persistencia de zonas
- **Agente sugerido**: `ingeniero-godot`

#### 4. **Pruebas y QA**
- **Estado**: 100+ pruebas implementadas
- **Tarea**: Ampliar cobertura de pruebas
- **Agente sugerido**: `qa`

#### 5. **Documentación**
- **Estado**: ADRs y specs en desarrollo
- **Tarea**: Completar ADRs pendientes
- **Agente sugerido**: `documentacion`

---

## 📋 Tareas para Probar Agentes (Prioritarias)

### Tarea 1: **Implementar comportamiento de IAs**
**Descripción**: Crear un sistema donde las 20 IAs interactúen entre sí de forma emergente.
**Archivos afectados**:
- `ai/ai_system.gd`
- `simulation/character.gd`
- `tests/ai/ai_perks_test.gd`

**Agentes involucrados**:
- `arquitecto`: Diseño de arquitectura
- `gameplay`: Mecánicas de IA
- `ingeniero-godot`: Implementación
- `qa`: Pruebas

**Complejidad**: Media-Alta
**Tiempo estimado**: 2-3 días

---

### Tarea 2: **Sistema de persistencia de zonas**
**Descripción**: Implementar guardado/carga de estado de zonas.
**Archivos afectados**:
- `scenes/beta/beta_zone.tscn`
- `core/save_system.gd`
- `data/zones/*.json`

**Agentes involucrados**:
- `arquitecto`: Diseño de persistencia
- `ingeniero-godot`: Implementación
- `qa`: Pruebas de carga/guardado

**Complejidad**: Media
**Tiempo estimado**: 1-2 días

---

### Tarea 3: **Integración de motor de conversaciones**
**Descripción**: Conectar el motor de conversaciones con el sistema de investigación.
**Archivos afectados**:
- `investigation/conversation_engine.gd`
- `investigation/knowledge_system.gd`
- `ui/dialogue_ui.gd`

**Agentes involucrados**:
- `arquitecto`: Integración de sistemas
- `gameplay`: Mecánicas de conversación
- `ingeniero-godot`: Implementación
- `documentacion`: Documentación

**Complejidad**: Alta
**Tiempo estimado**: 3-4 días

---

### Tarea 4: **Ampliar cobertura de pruebas**
**Descripción**: Crear pruebas para sistemas no cubiertos.
**Archivos afectados**:
- `tests/ai/*.gd`
- `tests/simulation/*.gd`
- `tests/investigation/*.gd`

**Agentes involucrados**:
- `qa`: Diseño de pruebas
- `ingeniero-godot`: Implementación de tests

**Complejidad**: Media
**Tiempo estimado**: 2-3 días

---

### Tarea 5: **Completar ADRs pendientes**
**Descripción**: Documentar decisiones técnicas pendientes.
**Archivos afectados**:
- `docs/adr/*.md`
- `docs/02_DECISIONES.md`

**Agentes involucrados**:
- `documentacion`: Redacción
- `arquitecto`: Validación técnica

**Complejidad**: Baja-Media
**Tiempo estimado**: 1-2 días

---

## 🎮 Recomendación para Primera Prueba

Para probar los agentes con modelos gratuitos, recomiendo empezar con:

### **Tarea 4: Ampliar cobertura de pruebas**
**Razones**:
1. ✅ **Bajo riesgo**: No afecta código existente
2. ✅ **Verificable**: Se puede comprobar fácilmente si funciona
3. ✅ **Aislado**: No requiere cambios en sistemas complejos
4. ✅ **Documentable**: Fácil de registrar en ADR
5. ✅ **Prueba múltiples agentes**: QA + ingeniero-godot

**Pasos**:
1. `qa`: Diseñar pruebas para sistema de IAs
2. `ingeniero-godot`: Implementar pruebas
3. `qa`: Verificar que pruebas pasan
4. `documentacion`: Documentar en ADR

---

## 📝 Notas Importantes

### ⚠️ Restricciones
- **NO se mergea nada a main sin tu permiso explícito**
- **Trabajar siempre en rama de prueba**
- **Probar agentes con modelos gratuitos**
- **Documentar todo en ADRs**

### ✅ Validaciones Requeridas
1. Cada cambio debe ser probado
2. Cada decisión debe estar documentada
3. Cada agente debe validar su trabajo
4. Tú (director) apruebas cada fusión

### 🔄 Flujo de Trabajo
1. Crear rama de prueba
2. Asignar tarea a agente
3. Agente propone solución
4. Tú revisas y apruebas
5. Agente implementa
6. QA verifica
7. Tú apruebas fusión a main

---

## 🚀 Próximo Paso Inmediato

**¿Quieres que empecemos con Tarea 4 (Ampliar cobertura de pruebas)?**

Si es así, puedo:
1. Crear la rama de prueba
2. Asignar la tarea a `qa` para diseño de pruebas
3. Asignar a `ingeniero-godot` para implementación
4. Documentar todo en un ADR

**¿Procedemos?** 🤠