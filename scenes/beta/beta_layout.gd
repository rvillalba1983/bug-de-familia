class_name BetaLayout
extends RefCounted
## Geometría fija de la zona de la beta: bosque con una ciudad perdida en el centro.
## Jubilados al norte, Mohócratas al sur y la tierra de nadie entre ambos.

const WORLD_SIZE: Vector2 = Vector2(3800.0, 2600.0)
const FLOOR_RECT: Rect2 = Rect2(100.0, 100.0, 3600.0, 2400.0)
const START: Vector2 = Vector2(300.0, 1300.0)
const SAVE_POINTS: Array[Vector2] = [
	Vector2(300.0, 1300.0), Vector2(1700.0, 950.0),
	Vector2(1700.0, 1600.0), Vector2(3300.0, 1300.0),
]

const CITY: Rect2 = Rect2(1100.0, 500.0, 1900.0, 1640.0)
const NORTH_QUARTER: Rect2 = Rect2(1100.0, 540.0, 1900.0, 610.0)
const SOUTH_QUARTER: Rect2 = Rect2(1100.0, 1490.0, 1900.0, 610.0)
const NO_MANS_LAND: Rect2 = Rect2(1140.0, 1190.0, 2560.0, 260.0)
const CROSSING_GOAL: Rect2 = Rect2(3350.0, 1190.0, 350.0, 260.0)
const CENTRAL_INSIDE: Rect2 = Rect2(2340.0, 660.0, 420.0, 340.0)
const DEPOT: Rect2 = Rect2(2200.0, 1650.0, 600.0, 330.0)

## Zona de dibujo de las fachadas. La del depósito sobresale por el sombrero de la seta.
const CENTRAL_FACADE: Rect2 = Rect2(2300.0, 600.0, 500.0, 480.0)
const DEPOT_FACADE: Rect2 = Rect2(2200.0, 1524.0, 640.0, 533.0)
const FACADE_DOOR_HEIGHT: float = 180.0

const CENTRAL_DOOR: Rect2 = Rect2(2520.0, 1000.0, 100.0, 40.0)
const CRACKED_WALL: Rect2 = Rect2(2300.0, 780.0, 40.0, 100.0)

const WALLS: Array[Rect2] = [
	# Muralla norte, con puerta en 1900-2060.
	Rect2(1100.0, 500.0, 800.0, 40.0), Rect2(2060.0, 500.0, 940.0, 40.0),
	# Muralla sur, con puerta en 1900-2060.
	Rect2(1100.0, 2100.0, 800.0, 40.0), Rect2(2060.0, 2100.0, 940.0, 40.0),
	# Muralla oeste, con entradas a los barrios y a la tierra de nadie.
	Rect2(1100.0, 540.0, 40.0, 260.0), Rect2(1100.0, 920.0, 40.0, 230.0),
	Rect2(1100.0, 1490.0, 40.0, 210.0), Rect2(1100.0, 1820.0, 40.0, 280.0),
	# Cierre del este: el mirador solo se alcanza por la tierra de nadie.
	Rect2(3000.0, 100.0, 40.0, 1050.0), Rect2(3000.0, 1490.0, 40.0, 1010.0),
	Rect2(3040.0, 1150.0, 660.0, 40.0), Rect2(3040.0, 1450.0, 660.0, 40.0),
	# Bordes de la tierra de nadie, con un paso a cada barrio en 1950-2070.
	Rect2(1100.0, 1150.0, 850.0, 40.0), Rect2(2070.0, 1150.0, 930.0, 40.0),
	Rect2(1100.0, 1450.0, 850.0, 40.0), Rect2(2070.0, 1450.0, 930.0, 40.0),
	# Centralita: conducto de servicio al norte (2540-2620).
	Rect2(2300.0, 620.0, 240.0, 40.0), Rect2(2620.0, 620.0, 180.0, 40.0),
	Rect2(2300.0, 660.0, 40.0, 120.0), Rect2(2300.0, 880.0, 40.0, 160.0),
	Rect2(2760.0, 660.0, 40.0, 380.0),
	Rect2(2340.0, 1000.0, 180.0, 40.0), Rect2(2620.0, 1000.0, 140.0, 40.0),
	# Depósito mohócrata: entrada al oeste (1780-1880) y hueco al sur (2480-2560).
	Rect2(2200.0, 1650.0, 600.0, 40.0), Rect2(2800.0, 1650.0, 40.0, 370.0),
	Rect2(2200.0, 1690.0, 40.0, 90.0), Rect2(2200.0, 1880.0, 40.0, 140.0),
	Rect2(2240.0, 1980.0, 240.0, 40.0), Rect2(2560.0, 1980.0, 240.0, 40.0),
	# Pilares en ruinas que cortan la vista en la tierra de nadie.
	Rect2(1500.0, 1290.0, 60.0, 60.0), Rect2(2000.0, 1290.0, 60.0, 60.0),
	Rect2(2500.0, 1290.0, 60.0, 60.0),
	# Árboles.
	Rect2(2920.0, 200.0, 44.0, 44.0),
	Rect2(2770.0, 2160.0, 44.0, 44.0),
	Rect2(1930.0, 420.0, 44.0, 44.0),
	Rect2(950.0, 600.0, 44.0, 44.0),
	Rect2(2700.0, 170.0, 44.0, 44.0),
	Rect2(1440.0, 390.0, 44.0, 44.0),
	Rect2(1030.0, 2390.0, 44.0, 44.0),
	Rect2(2810.0, 2430.0, 44.0, 44.0),
	Rect2(2210.0, 2390.0, 44.0, 44.0),
	Rect2(2230.0, 170.0, 44.0, 44.0),
	Rect2(290.0, 870.0, 44.0, 44.0),
	Rect2(310.0, 1160.0, 44.0, 44.0),
	Rect2(700.0, 2440.0, 44.0, 44.0),
	Rect2(1880.0, 2390.0, 44.0, 44.0),
	Rect2(950.0, 2060.0, 44.0, 44.0),
	Rect2(1590.0, 2200.0, 44.0, 44.0),
	Rect2(1210.0, 420.0, 44.0, 44.0),
	Rect2(1730.0, 210.0, 44.0, 44.0),
	Rect2(660.0, 910.0, 44.0, 44.0),
	Rect2(1320.0, 2410.0, 44.0, 44.0),
	Rect2(2520.0, 2150.0, 44.0, 44.0),
	Rect2(710.0, 190.0, 44.0, 44.0),
	Rect2(1110.0, 410.0, 44.0, 44.0),
	Rect2(400.0, 2210.0, 44.0, 44.0),
	Rect2(360.0, 1790.0, 44.0, 44.0),
	Rect2(1150.0, 2440.0, 44.0, 44.0),
	Rect2(1110.0, 140.0, 44.0, 44.0),
	Rect2(200.0, 190.0, 44.0, 44.0),
	Rect2(190.0, 1780.0, 44.0, 44.0),
	Rect2(260.0, 690.0, 44.0, 44.0),
	Rect2(2040.0, 2450.0, 44.0, 44.0),
	Rect2(1220.0, 2170.0, 44.0, 44.0),
	Rect2(1450.0, 2390.0, 44.0, 44.0),
	Rect2(2880.0, 430.0, 44.0, 44.0),
]
const LOW_COVERS: Array[Rect2] = [
	Rect2(1320.0, 1220.0, 120.0, 30.0), Rect2(1680.0, 1390.0, 120.0, 30.0),
	Rect2(2180.0, 1220.0, 120.0, 30.0), Rect2(2680.0, 1390.0, 120.0, 30.0),
	Rect2(2860.0, 1220.0, 100.0, 30.0),
	Rect2(2340.0, 1780.0, 140.0, 30.0), Rect2(2560.0, 1880.0, 140.0, 30.0),
]

const MINES: Array[Vector2] = [
	Vector2(1250.0, 1320.0), Vector2(1640.0, 1260.0), Vector2(1640.0, 1370.0),
	Vector2(1880.0, 1310.0), Vector2(2130.0, 1260.0), Vector2(2130.0, 1390.0),
	Vector2(2400.0, 1320.0), Vector2(2640.0, 1250.0), Vector2(2640.0, 1370.0),
	Vector2(2900.0, 1320.0), Vector2(3150.0, 1260.0), Vector2(3150.0, 1380.0),
]

## Los primeros de SHELTERS son toldos al aire libre; el resto, interiores.
const OUTDOOR_SHELTERS: int = 4
const SHELTERS: Array[Rect2] = [
	Rect2(620.0, 1000.0, 160.0, 120.0), Rect2(620.0, 1600.0, 160.0, 120.0),
	Rect2(1600.0, 820.0, 180.0, 100.0), Rect2(1600.0, 1560.0, 180.0, 100.0),
	CENTRAL_INSIDE, DEPOT,
]

const JUB_BARRIO_PATROL: Array[Vector2] = [Vector2(1250.0, 620.0), Vector2(2200.0, 620.0)]
const JUB_FRONT_PATROL: Array[Vector2] = [Vector2(2250.0, 1100.0), Vector2(2880.0, 1100.0)]
const JUB_STRIP_PATROL: Array[Vector2] = [Vector2(1250.0, 1225.0), Vector2(2950.0, 1225.0)]
const MOHO_STRIP_PATROL: Array[Vector2] = [Vector2(2950.0, 1410.0), Vector2(1250.0, 1410.0)]
const MOHO_DEPOT_PATROL: Array[Vector2] = [Vector2(2300.0, 1740.0), Vector2(2720.0, 1740.0)]
const MOHO_GATE_PATROL: Array[Vector2] = [Vector2(2120.0, 1560.0), Vector2(2120.0, 2000.0)]
## Adonde acuden los bandos cuando estalla la guerra por la chatarra.
const BRAWL_PATROL: Array[Vector2] = [Vector2(1900.0, 1320.0), Vector2(2300.0, 1320.0)]
const JUB_HOME_PATROL: Array[Vector2] = [Vector2(1400.0, 1020.0), Vector2(2100.0, 1020.0)]
const MOHO_HOME_PATROL: Array[Vector2] = [Vector2(1400.0, 1600.0), Vector2(2000.0, 1600.0)]

const DRONE_PATROL: Array[Vector2] = [Vector2(2350.0, 575.0), Vector2(2780.0, 575.0)]
const CAMERA_POSITION: Vector2 = Vector2(2300.0, 1095.0)
const CAMERA_CENTER_DEGREES: float = 0.0
const CAMERA_AMPLITUDE_DEGREES: float = 40.0

const RAMON_ROUTE: Array[Vector2] = [
	Vector2(500.0, 300.0), Vector2(2600.0, 300.0), Vector2(500.0, 300.0),
	Vector2(500.0, 2300.0), Vector2(2600.0, 2300.0), Vector2(500.0, 2300.0),
]
const MOHO_GROUP_ROUTE: Array[Vector2] = [Vector2(830.0, 2000.0), Vector2(830.0, 1450.0)]
const JUB_GROUP_ROUTE: Array[Vector2] = [Vector2(830.0, 650.0), Vector2(830.0, 1150.0)]

const MINE_PICKUP: Vector2 = Vector2(1380.0, 960.0)
const CRACKED_MARK: Vector2 = Vector2(2250.0, 860.0)
const REEL: Vector2 = Vector2(2680.0, 1830.0)
const GENERATOR: Vector2 = Vector2(700.0, 1300.0)
const PICKUP_LEG: Vector2 = Vector2(1200.0, 2300.0)
const PICKUP_ARM: Vector2 = Vector2(1800.0, 700.0)
const CRATE_NORTH: Vector2 = Vector2(2130.0, 930.0)
const CRATE_SOUTH: Vector2 = Vector2(1950.0, 1900.0)

## Puntos de aparición y encuentro del mundo vivo. Provisionales.
const JUB_HOME: Rect2 = Rect2(1220.0, 640.0, 960.0, 440.0)
const MOHO_HOME: Rect2 = Rect2(1220.0, 1560.0, 880.0, 480.0)
const JUB_GATE: Vector2 = Vector2(1980.0, 560.0)
const MOHO_GATE: Vector2 = Vector2(1980.0, 2070.0)
const ANTENNAS: Array[Vector2] = [Vector2(1620.0, 1180.0), Vector2(900.0, 980.0), Vector2(2650.0, 1620.0)]
const OPEN_SPOTS: Array[Vector2] = [
	Vector2(1450.0, 900.0), Vector2(1800.0, 760.0), Vector2(2050.0, 1000.0),
	Vector2(1450.0, 1750.0), Vector2(1800.0, 1950.0), Vector2(2000.0, 1650.0),
	Vector2(1750.0, 1320.0), Vector2(2300.0, 1300.0), Vector2(1250.0, 1270.0),
]
