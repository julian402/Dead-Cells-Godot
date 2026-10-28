class_name SistemaEventos
extends Node
## Tarea B, nivel 2. Hace que las luces respondan al juego: escucha a todo el grupo
## "disparadores" y hace un destello que se apaga con el alpha exponencial del Taller 2.

@export var luz_evento: OmniLight3D
@export var pico_destello := 4.0
@export var k_destello := 12.0     # 1/s: a los 0.3 s queda 4 × e^(-3.6) = 0.109 (2.7 % del pico)


func _ready() -> void:
	for d in get_tree().get_nodes_in_group("disparadores"):
		d.evento.connect(_on_evento)
	luz_evento.light_energy = 0.0


func _process(delta: float) -> void:
	luz_evento.light_energy = decaer(luz_evento.light_energy, 0.0, k_destello, delta)


func _on_evento(posicion: Vector3) -> void:
	luz_evento.global_position = posicion + Vector3.UP * 1.5
	luz_evento.light_energy = pico_destello


static func decaer(actual: float, base: float, k: float, dt: float) -> float:
	var alpha := CamaraSeguidora.alpha_exponencial(k, dt)
	return actual + (base - actual) * alpha
