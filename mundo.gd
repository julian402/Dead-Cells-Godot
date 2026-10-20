extends "res://bloques.gd"
# Taller 4. construir() arma el nivel a partir del MAPA:
# "#" bloque, "." celula, "o" pergamino, "E" zombi, "V" zombi vertical.

const MAPA = [
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"            .            .              ",
	"      .              o          .       ",
	"   o                                    ",
	"#      .    #        V  ##   .         #",
	"#        .  #    E.     ##       E.    #",
	"########################################",
]

var celula_escena = preload("res://celula.tscn")
var pergamino_escena = preload("res://pergamino.tscn")
var zombi_escena = preload("res://zombi.tscn")

var puntaje = 0
var modo_poder = false
var vidas = 3
var terminado = false

@onready var jugador = $Prisionero


func _ready():
	construir()   # primero se crean las células y los zombis...
	for item in get_tree().get_nodes_in_group("celulas"):   # ...y después se conectan
		item.recogido.connect(_on_recogido)
	for enemigo in get_tree().get_nodes_in_group("enemigos"):
		enemigo.toco_al_jugador.connect(_on_enemigo_toco)
	$TimerPoder.timeout.connect(_on_timer_poder_timeout)
	actualizar_hud()


func construir():
	construir_bloques(MAPA, Color(0.3, 0.32, 0.4, 1))
	for fila in MAPA.size():
		for col in MAPA[fila].length():
			var escena = null
			match MAPA[fila][col]:
				".":
					escena = celula_escena
				"o":
					escena = pergamino_escena
				"E", "V":
					escena = zombi_escena
			if escena:
				var nodo = escena.instantiate()
				if MAPA[fila][col] == "V":
					nodo.eje = "y"
				nodo.position = Vector2(col + 0.5, fila + 0.5) * CELDA
				$Mapa.add_child(nodo)


# Nivel 2
func _on_recogido(valor, da_poder):
	puntaje += valor
	print("recogida: +", valor, "  puntaje: ", puntaje)
	if da_poder:
		activar_poder()
	# La célula ya se sacó del grupo antes de avisar, así que aquí sí da 0.
	if get_tree().get_nodes_in_group("celulas").size() == 0:
		$HUD/Mensaje.text = "¡Bioma limpio!"
		terminado = true
	actualizar_hud()


# Nivel 3: un solo Timer. start() reinicia la cuenta desde 8 s.
func activar_poder():
	modo_poder = true
	print("poder: sí (", Time.get_ticks_msec() / 1000.0, " s)")
	$TimerPoder.start()
	for enemigo in get_tree().get_nodes_in_group("enemigos"):
		enemigo.modulate = Color(0.4, 0.6, 1.0)


func _on_timer_poder_timeout():
	modo_poder = false
	print("poder: no (", Time.get_ticks_msec() / 1000.0, " s)")
	for enemigo in get_tree().get_nodes_in_group("enemigos"):
		enemigo.modulate = Color(1, 1, 1)


func _on_enemigo_toco(enemigo):
	# 1. Si el Prisionero está muriendo o rodando, o el juego ya terminó, no pasa nada.
	if jugador.muriendo or jugador.rodando or terminado:
		return
	# 2. Con poder: el zombi vuelve a casa y suman 200.
	if modo_poder:
		enemigo.volver_a_casa()
		puntaje += 200
		print("zombi derrotado: +200")
	# 3. Sin poder: una vida menos.
	else:
		vidas -= 1
		print("vidas: ", vidas)
		if vidas <= 0:
			terminado = true
			$HUD/Mensaje.text = "Perdiste"
			jugador.set_physics_process(false)
			jugador.sprite.play("morir")
		else:
			jugador.morir()
	# 4. Actualicen el HUD.
	actualizar_hud()


func actualizar_hud():
	$HUD/Puntaje.text = "Células: %d" % puntaje
	$HUD/Vidas.text = "Vidas: %d" % vidas
