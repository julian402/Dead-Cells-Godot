extends Area2D
# Zombi con vaivén. Solo avisa que tocó al jugador: el Mundo decide qué pasa.

signal toco_al_jugador(zombi)

@export_enum("x", "y") var eje: String = "x"   # en qué eje hace el vaivén
@export var speed = 60.0        # px/s (con 0 se queda quieto)
@export var distancia = 96.0    # px hacia cada lado de su posición inicial

var inicio = Vector2.ZERO
var direccion = 1


func _ready():
	inicio = position
	body_entered.connect(_on_body_entered)


func _process(delta):
	var i = 0 if eje == "x" else 1   # Vector2: [0] es x, [1] es y
	var pos = position
	pos[i] += speed * direccion * delta
	if abs(pos[i] - inicio[i]) >= distancia:
		pos[i] = inicio[i] + distancia * direccion
		direccion *= -1
	position = pos
	if eje == "x":
		$Sprite2D.flip_h = direccion < 0


func _on_body_entered(body):
	if body.is_in_group("jugador"):
		toco_al_jugador.emit(self)


func volver_a_casa():
	position = inicio
	direccion = 1


func morir():
	# primero deja de ser enemigo y de hacer daño; después se desvanece
	remove_from_group("enemigos")
	set_deferred("monitoring", false)
	set_process(false)
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 0.3, 0.3, 0), 0.2)
	tween.tween_callback(queue_free)
