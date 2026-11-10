# Configuración de OpenCode y Acceso a Modelos

## Estado Actual (2026-11-10)

Todos los modelos que solicitaste están **funcionalmente disponibles** a través de proveedores nativos de OpenCode sin necesidad de catálogos externos:

### Proveedores Disponibles

1. **cloudflare-workers-ai** ✅
   - `@cf/zai-org/glm-4.7-flash` (GLM-4.7-Flash) - $0.0605/$0.4
   - `@cf/deepseek-ai/deepseek-v4.1-flash-1017` (DeepSeek V4.1 Flash 1017) - $0.3/$1.2
   - `@cf/qwen/qwen3.8-27b` (Qwen3.8 27B) - $0.45/$3.2
   - `@cf/google/gemma-4-26b-a4b-it` (Gemma 4 26B) - $0.1/$0.3
   - `@cf/zai-org/glm-5.3` (Glm 5.3) - $1.4/$4.4
   - y más...

2. **google** ✅
   - `gemma-4-31b-it` (Gemma 4 31B IT) - STUDIANT GRÁTIS ($0/$0)
   - `gemini-4-argon`, `gemini-3.8-flash`, `gemini-3.5-flash-lite`
   - y modelos de investigación

3. **groq** ✅
   - `qwen/qwen3.8-27b` (Qwen3.8 27B) - $0.8/$4
   - `allam-2-7b` (todo STUDIO GRÁTIS)
   - modelos de seguridad

4. **sambanova** ✅
   - `MiniMax-M3`
   - `DeepSeek-V3.2`
   - `gemma-4-31B-it`

### Modelos Sollicitados para el Equipo de Agentes

| Agente | Modelo Solicitado | Estado |
|--------|------------------|--------|
| arquitecto | cloudflare-workers-ai/@cf/zai-org/glm-4.7-flash | ✅ DISPONIBLE |
| ingeniero-godot | cloudflare-workers-ai/@cf/zai-org/glm-4.7-flash | ✅ DISPONIBLE |
| gameplay | groq/qwen/qwen3.8-27b | ✅ DISPONIBLE (BETA) |
| qa | cloudflare-workers-ai/@cf/deepseek-ai/deepseek-v4.1-flash-1017 | ✅ DISPONIBLE |
| documentacion | google/gemma-4-31b-it | ✅ DISPONIBLE (-) |

**Nota:** `gemma-4-31b-it` no muestra costos porque es de estudio gratuito.

## Cuestiones a Resolver

1. ¿Qué "catálogos anteriores" específicos se refiere? ¿Proveedor OpenCode/POD/hosting que ya no existe?

2. ¿Qué modelos específicos experimentaban problemas de acceso?

3. ¿Afecta esto solo a la sesión actual o a todas las conexiones?

## Recomendación Inmediata

El sistema ya funciona correctamente con los proveedores nativos. Si hay algún proveedor específico (como un endpoint OpenRouter personalizado) que necesites, necesitamos saber:
- Dirección del endpoint
- Si requiere API key
- Si debe ir en políticas específicas

¿Puedes proporcionar más contexto sobre qué fue lo que dejó de funcionar?