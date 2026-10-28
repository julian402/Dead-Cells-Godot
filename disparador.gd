extends Area3D
# Tarea B nivel 2: representa el "golpe recibido" (todavia no existe en el juego)
# Solo avisa con la senal, no sabe que luz lo escucha

signal golpe(posicion)


func _ready():
	body_entered.connect(_on_body_entered)


func _on_body_entered(_cuerpo):
	golpe.emit(global_position)


# tecla T para probar sin caminar hasta la trampa
func _input(event):
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_T:
		golpe.emit(global_position)
