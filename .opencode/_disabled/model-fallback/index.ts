import { Plugin } from "@opencode/plugin"

export default Plugin.define({
  id: "model-fallback",
  async setup(ctx) {
    // Lista de modelos por agente (en orden de prioridad)
    const modelLists: Record<string, string[]> = {
      "arquitecto": ["opencode/glm-5.3-flash", "opencode/claude-haiku-5-5", "opencode/beam-free", "opencode/mimo-v2.6-flash-free"],
      "ingeniero-godot": ["opencode/glm-5.3-flash", "opencode/claude-haiku-5-5", "opencode/beam-free", "opencode/mimo-v2.6-flash-free"],
      "gameplay": ["opencode/minimax-m3.1-flash-free", "opencode/claude-haiku-5-5", "opencode/beam-free", "opencode/mimo-v2.6-flash-free"],
      "qa": ["opencode/claude-haiku-5-5", "opencode/beam-free", "opencode/mimo-v2.6-flash-free", "opencode/gpt-5.4-mini"],
      "documentacion": ["opencode/minimax-m3.1-flash-free", "opencode/claude-haiku-5-5", "opencode/beam-free", "opencode/mimo-v2.6-flash-free"]
    }

    // Leer estado de modelos sin fondos
    const failedModels: Record<string, boolean> = (await ctx.storage.get("failed_models")) || {}

    // Hook experimental: Model resolve
    // Se ejecuta cuando una sesión resuelve el modelo para una solicitud
    await ctx.session.hook("context", async (event) => {
      const agent = event.agent
      if (!modelLists[agent]) return

      // Encontrar el primer modelo disponible
      for (const model of modelLists[agent]) {
        if (!failedModels[model]) {
          // Cambiar al modelo disponible
          const [providerID, modelID] = model.split('/')
          await ctx.session.switchModel({
            sessionID: event.sessionID,
            model: { providerID, id: modelID }
          })
          return
        }
      }
    }, { experimental: true })

    // Herramienta para marcar un modelo como sin fondos
    await ctx.tool.transform((editor) => {
      editor.add({
        name: "mark_model_failed",
        description: "Marca un modelo como sin fondos para fallback automático",
        input: {
          type: "object",
          properties: { model: { type: "string" } },
          required: ["model"]
        },
        execute: async (input) => {
          failedModels[input.model] = true
          await ctx.storage.set("failed_models", failedModels)
          return { content: `Modelo ${input.model} marcado como sin fondos. Se usará el siguiente modelo disponible.` }
        }
      })
    })

    // Herramienta para resetear modelos fallidos
    await ctx.tool.transform((editor) => {
      editor.add({
        name: "reset_failed_models",
        description: "Resetea la lista de modelos sin fondos",
        input: { type: "object", properties: {} },
        execute: async () => {
          Object.keys(failedModels).forEach(key => delete failedModels[key])
          await ctx.storage.set("failed_models", {})
          return { content: "Lista de modelos fallidos reseteada" }
        }
      })
    })

    console.log("Plugin model-fallback cargado correctamente")
  }
})