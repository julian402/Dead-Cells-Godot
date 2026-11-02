extends Node
# Tarea A niveles 1, 2 y 3: aplica la hora a la luz principal y al ambiente, calcula Lambert y controla el halo

signal cambio_noche(es_noche)

@export var sol: DirectionalLight3D
@export var entorno: WorldEnvironment
@export var luz_reacciona: Light3D
@export var halo_jugador: OmniLight3D
@export var energia_sol = 1.0
@export var azimut = -30.0        # grados en Y: hacia donde caen las sombras
@export var ambiente_dia = 0.4
@export var ambiente_noche = 0.15

@onready var ciclo = $CicloDia

var era_noche = false
var luz_vital = 1.0   # de 0 a 1: el halo de 3 m es penumbra y no frena el gasto (-1%/s)


func _ready():
	aplicar_hora()
	era_noche = ciclo.factor_sol(ciclo.hora) <= 0.0
	if luz_reacciona != null:
		cambio_noche.connect(func(n): luz_reacciona.visible = n)


func _process(delta):
	ciclo.avanzar(delta)
	aplicar_hora()
	var es_noche = ciclo.factor_sol(ciclo.hora) <= 0.0
	if es_noche != era_noche:
		era_noche = es_noche
		cambio_noche.emit(es_noche)
	actualizar_penumbra(delta)


func aplicar_hora():
	var h = ciclo.hora
	var f = ciclo.factor_sol(h)
	sol.rotation_degrees = Vector3(-ciclo.elevacion(h), azimut, 0.0)
	sol.light_energy = energia_sol * f
	sol.light_color = ciclo.color_sol(h)
	entorno.environment.ambient_light_energy = lerp(ambiente_noche, ambiente_dia, f)


func actualizar_penumbra(delta):
	# Vacio A: el halo propio (3 m) es penumbra y no frena la perdida (-1%/s)
	luz_vital -= 0.01 * delta
	if Input.is_key_pressed(KEY_UP):
		luz_vital += 0.5 * delta
	if Input.is_key_pressed(KEY_DOWN):
		luz_vital -= 0.5 * delta
	luz_vital = clamp(luz_vital, 0.0, 1.0)
	if halo_jugador != null:
		halo_jugador.omni_range = lerp(0.5, 3.0, luz_vital)
	if entorno != null and entorno.environment != null:
		entorno.environment.fog_depth_begin = lerp(3.5, 8.0, luz_vital)


static func lambert(normal, hacia_luz):
	var n = normal.normalized()
	var l = hacia_luz.normalized()
	return max(0.0, n.dot(l))


func prediccion_piso():
	var hacia_luz = sol.global_transform.basis.z
	return sol.light_energy * sol.light_color.r * lambert(Vector3.UP, hacia_luz)
