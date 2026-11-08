class_name Sentinel
extends RefCounted
## Crea las piezas comunes de un enemigo: detector, cono visible y selección.


static func add_cone(owner_node: Node2D, ground: Node2D, detector: Detector) -> VisionConeView:
	var view: VisionConeView = VisionConeView.new()
	view.detector = detector
	ground.add_child(view)
	var selectable: Selectable = Selectable.new()
	owner_node.add_child(selectable)
	return view
