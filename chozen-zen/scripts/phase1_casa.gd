extends Node2D

## Fase 1 — Família: "Uma noite em casa" (spec 003).
## Objetivo: terminar o dia no quarto. Momentos: chegada -> jantar -> noite -> resumo do dia.
## Energia 0 depois de um momento = o personagem apaga e o capítulo acaba antes.

enum Momento { INTRO, CHEGADA, JANTAR, NOITE, FIM }

const MAIN_MENU := "res://scenes/main_menu.tscn"
const MARCADOR_MESA := Vector2(1176, 360)
const MARCADOR_PORTA := Vector2(1120, 130)
const MESA := Vector2(1176, 470)
const PORTA_QUARTO := Vector2(1120, 212)
const ZOOM_CONVERSA := 1.15
## Emenda com o fim da cutscene: ele entra pela porta da frente.
const PORTA_DE_ENTRADA := Vector2(1153, 950)
const INICIO := Vector2(1153, 800)
const INTERVALO_DICAS := 3.4

## Luz conta a passagem do tempo: fim de tarde -> anoitecer -> noite.
const LUZ := {
	Momento.CHEGADA: {"ambiente": Color(1.0, 0.94, 0.86), "Abajur": 0.25, "Jantar": 0.0, "Cozinha": 0.35, "Corredor": 0.0},
	Momento.JANTAR: {"ambiente": Color(0.8, 0.73, 0.76), "Abajur": 0.65, "Jantar": 0.95, "Cozinha": 0.4, "Corredor": 0.15},
	Momento.NOITE: {"ambiente": Color(0.4, 0.44, 0.66), "Abajur": 0.95, "Jantar": 0.2, "Cozinha": 0.1, "Corredor": 0.75},
}

@onready var mae: CharacterBody2D = $Entities/Mae
@onready var player: CharacterBody2D = $Entities/Player
@onready var camera: Camera2D = $Entities/Player/Camera2D
@onready var ambiente: CanvasModulate = $Ambiente
@onready var hud: CanvasLayer = $HUD
@onready var decision_ui: CanvasLayer = $DecisionUI
@onready var story_card: CanvasLayer = $StoryCard
@onready var marker: Node2D = $ObjectiveMarker
@onready var zona_jantar: Area2D = $Zonas/Jantar
@onready var zona_quarto: Area2D = $Zonas/Quarto
@onready var zona_geladeira: Area2D = $Zonas/Geladeira

var momento := Momento.INTRO
## A casa em peças (tools/make_casa.py): móveis, colisões, assentos e interações.
var casa := Casa.new()
var _abajur_forcado := false
var diretor: DiretorCasa
## Somado ao enquadramento (o diretor usa para tremer a tela).
var tremor := Vector2.ZERO
var _camera_presa := false
var _foco_camera := Vector2.ZERO
var _tween_camera: Tween
var cenas: Fase1Cenas
var _evento_atual := ""
var _acoes_do_cartao: Array[Callable] = []

func _ready() -> void:
	GameState.start_chapter()
	Audio.play_music()
	Audio.play_ambience(Audio.AMB_DAY)
	Audio.set_music_muffled(false)
	add_child(casa)
	casa.montar($Entities, $Colisoes, $Zonas, player, hud)
	_posicionar_pela_casa()
	casa.abajur_mudou.connect(_on_abajur_mudou)
	_aplicar_luz(Momento.CHEGADA, 0.0)
	diretor = DiretorCasa.new(self, player, mae)
	add_child(diretor)
	cenas = Fase1Cenas.new(diretor, casa)
	decision_ui.before_result = func(opcao: Dictionary) -> void:
		_focar_camera(_centro_da_cena(), false, _zoom_da_cena())
		_mostrar_stats(false)
		await diretor.tocar(cenas.depois.bind(opcao))
		_mostrar_stats(true)
	decision_ui.chosen.connect(_on_option_chosen)
	mae.talk_requested.connect(_on_mae_talk_requested)
	zona_jantar.entered_by_player.connect(_on_zona_jantar)
	zona_quarto.entered_by_player.connect(_on_zona_quarto)
	zona_geladeira.interacted.connect(_on_geladeira)
	decision_ui.closed.connect(_on_decision_closed)
	story_card.button_pressed.connect(func(i: int) -> void: _acoes_do_cartao[i].call())
	GameState.reputation_changed.connect(_on_reputation_changed)
	mae.can_talk = false
	marker.visible = false
	hud.set_objective("")
	_entrar_em_casa()

func _entrar_em_casa() -> void:
	player.global_position = PORTA_DE_ENTRADA
	camera.reset_smoothing()
	player.modulate.a = 0.0
	create_tween().tween_property(player, "modulate:a", 1.0, 0.35)
	await player.walk_to(INICIO)
	_comecar()

## Também usado pelas ferramentas de captura para pular a entrada.
func pular_entrada() -> void:
	player.stop_walk()
	player.global_position = INICIO
	player.modulate.a = 1.0
	camera.reset_smoothing()
	_comecar()

func _comecar() -> void:
	if momento != Momento.INTRO:
		return
	_set_momento(Momento.CHEGADA)
	# Abertura de episódio: faixas diagonais e o título letra a letra.
	await diretor.letreiros.capitulo("Capítulo 1", "Família", Fase1Roteiro.SUBTITULO)
	player.lock_input(false)
	_mostrar_dicas()

func _mostrar_dicas() -> void:
	await _espera(2.6)
	for dica in Fase1Roteiro.DICAS:
		if _evento_atual != "" or momento != Momento.CHEGADA:
			return
		hud.toast(dica)
		await _espera(INTERVALO_DICAS)

## Espera presa à cena: se a fase for reiniciada, a espera morre junto.
func _espera(segundos: float) -> void:
	var timer := Timer.new()
	timer.one_shot = true
	add_child(timer)
	timer.start(segundos)
	await timer.timeout
	timer.queue_free()

## Zonas, luzes e o caminho da mãe vêm da ficha da casa (mudou o mapa, muda tudo junto).
func _posicionar_pela_casa() -> void:
	var ficha := casa.ficha
	for nome in ficha["zonas"]:
		var r: Array = ficha["zonas"][nome]
		var zona: Area2D = get_node("Zonas/" + nome)
		zona.position = Vector2(r[0] + r[2] / 2.0, r[1] + r[3] / 2.0)
		(zona.get_node("CollisionShape2D").shape as RectangleShape2D).size = Vector2(r[2], r[3])
	for nome in ficha["luzes"]:
		get_node("Luzes/" + nome).position = Vector2(ficha["luzes"][nome][0], ficha["luzes"][nome][1])
	var caminho: Array[Vector2] = []
	for p in ficha["mae_caminho"]:
		caminho.append(Vector2(p[0], p[1]))
	mae.waypoints = caminho
	mae.global_position = caminho[0]

func _caminho_da_mae_ate_a_mesa() -> Array[Vector2]:
	var caminho: Array[Vector2] = []
	for p in casa.ficha["mae_jantar"]:
		caminho.append(Vector2(p[0], p[1]))
	return caminho

func _on_abajur_mudou(aceso: bool) -> void:
	_abajur_forcado = true
	create_tween().tween_property($Luzes/Abajur, "energy", 1.1 if aceso else 0.0, 0.25)

func is_night() -> bool:
	return momento >= Momento.NOITE

func _set_momento(novo: Momento) -> void:
	momento = novo
	_aplicar_luz(novo, 2.5)
	match novo:
		Momento.CHEGADA:
			mae.can_talk = true
			hud.set_objective("Fale com sua mãe")
			marker.point_at_node(mae, 150.0)
		Momento.JANTAR:
			# a mãe põe a mesa e senta na cabeceira para jantar
			casa.mesa_posta(true)
			mae.settle_at(_caminho_da_mae_ate_a_mesa(), "right", true)
			hud.set_objective("Jante com sua mãe (mesa de jantar)")
			marker.point_at(MARCADOR_MESA)
			if zona_jantar.player_inside:
				_on_zona_jantar.call_deferred()
		Momento.NOITE:
			hud.set_objective("Vá para o seu quarto (porta do corredor)")
			mae.levantar(Vector2(984, 560))
			Audio.play_ambience(Audio.AMB_NIGHT, 3.0)
			Audio.set_music_muffled(true, 3.0)
			marker.point_at(MARCADOR_PORTA)
			if zona_quarto.player_inside:
				_on_zona_quarto.call_deferred()
		Momento.FIM:
			mae.can_talk = false
			hud.set_objective("")
			marker.visible = false

func _aplicar_luz(alvo: Momento, segundos: float) -> void:
	if not LUZ.has(alvo):
		return
	var preset: Dictionary = LUZ[alvo]
	var tween := create_tween().set_parallel()
	tween.tween_property(ambiente, "color", preset["ambiente"], segundos)
	for luz in ["Abajur", "Jantar", "Cozinha", "Corredor"]:
		if luz == "Abajur" and _abajur_forcado:
			continue
		tween.tween_property(get_node("Luzes/" + luz), "energy", preset[luz], segundos)

## Cena curta mostrando a situação → enquete → (cena da escolha → resultado, no DecisionUI).
func _abrir_evento(id: String, evento: Dictionary, foco: Vector2, variante := "") -> void:
	_evento_atual = id
	marker.visible = false
	casa.ativar_zonas(false)
	_mostrar_objetivo(false)
	_mostrar_stats(false)
	_focar_camera(_centro_da_cena(), false, _zoom_da_cena())
	await diretor.comecar()
	await diretor.tocar(cenas.antes.bind(id, variante))
	if momento == Momento.FIM:
		return
	_mostrar_stats(true)
	_focar_camera(foco)
	decision_ui.show_event(evento)

## Onde a câmera olha durante as cenas curtas: os dois personagens, centralizados.
func _centro_da_cena() -> Vector2:
	match _evento_atual:
		"chegada":
			return (player.global_position + mae.global_position) / 2 + Vector2(0, -60)
		"jantar":
			return Vector2(1176, 470)
		_:
			return player.global_position + Vector2(0, -90)

## A porta do quarto fica no canto da casa: só um close mais fechado deixa ele no centro.
func _zoom_da_cena() -> float:
	return 1.9 if _evento_atual == "noite" else ZOOM_CONVERSA

## Na cena o HUD sai de cena (tela limpa, como no cinema); volta na enquete e no resultado.
func _mostrar_stats(mostrar: bool) -> void:
	# roda mesmo com o jogo pausado pela enquete
	create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).tween_property(hud.stats, "modulate:a", 1.0 if mostrar else 0.0, 0.3)

func _mostrar_objetivo(mostrar: bool) -> void:
	create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).tween_property(hud.objective_panel, "modulate:a", 1.0 if mostrar else 0.0, 0.3)

## Aproxima a câmera no que importa e a prende num ponto da casa (mesmo se o jogador andar
## numa cena). `acima_do_painel`: na enquete o alvo sobe para não ficar atrás do painel central.
func _focar_camera(alvo: Vector2, acima_do_painel := true, zoom := ZOOM_CONVERSA) -> void:
	var destino := alvo + (Vector2(0, 110) if acima_do_painel else Vector2.ZERO)
	if not _camera_presa:
		_foco_camera = player.global_position + camera.offset
		_camera_presa = true
	if _tween_camera:
		_tween_camera.kill()
	_tween_camera = create_tween().set_parallel().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_tween_camera.tween_property(camera, "zoom", Vector2.ONE * zoom, 0.7).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_tween_camera.tween_method(_mirar_camera, _foco_camera, destino, 0.7).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _mirar_camera(ponto: Vector2) -> void:
	_foco_camera = ponto
	camera.offset = _offset_dentro_dos_limites(ponto, camera.zoom.x) + tremor

func _process(_delta: float) -> void:
	if _camera_presa:
		_mirar_camera(_foco_camera)

func _soltar_camera() -> void:
	_camera_presa = false
	if _tween_camera:
		_tween_camera.kill()
	var tween := create_tween().set_parallel().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(camera, "zoom", Vector2.ONE, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(camera, "offset", Vector2.ZERO, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

## O offset da câmera não respeita os limites sozinho; sem isso aparece a área fora da casa.
## E a posição-base da câmera já vem presa pelos limites (perto das paredes ela não segue o
## jogador), então o offset é calculado a partir dessa base, não da posição do jogador.
func _offset_dentro_dos_limites(centro: Vector2, zoom: float) -> Vector2:
	var meia_tela := get_viewport_rect().size / (2.0 * zoom)
	return _dentro_dos_limites(centro, meia_tela) - _dentro_dos_limites(player.global_position, meia_tela)

func _dentro_dos_limites(ponto: Vector2, meia_tela: Vector2) -> Vector2:
	ponto.x = clampf(ponto.x, camera.limit_left + meia_tela.x, camera.limit_right - meia_tela.x)
	ponto.y = clampf(ponto.y, camera.limit_top + meia_tela.y, camera.limit_bottom - meia_tela.y)
	return ponto

func _on_option_chosen(option: Dictionary) -> void:
	var flag: String = option.get("flag", "")
	if Fase1Roteiro.MEMORIAS.has(flag):
		await get_tree().create_timer(0.45).timeout
		hud.memory(Fase1Roteiro.MEMORIAS[flag])

func _on_mae_talk_requested() -> void:
	if momento == Momento.CHEGADA:
		_abrir_evento("chegada", Fase1Roteiro.chegada(false), mae.global_position)

func _on_zona_quarto() -> void:
	match momento:
		Momento.CHEGADA:
			mae.can_talk = false
			_abrir_evento("chegada", Fase1Roteiro.chegada(true), mae.global_position, "corredor")
		Momento.JANTAR:
			hud.toast("Sua mãe está te chamando para jantar.")
		Momento.NOITE:
			_abrir_evento("noite", Fase1Roteiro.NOITE, PORTA_QUARTO)

func _on_zona_jantar() -> void:
	if momento == Momento.JANTAR:
		_abrir_evento("jantar", Fase1Roteiro.jantar(), MESA)

func _on_geladeira() -> void:
	zona_geladeira.enabled = false
	casa.abrir_geladeira()
	GameState.apply_energy_delta(Fase1Roteiro.LANCHE_ENERGIA)
	hud.toast("+%d Energia: um lanche rápido ajudou." % Fase1Roteiro.LANCHE_ENERGIA)

func _on_decision_closed(_option: Dictionary) -> void:
	diretor.terminar()
	casa.ativar_zonas(true)
	_mostrar_objetivo(true)
	_soltar_camera()
	if momento == Momento.FIM:
		return
	if _evento_atual == "noite":
		_fim_do_dia(false)
	elif GameState.energy <= 0:
		player.lock_input(true)
		diretor.emote(player, "zzz", 1.4)
		await _espera(1.5)
		_fim_do_dia(true)
	elif _evento_atual == "chegada":
		_set_momento(Momento.JANTAR)
	elif _evento_atual == "jantar":
		_set_momento(Momento.NOITE)

func _on_reputation_changed(value: int) -> void:
	if value > 0 or momento == Momento.FIM:
		return
	# RF-AGE-004: a tela de fim aparece na hora, sem esperar o jogador.
	_set_momento(Momento.FIM)
	decision_ui.hide_panel()
	_mostrar_cartao("Caiu em desgraça", Fase1Roteiro.TITULO,
		"Sua reputação chegou a [b]0%[/b]. Ninguém mais confia em você, e esta vida chega ao fim.",
		{"Jogar de novo": _jogar_de_novo, "Menu principal": _ir_para_menu})

func _fim_do_dia(apagou: bool) -> void:
	_set_momento(Momento.FIM)
	var corpo := ""
	if apagou:
		corpo += "Sua Energia acabou. Você sentou no sofá por um minuto... e só acordou de manhã.\n\n"
	corpo += "[b]O que vem amanhã:[/b]\n" + Fase1Roteiro.resumo(apagou)
	corpo += "\n\n[b]Reputação:[/b] %d%%     [b]Energia:[/b] %d" % [GameState.reputation, GameState.energy]
	_mostrar_cartao("Você apagou de sono" if apagou else "Fim do dia", Fase1Roteiro.SUBTITULO, corpo,
		{"Jogar de novo": _jogar_de_novo, "Menu principal": _ir_para_menu}, Fase1Roteiro.FIM_DA_DEMO)

func _mostrar_cartao(titulo: String, subtitulo: String, corpo: String, botoes: Dictionary, rodape := "") -> void:
	_acoes_do_cartao.assign(botoes.values())
	var nomes: Array[String] = []
	nomes.assign(botoes.keys())
	story_card.show_card(titulo, subtitulo, corpo, nomes, rodape)

func _jogar_de_novo() -> void:
	GameState.reset()
	Transition.reload()

func _ir_para_menu() -> void:
	Transition.change_scene(MAIN_MENU)
