# Guía de Fallback para Modelos de Agentes

## 📋 Propósito

Este documento sirve como guía de referencia para cuando un modelo se queda sin fondos (insufficient account funds). Cada agente tiene una lista de modelos alternativos que se pueden usar.

## 🔄 Procedimiento de Fallback

Cuando un agente falla por falta de fondos:

1. **Identificar el modelo que falló**
2. **Consultar la lista de alternativas** en este documento
3. **Cambiar el modelo** en `opencode.jsonc`
4. **Documentar el cambio** en un ADR
5. **Informar al director** del cambio

## 📊 Tabla de Fallback por Agente

### 1. Arquitecto (opencode/glm-5.3-flash)

| Prioridad | Modelo | Proveedor | Costo | Notas |
|-----------|--------|-----------|-------|-------|
| 1 (actual) | `opencode/glm-5.3-flash` | OpenCode | Gratis | Modelo principal |
| 2 | `opencode/claude-haiku-5-5` | OpenCode | Gratis | Backup rápido |
| 3 | `opencode/beam-free` | OpenCode | Gratis | Backup alternativo |
| 4 | `opencode/mimo-v2.6-flash-free` | OpenCode | Gratis | Backup alternativo |
| 5 | `cloudflare-workers-ai/@cf/zai-org/glm-5.3` | Cloudflare | $1.4/$4.4 | Backup de pago |

### 2. Ingeniero Godot (opencode/glm-5.3-flash)

| Prioridad | Modelo | Proveedor | Costo | Notas |
|-----------|--------|-----------|-------|-------|
| 1 (actual) | `opencode/glm-5.3-flash` | OpenCode | Gratis | Modelo principal |
| 2 | `opencode/claude-haiku-5-5` | OpenCode | Gratis | Backup rápido |
| 3 | `opencode/beam-free` | OpenCode | Gratis | Backup alternativo |
| 4 | `opencode/mimo-v2.6-flash-free` | OpenCode | Gratis | Backup alternativo |
| 5 | `cloudflare-workers-ai/@cf/zai-org/glm-5.3` | Cloudflare | $1.4/$4.4 | Backup de pago |

### 3. Gameplay (opencode/minimax-m3.1-flash-free)

| Prioridad | Modelo | Proveedor | Costo | Notas |
|-----------|--------|-----------|-------|-------|
| 1 (actual) | `opencode/minimax-m3.1-flash-free` | OpenCode | Gratis | Modelo principal |
| 2 | `opencode/claude-haiku-5-5` | OpenCode | Gratis | Backup rápido |
| 3 | `opencode/beam-free` | OpenCode | Gratis | Backup alternativo |
| 4 | `opencode/mimo-v2.6-flash-free` | OpenCode | Gratis | Backup alternativo |
| 5 | `openrouter/minimax/minimax-m3.1-flash` | OpenRouter | Variable | Backup de pago |

### 4. QA (opencode/claude-haiku-5-5)

| Prioridad | Modelo | Proveedor | Costo | Notas |
|-----------|--------|-----------|-------|-------|
| 1 (actual) | `opencode/claude-haiku-5-5` | OpenCode | Gratis | Modelo principal (cambiado de deepseek) |
| 2 | `opencode/beam-free` | OpenCode | Gratis | Backup rápido |
| 3 | `opencode/mimo-v2.6-flash-free` | OpenCode | Gratis | Backup alternativo |
| 4 | `opencode/gpt-5.4-mini` | OpenCode | Gratis | Backup alternativo |
| 5 | `cloudflare-workers-ai/@cf/deepseek-ai/deepseek-v4.1-flash-1017` | Cloudflare | $0.3/$1.2 | Backup de pago |

### 5. Documentación (opencode/minimax-m3.1-flash-free)

| Prioridad | Modelo | Proveedor | Costo | Notas |
|-----------|--------|-----------|-------|-------|
| 1 (actual) | `opencode/minimax-m3.1-flash-free` | OpenCode | Gratis | Modelo principal |
| 2 | `opencode/claude-haiku-5-5` | OpenCode | Gratis | Backup rápido |
| 3 | `opencode/beam-free` | OpenCode | Gratis | Backup alternativo |
| 4 | `opencode/mimo-v2.6-flash-free` | OpenCode | Gratis | Backup alternativo |
| 5 | `openrouter/minimax/minimax-m3.1-flash` | OpenRouter | Variable | Backup de pago |

## 🔧 Procedimiento de Cambio

### Paso 1: Identificar el modelo que falló
Revisa el error del agente para identificar qué modelo se quedó sin fondos.

### Paso 2: Consultar la tabla de fallback
Busca el agente en la tabla anterior y selecciona el siguiente modelo disponible.

### Paso 3: Actualizar opencode.jsonc
Edita el archivo `opencode.jsonc` y cambia el modelo del agente afectado.

### Paso 4: Documentar el cambio
Crea un ADR en `docs/adr/` documentando:
- Qué modelo falló
- Qué modelo se usó como alternativa
- Fecha del cambio
- Razón del cambio

### Paso 5: Informar al director
Notifica al director del proyecto sobre el cambio realizado.

## 📝 Ejemplo de ADR

```markdown
# ADR-0018: Cambio de modelo para agente QA

## Estado
Aprobado

## Fecha
2026-11-10

## Contexto
El modelo `opencode/deepseek-v4.1-flash` se quedó sin fondos.

## Decisión
Se cambió el modelo del agente QA a `opencode/claude-haiku-5-5`.

## Consecuencias
- El agente QA ahora usa un modelo diferente
- Se mantiene la funcionalidad del agente
- Se documenta el cambio para futuras referencias

## Alternativas consideradas
- `opencode/beam-free`
- `opencode/mimo-v2.6-flash-free`
- `cloudflare-workers-ai/@cf/deepseek-ai/deepseek-v4.1-flash-1017`
```

## ⚠️ Notas Importantes

1. **No se mergea a main** sin aprobación del director
2. **Documentar todos los cambios** en ADRs
3. **Informar al director** de cada cambio
4. **Probar el nuevo modelo** antes de continuar

## 🔄 Actualización de la Tabla

Esta tabla debe actualizarse cuando:
- Se añadan nuevos modelos disponibles
- Se cambien los modelos principales
- Se descubran nuevos modelos gratuitos

Última actualización: 2026-11-10