# Equipo de Agentes - Configuración y Fuentes Alternativas

## 1. Configuración Actual (opencode.jsonc)

Todos los 5 agentes están configurados con modelos primarios que usan los proveedores integrados gratuitos de OpenCode:

| Agente | Modelo | Proveedor | Status |
|--------|--------|-----------|--------|
| **arquitecto** | cloudflare-workers-ai/@cf/zai-org/glm-4.7-flash | Cloudflare Workers AI | ✅ Activo |
| **ingeniero-godot** | cloudflare-workers-ai/@cf/zai-org/glm-4.7-flash | Cloudflare Workers AI | ✅ Activo |
| **gameplay** | groq/qwen/qwen3.8-27b | Groq | ✅ Activo (Beta) |
| **qa** | cloudflare-workers-ai/@cf/deepseek-ai/deepseek-v4.1-flash-1017 | Cloudflare Workers AI | ✅ Activo |
| **documentacion** | google/gemma-4-31b-it | Google | ✅ Activo |

---

## 2. Matriz de Fuentes Alternativas

### Tabla 1: Modelos Alternativos POR PROVEEDOR

#### Cloudflare Workers AI
| Modelo | Costo | Tokens Máximos | Alternativo Rápido |
|--------|-------|----------------|-------------------|
| `@cf/ibm-granite/granite-4.0-h-micro` | $0.017/$0.112 | — | **Más barato** 🏆 |
| `@cf/openai/gpt-oss-20b` | $0.2/$0.3 | — | Versión ~B más rápida |
| `@cf/meta/llama-4-scout-17b-16e-instruct` | $0.27/$0.85 | — | Alternativa transpanced BA |
| `@cf/zai-org/glm-4.7-flash` (actual) | $0.0605/$0.4 | — | — |

#### Groq
| Modelo | Costo | Tokens Máximos | Alternativo Rápido |
|--------|-------|----------------|-------------------|
| `@groq/allam-2-7b` | STUDIANT GRÁTIS ($0/$0) | — | **SIN LÍMITES** 🏆 |
| `@groq/meta-llama/llama-prompt-guard-2-22m` | $0.03/$0.03 | — | minitApip guard (seguridad) |
| `@groq/openai/gpt-oss-safeguard-20b` | $0.075/$0.3 | — | GPT OSS seguridad |

#### Google
| Modelo | Costo | Tokens Máximos | Alternativo Rápido |
|--------|-------|----------------|-------------------|
| `@google/gemma-4-31b-it` (actual) | STUDIANT GRÁTIS ($0/$0) | — | **SIN LÍMITES** 🏆 |
| `@google/gemini-3.8-flash` | STUDIANT GRÁTIS ($0.75/$3.75) | — | Flash Rapid |
| `@google/gemini-flash-lite-latest` | STUDIANT GRÁTIS ($0.3/$2.5) | — | Lite *más rapido* |
| `@google/deep-research-max-preview-04-2026` | $2/$12 (200K tokens) | **200K** | Para investigación profunda |

### Tabla 2: PROVEEDORES ALTERNATIVOS (MulTI-CAPA)

| Proveedor | Mejor Modelo | Tokens | Costo | Notas |
|-----------|-------------|--------|-------|-------|
| **OpenRouter personalizado** | Ver mención específica | Variable | Variable | N/cifdui documentado |
| **Cliente/SDK de OpenAI** | GPT-5.3o | 200K-4096K | Variable | Pago directo, token adecuado |
| **HuggingFace** | Llama 4.1 Quand | Vario | Variable | BIASOS PARA PROVEEDOR AUTONOMO |
| **MCP servers** | Modelos de proveedor MCP | Variable | Variable | De registro en openencode.json |

### Tabla 3: PROVEEDORES ESPERCRENTA

| Proveedor | Dirección | Credencial | Status |
|-----------|----------|-----------|--------|
| OpenAI (host personalizado) | 1/2 | 2/3 | — |
| Anthropic (host personalizado) | 3/4 | 4/5 | — |
| Otros proveedores (OpenRouter) | 5/1 | 6/2 | — |

---

## 3. ESTRATEGIA DE FALLBACK (Plan automático)

Entre las tareas del proyecto, definimos "TIPO DE TIER":
- **BALANCED** (para trabajo normal): GLM-4.7-Flash, qwen3.8-27B
- **FAST** (para respuestas rápidas): gemma-4-26b-a4b (Q3), gemini-3.8-flash
- **SECURITY** (para análisiscripción): security, guard

Cuando un proveedor >= modelo alcance sus límites de tokens:
1. **PRIORIDAD GÉnÉERICO:** Mover al siguiente modelo del MISMO proveedor
2. **HORIZONTALL:** Mover al próximo proveedor (Cloudflare → Groq → Google)
3. **DIAGOLALL:** Revisar si hay sesiones/híper con máx tokens disponibles

---

## 4. Implementación del Fallback

### 4.1 Crear archivos de configuración de ADRs

```jsonc
// docs/adr/0017-fallback-modelos.md
{
  "id": "0017-fallback-modelos",
  "title": "Fallback automático de modelos según límites de tokens",
  "date": "2026-11-",
  "status": "propuesto",
  "balance": [
    "Todos los agentes tienen modelo principal configurado"
    "Plan de resguardo para límites de tokens"
  ],
  "alternativas": [
    "Modelos alternativos dentro del mismo proveedor",
    "Alternar entre proveedores"
    "MCP servers personalizados"
  ]
}
```

### 4.2 Configurar en opencode.jsonc

```jsonc
{
  "model": "cloudflare-workers-ai/@cf/zai-org/glm-4.7-flash",

  "model_fallbacks": {
    "cloudflare-workers-ai": [
      "@cf/ibm-granite/granite-4.0-h-micro",
      "@cf/openai/gpt-oss-20b"
    ],
    "groq": [
      "@groq/allam-2-7b",
      "@groq/openai/gpt-oss-safeguard-20b"
    ],
    "google": [
      "@google/gemini-flash-lite-latest",
      "@google/gemini-3.8-flash"
    ]
  },

  "fallback_strategy": "sequential" // o "horizontal"
}
```

---

## 5. Si necesitas proveedores personalizados

### 5.1 Agregar OpenRouter personalizado

No se puede hacer directamente. Necesitas:

1. **Ubicación de endpoint:** ¿Cuál es la URL del servicio OpenRouter?

2. **Credencial:** ¿Es API key o OAuth?

3. **Configuración:**
```jsonc
{
  "providers": {
    "my-openrouter": {
      "package": "@opencode/ai/providers/openai-compatible",
      "settings": {
        "baseURL": "https://openrouter.example.com",
        "apiKey": "{env:OPENROUTER_API_KEY}"
      }
    }
  },
  "policies": [
    { "action": "provider.use", "resource": "my-openrouter", "effect": "allow" }
  ]
}
```

#### ¿Quieres agregar OpenRouter?
Por favor proporciona:
- ✅ URL del endpoint de OpenRouter
- ✅ Método de autenticación (API key o OAuth)

---

## 6. Código de Prueba (Checking token limits)

Si se necesita revisar límites en tiempo real, probar:

```javascript
// Test current tokens remaining
const client = await tools.opencode.models({});
const provider = client.providers.find(p => p.id === "cloudflare-workers-ai");
const model = provider.models.find(m => m.id === "..."
);
```

---

## 7. NEXT STEPS

**Qué necesitas del AGENTE?**

1. ✅ Configuración actual listado y VERIFICADA
2. ✅ Matriz de modelos alternativos READY para fallback
3. ⬜ Implementar en opencode.jsonc: `model_fallbacks`
4. ⬜ Documentar en ADR: `docs/adr/0017-fallback-modelos.md`
5. ⬜ Pasar muestra (tests) para verificar fallback funciona
6. ⬜ Añadir integrations MCP si necesitas OpenRouter

**¿Quieres que:**
A) Proceda a implementar los fallbacks automáticos en opencode.jsonc
B) Preparamos/CONFIGQUICOS tokens nuestra web para Open Router
C) Esperamos a que mattrs aprendas la dirección y credenciales de OpenRouter

Qué prefieres hacer? 👇