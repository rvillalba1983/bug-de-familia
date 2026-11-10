extends Node
# tools/capture_helper.gd

static func capture_screenshot(node: Node, filename: String):
    var viewport = node.get_viewport()
    yield(VisualServer, "frame_post_draw")
    var img = viewport.get_texture().get_data()
    img.flip_y()
    img.save_png("res://docs/capturas/" + filename + ".png")
    print("Screenshot guardada: ", filename)

static func start_video_record():
    # Integración con plugin de grabación (ej: GodotVideoRecorder)
    if Engine.has_meta("recorder"):
        Engine.get_meta("recorder").start()

static func stop_video_record(output_path: String):
    if Engine.has_meta("recorder"):
        Engine.get_meta("recorder").stop(output_path)
