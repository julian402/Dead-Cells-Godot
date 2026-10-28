class_name SistemaEventos
extends Node
## Tarea B, nivel 2. Hace que las luces respondan al juego: escucha a todo el grupo
## "disparadores" y hace un destello que se apaga con el alpha exponencial del Taller 2.

@export var luz_evento: OmniLight3D
@export var pico_destello := 4.0
@export var k_destello := 12.0     # 1/s: a los 0.3 s queda 4 × e^(-3.6) = 0.109 (2.7 % del pico)

## Nivel 3: una luz que sigue la Luz Vital.
@export var luz_variable: Light3D                        # la luz que sigue la variable
@export var color_bajo := Color(0.91, 0.263, 0.227)      # #E8433A: Luz Vital casi vacía
@export var color_alto := Color(1.0, 0.702, 0.278)       # #FFB347: Ceniza con la Luz Vital llena
@export var k_variable := 4.0

var variable := 1.0   # la Luz Vital, de 0 a 1: la pone el juego (o las flechas de prueba)


func _ready() -> void:
	for d in get_tree().get_nodes_in_group("disparadores"):
		d.evento.connect(_on_evento)
	luz_evento.light_energy = 0.0


func _process(delta: float) -> void:
	luz_evento.light_energy = decaer(luz_evento.light_energy, 0.0, k_destello, delta)

	# tecla de prueba mientras la mecánica de la Luz Vital no existe
	if Input.is_key_pressed(KEY_UP):
		variable = minf(1.0, variable + delta * 0.5)
	if Input.is_key_pressed(KEY_DOWN):
		variable = maxf(0.0, variable - delta * 0.5)

	if luz_variable != null:
		var v := clampf(variable, 0.0, 1.0)
		luz_variable.light_color = color_bajo.lerp(color_alto, v)
		var deseada := 1.0 + 3.0 * v
		luz_variable.light_energy = decaer(luz_variable.light_energy, deseada, k_variable, delta)


func _on_evento(posicion: Vector3) -> void:
	luz_evento.global_position = posicion + Vector3.UP * 1.5
	luz_evento.light_energy = pico_destello


static func decaer(actual: float, base: float, k: float, dt: float) -> float:
	var alpha := CamaraSeguidora.alpha_exponencial(k, dt)
	return actual + (base - actual) * alpha
