# Tarea: Ampliar Cobertura de Pruebas

## 📋 Información General

- **Tarea ID**: TAREA-001
- **Prioridad**: Media
- **Complejidad**: Media
- **Tiempo estimado**: 2-3 días
- **Rama**: `feature/opencode-free-models-test`

## 🎯 Objetivo

Ampliar la cobertura de pruebas para sistemas que actualmente no tienen suficientes tests, especialmente:
1. Sistema de IAs (20 IAs)
2. Sistema de simulación
3. Sistema de investigación

## 📊 Estado Actual

- **Pruebas existentes**: 100+ pruebas
- **Cobertura actual**: ~60%
- **Objetivo**: ~80% de cobertura

## 🤖 Agentes Involucrados

### 1. QA (opencode/deepseek-v4.1-flash)
- **Rol**: Diseñar pruebas
- **Tareas**:
  - Identificar sistemas sin cobertura
  - Diseñar casos de prueba
  - Definir edge cases
  - Crear checklist de validación

### 2. Ingeniero Godot (opencode/glm-5.3-flash)
- **Rol**: Implementar pruebas
- **Tareas**:
  - Implementar tests en GDScript
  - Seguir convenio `tests/<sistema>/<nombre>_test.gd`
  - Usar `TestSupport.reset_session()` para semilla (1234)
  - Verificar que pruebas pasan

### 3. Documentación (opencode/minimax-m3.1-flash-free)
- **Rol**: Documentar
- **Tareas**:
  - Crear ADR para la tarea
  - Actualizar documentación de pruebas
  - Registrar decisiones tomadas

## 📝 Pasos a Seguir

### Fase 1: Análisis (QA)
1. Revisar sistemas existentes
2. Identificar gaps de cobertura
3. Diseñar casos de prueba
4. Crear checklist de validación

### Fase 2: Implementación (Ingeniero Godot)
1. Crear archivos de test
2. Implementar pruebas
3. Ejecutar pruebas
4. Verificar que pasan

### Fase 3: Documentación (Documentación)
1. Crear ADR
2. Actualizar docs/02_DECISIONES.md
3. Registrar en docs/03_ESTADO.md

### Fase 4: Validación (QA)
1. Revisar pruebas implementadas
2. Verificar edge cases
3. Confirmar cobertura

## 🔍 Sistemas a Probar

### 1. Sistema de IAs
**Archivos**:
- `ai/ai_system.gd`
- `ai/ai_perks.gd`
- `ai/ai_behavior.gd`

**Pruebas necesarias**:
- Percepción de IAs
- Comportamiento emergente
- Interacción entre IAs
- Balance de perks

### 2. Sistema de Simulación
**Archivos**:
- `simulation/character.gd`
- `simulation/world_simulation.gd`
- `simulation/time_system.gd`

**Pruebas necesarias**:
- Ciclo de vida de personajes
- Simulación de mundo
- Sistema de tiempo

### 3. Sistema de Investigación
**Archivos**:
- `investigation/conversation_engine.gd`
- `investigation/knowledge_system.gd`
- `investigation/evidence_system.gd`

**Pruebas necesarias**:
- Motor de conversaciones
- Sistema de conocimiento
- Sistema de evidencias

## ✅ Criterios de Aceptación

1. ✅ Pruebas implementadas siguiendo convenio
2. ✅ Todas las pruebas pasan
3. ✅ Cobertura aumentada en al menos 10%
4. ✅ Documentación actualizada
5. ✅ ADR creado

## 📊 Métricas de Éxito

- **Pruebas nuevas**: Mínimo 20
- **Cobertura**: De ~60% a ~70%
- **Tiempo**: 2-3 días
- **Agentes usados**: 3 (QA, ingeniero, documentación)

## ⚠️ Restricciones

- **NO se mergea a main sin aprobación**
- **Trabajar solo en rama de prueba**
- **No modificar código existente sin aprobación**
- **Documentar todas las decisiones**

## 🔄 Flujo de Trabajo

1. **QA**: Diseña pruebas → Propone solución
2. **Tú (director)**: Revisas y apruebas
3. **Ingeniero Godot**: Implementa pruebas
4. **QA**: Verifica que pasan
5. **Documentación**: Documenta en ADR
6. **Tú (director)**: Apruebas fusión a main

## 📝 Notas

- Usar `TestSupport.reset_session()` para aislar estado
- Fijar semilla (1234) para reproducibilidad
- Seguir normas de código (docs/35_normas_codigo.md)
- No desactivar pruebas existentes

---

## 🚀 Próximo Paso

**¿Quieres que empecemos con la Fase 1 (Análisis por QA)?**

Si es así, puedo:
1. Invocar al agente `qa` para diseñar las pruebas
2. El agente `qa` propondrá qué sistemas probar y qué casos de prueba crear
3. Tú revisas y apruebas la propuesta
4. Continuamos con la implementación

**¿Procedemos?** 🤠