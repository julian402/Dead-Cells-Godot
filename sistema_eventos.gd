extends Node
# Tarea B niveles 2 y 3: hace que las luces respondan a lo que pasa en el juego

@export var luz_destello: OmniLight3D
@export var luz_vital: OmniLight3D

var vida = 1.0   # la Luz Vital, de 0 a 1

var rojo = Color("E8433A")
var naranja = Color("FFB347")


func _ready():
	# escucho a todos los que esten en el grupo "disparadores"
	for d in get_tree().get_nodes_in_group("disparadores"):
		d.golpe.connect(_on_golpe)
	luz_destello.light_energy = 0


func _process(delta):
	# nivel 2: el destello se apaga solo (igual a cualquier FPS)
	luz_destello.light_energy = lerp(luz_destello.light_energy, 0.0, 1 - exp(-12 * delta))

	# nivel 3: flechas para probar mientras no existe la Luz Vital de verdad
	if Input.is_key_pressed(KEY_UP):
		vida += 0.5 * delta
	if Input.is_key_pressed(KEY_DOWN):
		vida -= 0.5 * delta
	vida = clamp(vida, 0.0, 1.0)

	luz_vital.light_color = rojo.lerp(naranja, vida)
	var energia = 1 + 3 * vida
	luz_vital.light_energy = lerp(luz_vital.light_energy, energia, 1 - exp(-4 * delta))


func _on_golpe(posicion):
	luz_destello.global_position = posicion + Vector3(0, 1.5, 0)
	luz_destello.light_energy = 4
