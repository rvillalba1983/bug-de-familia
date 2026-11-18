class_name EnemyRigData
extends RefCounted
## Articulaciones de cada vista, en las coordenadas del SVG original.
## La clave es el nombre de la carpeta en art/shared/rig/.
## Las diagonales `_se` y `_ne` llevan las articulaciones medidas sobre su propio
## arte (P-52); las vistas sur, este y norte siguen con valores provisionales.

const LEGS: StringName = &"piernas"
const NO_LEGS: StringName = &"sin_piernas"

const VIEWS: Dictionary = {
	"jubilado_hierro": {
		"canvas": Vector2(512.0, 512.0), "gait": LEGS, "side": false, "front": [],
		"hips": Vector2(256.0, 420.0), "chest": Vector2(256.0, 400.0),
		"joints": {
			"pierna_i": Vector2(205.0, 400.0), "pierna_d": Vector2(313.0, 400.0),
			"brazo_i": Vector2(136.0, 274.0), "brazo_d": Vector2(380.0, 272.0),
			"cabeza": Vector2(258.0, 180.0),
		},
	},
	"jubilado_hierro_e": {
		"canvas": Vector2(512.0, 512.0), "gait": LEGS, "side": true, "front": ["brazo_d"],
		"hips": Vector2(256.0, 420.0), "chest": Vector2(256.0, 400.0),
		"joints": {
			"pierna_i": Vector2(237.0, 400.0), "pierna_d": Vector2(237.0, 400.0),
			"brazo_i": Vector2(190.0, 280.0), "brazo_d": Vector2(240.0, 280.0),
			"cabeza": Vector2(258.0, 180.0),
		},
	},
	"jubilado_hierro_se": {
		# Joints medidos sobre el arte de P-52 (art/shared/rig/jubilado_hierro_se/).
		"canvas": Vector2(512.0, 512.0), "gait": LEGS, "side": true, "front": ["brazo_d"],
		"hips": Vector2(256.0, 420.0), "chest": Vector2(256.0, 400.0),
		"joints": {
			"pierna_i": Vector2(221.0, 400.0), "pierna_d": Vector2(315.0, 400.0),
			"brazo_i": Vector2(148.0, 276.0), "brazo_d": Vector2(374.0, 274.0),
			"cabeza": Vector2(260.0, 180.0),
		},
	},
	"jubilado_hierro_ne": {
		# Joints medidos sobre el arte de P-52. El brazo cercano es `brazo_i`
		# (izquierda de pantalla) y va delante del torso.
		"canvas": Vector2(512.0, 512.0), "gait": LEGS, "side": true, "front": ["brazo_i"],
		"hips": Vector2(256.0, 420.0), "chest": Vector2(256.0, 400.0),
		"joints": {
			"pierna_i": Vector2(211.0, 400.0), "pierna_d": Vector2(299.0, 400.0),
			"brazo_i": Vector2(144.0, 276.0), "brazo_d": Vector2(366.0, 274.0),
			"cabeza": Vector2(260.0, 180.0),
		},
	},
	"jubilado_hierro_n": {
		"canvas": Vector2(512.0, 512.0), "gait": LEGS, "side": false, "front": [],
		"hips": Vector2(256.0, 420.0), "chest": Vector2(256.0, 400.0),
		"joints": {
			"pierna_i": Vector2(205.0, 400.0), "pierna_d": Vector2(313.0, 400.0),
			"brazo_i": Vector2(136.0, 274.0), "brazo_d": Vector2(380.0, 272.0),
			"cabeza": Vector2(258.0, 180.0),
		},
	},
	"mohocrata": {
		"canvas": Vector2(512.0, 512.0), "gait": NO_LEGS, "side": false, "front": [],
		"hips": Vector2(256.0, 470.0), "chest": Vector2(256.0, 450.0),
		"joints": {
			"brazo_i": Vector2(180.0, 396.0), "brazo_d": Vector2(336.0, 388.0),
			"cabeza": Vector2(256.0, 268.0),
		},
	},
	"mohocrata_e": {
		"canvas": Vector2(512.0, 512.0), "gait": NO_LEGS, "side": true, "front": ["brazo_d"],
		"hips": Vector2(256.0, 470.0), "chest": Vector2(256.0, 450.0),
		"joints": {
			"brazo_i": Vector2(250.0, 390.0), "brazo_d": Vector2(300.0, 400.0),
			"cabeza": Vector2(256.0, 268.0),
		},
	},
	"mohocrata_se": {
		# Joints medidos sobre el arte de P-52 (art/shared/rig/mohocrata_se/).
		"canvas": Vector2(512.0, 512.0), "gait": NO_LEGS, "side": true, "front": ["brazo_d"],
		"hips": Vector2(256.0, 470.0), "chest": Vector2(256.0, 450.0),
		"joints": {
			"brazo_i": Vector2(210.0, 404.0), "brazo_d": Vector2(334.0, 380.0),
			"cabeza": Vector2(256.0, 268.0),
		},
	},
	"mohocrata_ne": {
		# Joints medidos sobre el arte de P-52. El brazo cercano es `brazo_i`
		# (izquierda de pantalla) y va delante del torso.
		"canvas": Vector2(512.0, 512.0), "gait": NO_LEGS, "side": true, "front": ["brazo_i"],
		"hips": Vector2(256.0, 470.0), "chest": Vector2(256.0, 450.0),
		"joints": {
			"brazo_i": Vector2(190.0, 400.0), "brazo_d": Vector2(312.0, 388.0),
			"cabeza": Vector2(256.0, 268.0),
		},
	},
	"mohocrata_n": {
		"canvas": Vector2(512.0, 512.0), "gait": NO_LEGS, "side": false, "front": [],
		"hips": Vector2(256.0, 470.0), "chest": Vector2(256.0, 450.0),
		"joints": {
			"brazo_i": Vector2(180.0, 396.0), "brazo_d": Vector2(336.0, 388.0),
			"cabeza": Vector2(256.0, 268.0),
		},
	},
	"don_ramon": {
		"canvas": Vector2(512.0, 560.0), "gait": LEGS, "side": false, "front": [],
		"hips": Vector2(256.0, 430.0), "chest": Vector2(256.0, 410.0),
		"joints": {
			"pierna_i": Vector2(209.0, 444.0), "pierna_d": Vector2(307.0, 444.0),
			"brazo_i": Vector2(134.0, 262.0), "brazo_d": Vector2(380.0, 260.0),
			"cabeza": Vector2(256.0, 180.0),
		},
	},
	"don_ramon_e": {
		"canvas": Vector2(512.0, 560.0), "gait": LEGS, "side": true, "front": ["brazo_d"],
		"hips": Vector2(256.0, 430.0), "chest": Vector2(256.0, 410.0),
		"joints": {
			"pierna_i": Vector2(253.0, 444.0), "pierna_d": Vector2(253.0, 444.0),
			"brazo_d": Vector2(240.0, 262.0), "cabeza": Vector2(256.0, 180.0),
		},
	},
	"don_ramon_se": {
		# Joints medidos sobre el arte de P-52 (art/shared/rig/don_ramon_se/).
		# El brazo lejano lo dibuja el arte dentro de la pieza `torso`.
		"canvas": Vector2(512.0, 560.0), "gait": LEGS, "side": true, "front": ["brazo_d"],
		"hips": Vector2(256.0, 430.0), "chest": Vector2(256.0, 410.0),
		"joints": {
			"pierna_i": Vector2(224.0, 440.0), "pierna_d": Vector2(311.0, 440.0),
			"brazo_d": Vector2(374.0, 262.0), "cabeza": Vector2(256.0, 180.0),
		},
	},
	"don_ramon_ne": {
		# Joints medidos sobre el arte de P-52. `front` sigue en `brazo_d`, pero
		# aquí ese es el brazo cercano (izquierda de pantalla): el lejano lo
		# dibuja el arte dentro de la pieza `torso`.
		"canvas": Vector2(512.0, 560.0), "gait": LEGS, "side": true, "front": ["brazo_d"],
		"hips": Vector2(256.0, 430.0), "chest": Vector2(256.0, 410.0),
		"joints": {
			"pierna_i": Vector2(208.0, 440.0), "pierna_d": Vector2(292.0, 440.0),
			"brazo_d": Vector2(158.0, 264.0), "cabeza": Vector2(256.0, 180.0),
		},
	},
	"don_ramon_n": {
		"canvas": Vector2(512.0, 560.0), "gait": LEGS, "side": false, "front": [],
		"hips": Vector2(256.0, 430.0), "chest": Vector2(256.0, 410.0),
		"joints": {
			"pierna_i": Vector2(209.0, 444.0), "pierna_d": Vector2(307.0, 444.0),
			"brazo_i": Vector2(134.0, 262.0), "brazo_d": Vector2(380.0, 262.0),
			"cabeza": Vector2(256.0, 180.0),
		},
	},
}
