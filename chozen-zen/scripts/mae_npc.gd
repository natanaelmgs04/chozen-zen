extends CharacterBody2D

## Mãe: circula entre pontos da casa com pausas; quando o jogador chega perto,
## para e se vira para ele (RF-MOV-003). A fase pode levá-la a um lugar fixo (ex.: o jantar).

signal talk_requested

const WALK_SPEED := 45.0
const ARRIVE_DISTANCE := 4.0

@export var waypoints: Array[Vector2] = []
@export var pause_range := Vector2(1.5, 3.5)

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var prompt: Label = $Prompt
@onready var interaction_area: Area2D = $InteractionArea
@onready var emote: Label = $Emote

var _noticed := false
## Em cutscene a fase controla a mãe (andar, virar); a rotina dela fica suspensa.
var scripted := false:
	set(value):
		scripted = value
		if scripted:
			_walking = false
			velocity = Vector2.ZERO
var _script_tween: Tween
## Sentada (no jantar): fica parada na pose, sem a rotina de andar nem virar para o jogador.
var sentada := false
var _sentar_ao_chegar := false

var can_talk := true:
	set(value):
		can_talk = value
		prompt.visible = can_talk and _player != null

var _player: Node2D
var _facing := "down"
var _path: Array[Vector2] = []
var _target := Vector2.ZERO
var _walking := false
var _settled := false
var _settle_face := "down"
var _pause_left := 0.0
var _walk_time_left := 0.0

func _ready() -> void:
	prompt.visible = false
	interaction_area.body_entered.connect(_on_body_entered)
	interaction_area.body_exited.connect(_on_body_exited)
	_pause_left = randf_range(pause_range.x, pause_range.y)

## Caminha pelos pontos em ordem e fica no último, virada para `face` (e senta, se pedido).
func settle_at(path: Array[Vector2], face: String, sit := false) -> void:
	_path = path.duplicate()
	_settled = true
	_settle_face = face
	_sentar_ao_chegar = sit
	_start_walking(_path.pop_front())

## Anda até um ponto, sem física (usada nas cenas antes e depois das enquetes).
func walk_to(target: Vector2, speed := 110.0) -> void:
	scripted = true
	var direction := target - global_position
	_face(direction)
	sprite.play("walk_" + _facing)
	_script_tween = create_tween()
	_script_tween.tween_property(self, "global_position", target, maxf(direction.length() / speed, 0.05))
	await _script_tween.finished
	sprite.play("idle_" + _facing)

func face(direction: String) -> void:
	_facing = direction
	sprite.play(("sit_" if sentada else "idle_") + _facing)

func sentar(direcao: String) -> void:
	sentada = true
	_walking = false
	_facing = direcao
	sprite.play("sit_" + direcao)

## O último trecho até a cadeira é feito sem física (a cadeira tem colisão).
func _sentar_no_lugar() -> void:
	await walk_to(_target, 80.0)
	scripted = false
	sentar(_settle_face)

## Levanta; com `saida`, antes sai da cadeira (sem física) para não ficar presa nela.
func levantar(saida := Vector2.INF) -> void:
	sentada = false
	_settled = false
	_sentar_ao_chegar = false
	sprite.play("idle_" + _facing)
	if saida != Vector2.INF:
		await walk_to(saida, 90.0)
		scripted = false

func comer(ligado: bool) -> void:
	if sentada:
		sprite.play(("eat_" if ligado else "sit_") + _facing)

func face_towards(point: Vector2) -> void:
	_face(point - global_position)
	sprite.play("idle_" + _facing)

func _physics_process(delta: float) -> void:
	if scripted or sentada:
		return
	if _player and not _walking:
		_face(_player.global_position - global_position)
		sprite.play("idle_" + _facing)
		return
	if not _walking:
		sprite.play("idle_" + _facing)
		if _settled:
			return
		_pause_left -= delta
		if _pause_left <= 0.0:
			_pick_next_waypoint()
		return
	var to_target := _target - global_position
	_walk_time_left -= delta
	# Desiste do ponto se ficar bloqueada (ex.: o jogador no caminho).
	if to_target.length() <= ARRIVE_DISTANCE or _walk_time_left <= 0.0:
		_arrive()
		return
	velocity = to_target.normalized() * WALK_SPEED
	move_and_slide()
	_face(velocity)
	sprite.play("walk_" + _facing)

func _arrive() -> void:
	_walking = false
	if not _path.is_empty():
		_start_walking(_path.pop_front())
	elif _settled:
		_facing = _settle_face
		if _sentar_ao_chegar:
			_sentar_no_lugar()
	else:
		_pause_left = randf_range(pause_range.x, pause_range.y)

func _pick_next_waypoint() -> void:
	var candidates := waypoints.filter(func(p: Vector2) -> bool: return p.distance_to(global_position) > 24.0)
	if candidates.is_empty():
		_pause_left = randf_range(pause_range.x, pause_range.y)
		return
	_start_walking(candidates.pick_random())

func _start_walking(target: Vector2) -> void:
	_target = target
	_walk_time_left = target.distance_to(global_position) / WALK_SPEED + 1.5
	_walking = true

func _face(direction: Vector2) -> void:
	if direction.length_squared() < 0.01:
		return
	if absf(direction.x) > absf(direction.y):
		_facing = "right" if direction.x > 0 else "left"
	else:
		_facing = "down" if direction.y > 0 else "up"

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	_player = body
	if not _settled:
		_walking = false
	prompt.visible = can_talk
	if can_talk and not _noticed:
		_noticed = true
		_emote("!")

func _emote(text: String) -> void:
	emote.text = text
	emote.visible = true
	emote.scale = Vector2.ZERO
	var tween := create_tween()
	tween.tween_property(emote, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_interval(1.2)
	tween.tween_property(emote, "modulate:a", 0.0, 0.3)
	tween.tween_callback(func() -> void:
		emote.visible = false
		emote.modulate.a = 1.0)

func _on_body_exited(body: Node2D) -> void:
	if body == _player:
		_player = null
		prompt.visible = false
		_pause_left = randf_range(pause_range.x, pause_range.y)

func _unhandled_input(event: InputEvent) -> void:
	if _player and can_talk and event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		can_talk = false
		talk_requested.emit()
