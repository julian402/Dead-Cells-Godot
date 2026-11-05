class_name ControlEfectos
extends Node
# Tarea B niveles 1, 2 y 3: no pinta nada, solo escribe el numero flash en el shader del objeto
# El golpe recibido llega por la senal golpe del Disparador (grupo "disparadores")
# Nivel 3: cuando el jugador toca el orbe lo absorbe y el orbe se disuelve

@export var objetivo: GeometryInstance3D

@export var tecla := KEY_F  # para probar sin la mecanica
@export var radio := 3.0       # m: hasta donde lo alcanza un evento
@export var dura_flash := 0.3  # s: lo que se nota el destello del golpe
@export var dura_dissolve := 1.2  # s: lo que tarda en absorberse (4 veces el golpe)
@export var jugador: Node3D
@export var distancia_absorber := 2.0  # m: el orbe flota a 1.8 m, sobre la cabeza

var mat: ShaderMaterial
var flash := 0.0
var avance := 0.0
var disolviendo := false


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

	if jugador != null and avance == 0.0 and not disolviendo:
		if objetivo.global_position.distance_to(jugador.global_position) <= distancia_absorber:
			disolver()
	if disolviendo:
		avance = avance_en(avance, delta, dura_dissolve)
		mat.set_shader_parameter("avance", avance_visible(avance))
		if avance >= 1.0:
			objetivo.visible = false
			disolviendo = false


func golpe() -> void:
	flash = 1.0


func disolver() -> void:
	disolviendo = true
	objetivo.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


func _on_evento(posicion: Vector3) -> void:
	if objetivo.global_position.distance_to(posicion) <= radio:
		golpe()


static func mezclar(base: Color, color_flash: Color, t: float) -> Color:
	return base + (color_flash - base) * t


static func decaer(actual: float, base: float, k: float, dt: float) -> float:
	return actual + (base - actual) * (1.0 - exp(-k * dt))


static func k_para(duracion: float) -> float:
	return 3.0 / duracion


static func avance_en(actual: float, dt: float, duracion: float) -> float:
	return minf(1.0, actual + dt / duracion)


static func avance_visible(a: float) -> float:
	return lerpf(0.2, 0.8, a) # el tramo donde si se ve desaparecer
