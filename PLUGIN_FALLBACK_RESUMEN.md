# Plugin de Fallback Automático - Resumen

## ✅ Implementado

### Plugin: `model-fallback`
- **Ubicación**: `.opencode/plugins/model-fallback/index.ts`
- **ID**: `model-fallback`
- **Estado**: Cargado y funcionando

### Herramientas disponibles:
1. `mark_model_failed(model: string)` - Marca un modelo como sin fondos
2. `reset_failed_models()` - Resetea la lista de modelos fallidos

### Funcionalidad:
- ✅ Hook `Model resolve` para cambiar modelos automáticamente
- ✅ Storage persistente de modelos fallidos
- ✅ Lista de modelos por agente en orden de prioridad
- ✅ Herramientas para gestionar modelos fallidos

### Modelos marcados como fallidos:
- `opencode/deepseek-v4.1-flash` (marcado manualmente)

### Configuración actualizada:
- `opencode.jsonc` ahora incluye el plugin en la sección `plugins`

## 📊 Agentes y sus Modelos

| Agente | Modelo Actual | Alternativas (en orden) |
|--------|---------------|------------------------|
| **arquitecto** | `opencode/glm-5.3-flash` | claude-haiku-5-5, beam-free, mimo-v2.6-flash-free |
| **ingeniero-godot** | `opencode/glm-5.3-flash` | claude-haiku-5-5, beam-free, mimo-v2.6-flash-free |
| **gameplay** | `opencode/minimax-m3.1-flash-free` | claude-haiku-5-5, beam-free, mimo-v2.6-flash-free |
| **qa** | `opencode/claude-haiku-5-5` | beam-free, mimo-v2.6-flash-free, gpt-5.4-mini |
| **documentacion** | `opencode/minimax-m3.1-flash-free` | claude-haiku-5-5, beam-free, mimo-v2.6-flash-free |

## 🔄 Flujo de Trabajo

1. **Modelo principal** se usa por defecto
2. **Si falla por falta de fondos**, se marca con `mark_model_failed`
3. **El plugin automáticamente** cambia al siguiente modelo disponible
4. **El estado se guarda** en storage del plugin
5. **Para resetear**, usar `reset_failed_models`

## ⚠️ Limitaciones

- El hook `Model resolve` es experimental
- Solo funciona con modelos del mismo proveedor
- Para fallbacks entre proveedores, se necesita actualizar manualmente

## 🚀 Próximo Paso

¿Quieres que:
1. **Probemos el plugin** con el agente QA?
2. **Creemos la rama de prueba** para desarrollo?
3. **Actualicemos la documentación** (ADR)?

¿Qué prefieres? 🤠