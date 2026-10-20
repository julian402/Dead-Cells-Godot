extends Area2D
# Script compartido por células y pergaminos. Solo avisa: el Mundo decide.

signal recogido(valor, da_poder)

@export var valor = 1
@export var da_poder = false


func _ready():
	body_entered.connect(_on_body_entered)


func _on_body_entered(body):
	if body.is_in_group("jugador"):
		# Arreglo de la victoria: salir del grupo ANTES de avisar,
		# porque queue_free() solo borra el nodo al final del frame.
		remove_from_group("celulas")
		recogido.emit(valor, da_poder)
		queue_free()
