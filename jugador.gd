extends CharacterBody2D
# Solución del Taller 3 (solo profesor).

@export var speed = 220.0            # px/s
@export var gravedad = 1200.0        # px/s²
@export var salto = 560.0            # px/s hacia arriba
@export var velocidad_rodar = 400.0  # px/s

var mirando = 1                      # 1 derecha, -1 izquierda
var rodando = false
var inicio = Vector2.ZERO
var muriendo = false

@onready var sprite = $AnimatedSprite2D
@onready var golpe = $Golpe     # el área que golpea con la espada
@onready var sonido_espada = $Espada
@onready var sonido_rodar = $Rodar
@onready var sonido_muerte = $Muerte
@onready var camara = $Camera2D


func _ready():
	inicio = position


func _physics_process(delta):
	if muriendo:
		return
	if rodando:
		# mientras rueda, no se lee el teclado: sigue derecho
		velocity.x = velocidad_rodar * mirando
		if not is_on_floor():
			velocity.y += gravedad * delta
		move_and_slide()
		return
	if Input.is_action_just_pressed("rodar") and is_on_floor():
		rodar()
		return
	mover(delta)
	actualizar_animacion()
	orientar()
	# la cámara se adelanta poco a poco hacia donde mira, como en Dead Cells
	camara.offset.x = move_toward(camara.offset.x, 80 * mirando, 240 * delta)
	if Input.is_action_just_pressed("atacar"):
		atacar()


func mover(delta):
	if not is_on_floor():
		velocity.y += gravedad * delta
	if Input.is_action_just_pressed("saltar") and is_on_floor():
		velocity.y = -salto
	velocity.x = Input.get_axis("move_left", "move_right") * speed
	move_and_slide()


# Nivel 1 (y nivel 3: speed_scale)
func actualizar_animacion():
	var real = get_real_velocity()
	sprite.speed_scale = 1.0
	if not is_on_floor():
		sprite.play("saltar" if real.y < 0 else "caer")
	elif abs(real.x) > 1.0:
		sprite.play("correr")
		sprite.speed_scale = abs(real.x) / speed
	else:
		sprite.play("quieto")


# Nivel 2
func orientar():
	var eje = Input.get_axis("move_left", "move_right")
	if eje != 0:
		mirando = sign(eje)
	sprite.flip_h = mirando < 0
	golpe.position.x = 36 * mirando   # flip_h no mueve a los hijos: el área del golpe hay que moverla


func atacar():
	sonido_espada.play()   # cada golpe es un sonido nuevo: aquí sí se reinicia
	# un tajo corto que se ve solo una décima de segundo
	$Golpe/ColorRect.show()
	await get_tree().create_timer(0.1).timeout
	$Golpe/ColorRect.hide()


# Nivel 3
func rodar():
	rodando = true
	sprite.speed_scale = 1.0
	sprite.play("rodar")
	sonido_rodar.play()
	await sprite.animation_finished
	rodando = false


# Ya viene escrita para el Taller 4.
func morir():
	muriendo = true
	rodando = false
	velocity = Vector2.ZERO
	sprite.speed_scale = 1.0
	sprite.play("morir")
	sonido_muerte.play()
	await sprite.animation_finished
	position = inicio
	sprite.play("quieto")
	muriendo = false
