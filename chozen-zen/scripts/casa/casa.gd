class_name Casa
extends Node

## Monta a casa a partir de assets/casa/casa.json (gerada por tools/make_casa.py):
## móveis como sprites ordenados por profundidade (dá para passar atrás do sofá e sentar à
## mesa), colisões, assentos e interações (abajur, TV, estante, foto, plantas, pia).

signal abajur_mudou(aceso: bool)

const FICHA := "res://assets/casa/casa.json"
const ZONA_ASSENTO := Vector2(76, 76)
const TRIGGER := preload("res://scripts/trigger_zone.gd")

var ficha: Dictionary
var objetos := {}
var assentos := {}        # nome do móvel -> Array de assentos {pos, dir, saida}
var abajur_aceso := false

var _player: CharacterBody2D
var _hud: CanvasLayer
var _zonas_assento: Array[Area2D] = []
var _zonas: Array[Area2D] = []
var _zonas_ativas := true
var _tv_ligada := false
var _tv_tween: Tween
var _falas_vistas := {}

func montar(entidades: Node2D, corpo: StaticBody2D, zonas: Node2D, player: CharacterBody2D, hud: CanvasLayer) -> void:
	ficha = (load(FICHA) as JSON).data
	_player = player
	_hud = hud
	for o: Dictionary in ficha["objetos"]:
		var sprite := Sprite2D.new()
		sprite.name = o["nome"]
		sprite.centered = false
		sprite.texture = load(o["png"])
		sprite.position = _v(o["pos"])
		sprite.offset = _v(o["offset"])
		entidades.add_child(sprite)
		objetos[o["nome"]] = sprite
		if o.has("colisao"):
			_retangulo(corpo, o["colisao"])
		if o.has("interacao"):
			_zona(zonas, o["interacao"], o["nome"])
		if o.has("assentos"):
			assentos[o["nome"]] = o["assentos"]
		if o.has("assento"):
			assentos[o["nome"]] = [o["assento"]]
			_zona(zonas, {"tipo": "sentar", "texto": "[E] Sentar",
				"zona": [o["assento"]["pos"][0] - ZONA_ASSENTO.x / 2, o["assento"]["pos"][1] - ZONA_ASSENTO.y / 2, ZONA_ASSENTO.x, ZONA_ASSENTO.y]}, o["nome"])
		match o.get("decoracao", ""):
			"relogio":
				sprite.add_child(_ponteiros())
			"tv":
				sprite.visible = false
	for r in ficha["paredes"]:
		_retangulo(corpo, r)
	for i: Dictionary in ficha["interacoes"]:
		_zona(zonas, i, "")
	_player.levantou.connect(_on_levantou)

## Assento livre mais perto de um ponto, num móvel com assentos.
func assento(movel: String, perto_de := Vector2.ZERO) -> Dictionary:
	var lista: Array = assentos.get(movel, [])
	var melhor := {}
	var menor := INF
	for a: Dictionary in lista:
		var d := _v(a["pos"]).distance_to(perto_de)
		if d < menor:
			menor = d
			melhor = a
	return melhor

## A mesa posta (pratos e panela) no jantar.
func mesa_posta(posta: bool) -> void:
	var mesa: Sprite2D = objetos["mesa_jantar"]
	var alternativo := ""
	for o: Dictionary in ficha["objetos"]:
		if o["nome"] == "mesa_jantar":
			alternativo = o["alternativo"]
	mesa.texture = load(alternativo if posta else "res://assets/casa/mesa_jantar.png")
	if posta and not mesa.has_node("Vapor"):
		mesa.add_child(_vapor(mesa.offset + Vector2(126, 52)))

func abrir_geladeira() -> void:
	var geladeira: Sprite2D = objetos["geladeira"]
	Audio.sfx("door", -8.0, 0.1)
	geladeira.texture = load("res://assets/casa/geladeira_aberta.png")
	await get_tree().create_timer(1.3).timeout
	geladeira.texture = load("res://assets/casa/geladeira.png")

## Durante as cutscenes nenhuma interação da casa aparece nem responde.
func ativar_zonas(ativo: bool) -> void:
	_zonas_ativas = ativo
	for zona in _zonas:
		zona.enabled = ativo and not (_player.sentado and zona in _zonas_assento)

func ativar_assentos(ativo: bool) -> void:
	for zona in _zonas_assento:
		zona.enabled = ativo

# --- interações ---------------------------------------------------------------------

func _on_interagiu(dados: Dictionary, movel: String) -> void:
	if _player.sentado:
		return
	match dados["tipo"]:
		"sentar":
			var a := assento(movel, _player.global_position)
			if a.is_empty():
				return
			ativar_assentos(false)
			_hud.toast("E ou mover: levantar")
			_player.sentar(_v(a["pos"]), a["dir"], _v(a["saida"]))
		"abajur":
			_alternar_abajur()
		"tv":
			_alternar_tv()
		"texto", "pia":
			_falar(dados)

func _on_levantou() -> void:
	if _zonas_ativas:
		ativar_assentos(true)

func _alternar_abajur() -> void:
	abajur_aceso = not abajur_aceso
	Audio.sfx("click")
	var sprite: Sprite2D = objetos["abajur"]
	sprite.texture = load("res://assets/casa/abajur_aceso.png" if abajur_aceso else "res://assets/casa/abajur.png")
	abajur_mudou.emit(abajur_aceso)

func _alternar_tv() -> void:
	_tv_ligada = not _tv_ligada
	var tela: Sprite2D = objetos["tv_tela"]
	Audio.sfx("click")
	if _tv_tween:
		_tv_tween.kill()
	tela.visible = _tv_ligada
	if _tv_ligada:
		Audio.sfx("swoosh", -10.0)
		_hud.toast(["Um programa de culinária. A apresentadora sorri demais.", "O jornal fala da previsão do tempo. Amanhã vai chover.", "Desenho animado. Você assistia isso quando era criança."].pick_random())
		# a tela "pisca" trocando de imagem, como uma TV de verdade
		_tv_tween = create_tween().set_loops()
		for cor in [Color(1, 1, 1), Color(0.8, 0.9, 1), Color(1, 0.92, 0.85), Color(0.9, 1, 0.92)]:
			_tv_tween.tween_property(tela, "modulate", cor, 0.6)

func _falar(dados: Dictionary) -> void:
	var falas: Array = dados.get("falas", [])
	if falas.is_empty():
		return
	var chave: String = dados["texto"]
	var i: int = _falas_vistas.get(chave, 0)
	_hud.toast(falas[i % falas.size()])
	_falas_vistas[chave] = i + 1
	if dados["tipo"] == "pia":
		Audio.sfx("paper", -12.0, 0.2)

# --- construção ---------------------------------------------------------------------

func _retangulo(corpo: StaticBody2D, r: Array) -> void:
	var forma := RectangleShape2D.new()
	forma.size = Vector2(r[2], r[3])
	var colisao := CollisionShape2D.new()
	colisao.shape = forma
	colisao.position = Vector2(r[0] + r[2] / 2.0, r[1] + r[3] / 2.0)
	corpo.add_child(colisao)

func _zona(pai: Node2D, dados: Dictionary, movel: String) -> void:
	var zona := Area2D.new()
	zona.set_script(TRIGGER)
	zona.collision_layer = 0
	zona.collision_mask = 2
	zona.set("prompt_text", dados["texto"])
	var r: Array = dados["zona"]
	zona.position = Vector2(r[0] + r[2] / 2.0, r[1] + r[3] / 2.0)
	var forma := RectangleShape2D.new()
	forma.size = Vector2(r[2], r[3])
	var colisao := CollisionShape2D.new()
	colisao.shape = forma
	zona.add_child(colisao)
	var prompt := Label.new()
	prompt.name = "Prompt"
	prompt.visible = false
	prompt.z_index = 20
	prompt.theme_type_variation = &"WorldLabel"
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt.size = Vector2(320, 26)
	prompt.position = Vector2(-160, -r[3] / 2.0 - 70)
	zona.add_child(prompt)
	pai.add_child(zona)
	zona.interacted.connect(_on_interagiu.bind(dados, movel))
	_zonas.append(zona)
	if dados["tipo"] == "sentar":
		_zonas_assento.append(zona)

func _ponteiros() -> Node2D:
	var relogio := Node2D.new()
	relogio.position = Vector2(24, 24)
	relogio.set_script(preload("res://scripts/casa/relogio.gd"))
	return relogio

func _vapor(pos: Vector2) -> CPUParticles2D:
	var vapor := CPUParticles2D.new()
	vapor.name = "Vapor"
	vapor.position = pos
	vapor.amount = 10
	vapor.lifetime = 1.8
	vapor.direction = Vector2(0, -1)
	vapor.spread = 15.0
	vapor.gravity = Vector2(4, -10)
	vapor.initial_velocity_min = 12.0
	vapor.initial_velocity_max = 22.0
	vapor.scale_amount_min = 4.0
	vapor.scale_amount_max = 7.0
	vapor.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	vapor.emission_rect_extents = Vector2(10, 2)
	var fade := Gradient.new()
	fade.set_color(0, Color(1, 1, 1, 0.55))
	fade.set_color(1, Color(1, 1, 1, 0))
	vapor.color_ramp = fade
	return vapor

func _v(a: Array) -> Vector2:
	return Vector2(a[0], a[1])
