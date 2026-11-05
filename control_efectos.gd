class_name ControlEfectos
extends Node
# Tarea B niveles 1 y 2: no pinta nada, solo escribe el numero flash en el shader del objeto
# El golpe recibido llega por la senal golpe del Disparador (grupo "disparadores")

@export var objetivo: GeometryInstance3D

@export var tecla := KEY_F  # para probar sin la mecanica
@export var radio := 3.0       # m: hasta donde lo alcanza un evento
@export var dura_flash := 0.3  # s: lo que se nota el destello del golpe

var mat: ShaderMaterial
var flash := 0.0


func _ready() -> void:
	mat = objetivo.material_override.duplicate() # cada objeto con su copia
	objetivo.material_override = mat
	for d in get_tree().get_nodes_in_group("disparadores"):
		d.golpe.connect(_on_evento)


func _process(delta: float) -> void:
	if Input.is_physical_key_pressed(tecla):
		golpe()
	flash = decaer(flash, 0.0, k_para(dura_flash), delta)
	mat.set_shader_parameter("flash", flash)


func golpe() -> void:
	flash = 1.0


func _on_evento(posicion: Vector3) -> void:
	if objetivo.global_position.distance_to(posicion) <= radio:
		golpe()


static func mezclar(base: Color, color_flash: Color, t: float) -> Color:
	return base + (color_flash - base) * t


static func decaer(actual: float, base: float, k: float, dt: float) -> float:
	return actual + (base - actual) * (1.0 - exp(-k * dt))


static func k_para(duracion: float) -> float:
	return 3.0 / duracion
