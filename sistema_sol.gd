class_name SistemaSol
extends Node
## Tarea A, niveles 1, 2 y 3. Aplica la hora a la luz principal y al ambiente; calcula Lambert.

signal cambio_noche(es_noche: bool)

@export var sol: DirectionalLight3D
@export var entorno: WorldEnvironment
@export var luz_reacciona: Light3D
@export var energia_sol := 1.0
@export var azimut := -30.0        # grados en Y: hacia dónde caen las sombras
@export var ambiente_dia := 0.4
@export var ambiente_noche := 0.15

@onready var ciclo: CicloDia = $CicloDia

var era_noche := false


func _ready() -> void:
	aplicar_hora()
	era_noche = CicloDia.factor_sol(ciclo.hora) <= 0.0
	if luz_reacciona != null:
		cambio_noche.connect(func(n: bool) -> void: luz_reacciona.visible = n)


func _process(delta: float) -> void:
	ciclo.avanzar(delta)
	aplicar_hora()
	var es_noche := CicloDia.factor_sol(ciclo.hora) <= 0.0
	if es_noche != era_noche:
		era_noche = es_noche
		cambio_noche.emit(es_noche)


func aplicar_hora() -> void:
	var h := ciclo.hora
	var f := CicloDia.factor_sol(h)
	sol.rotation_degrees = Vector3(-CicloDia.elevacion(h), azimut, 0.0)
	sol.light_energy = energia_sol * f
	sol.light_color = CicloDia.color_sol(h)
	entorno.environment.ambient_light_energy = lerpf(ambiente_noche, ambiente_dia, f)


static func lambert(normal: Vector3, hacia_luz: Vector3) -> float:
	var n := Vectores.normalizar(normal)
	var l := Vectores.normalizar(hacia_luz)
	return maxf(0.0, n.dot(l))


func prediccion_piso() -> float:
	var hacia_luz := sol.global_transform.basis.z
	return sol.light_energy * sol.light_color.r * lambert(Vector3.UP, hacia_luz)
