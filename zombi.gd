extends Area2D
# Zombi con vaivén. Solo avisa que tocó al jugador: el Mundo decide qué pasa.

signal toco_al_jugador(zombi)

@export var speed = 60.0        # px/s (con 0 se queda quieto)
@export var distancia = 96.0    # px hacia cada lado de su x inicial

var inicio_x = 0.0
var direccion = 1


func _ready():
	inicio_x = position.x
	body_entered.connect(_on_body_entered)


func _process(delta):
	position.x += speed * direccion * delta
	if abs(position.x - inicio_x) >= distancia:
		position.x = inicio_x + distancia * direccion
		direccion *= -1
	$Sprite2D.flip_h = direccion < 0


func _on_body_entered(body):
	if body.is_in_group("jugador"):
		toco_al_jugador.emit(self)


func volver_a_casa():
	position.x = inicio_x
	direccion = 1
