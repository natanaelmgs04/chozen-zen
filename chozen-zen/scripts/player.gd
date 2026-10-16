extends CharacterBody2D

## Movimento com aceleração/desaceleração, passos sonoros sincronizados com a animação
## e um squash & stretch sutil a cada passo (princípios de animação).

const SPEED := 130.0
const ACCELERATION := 900.0
const FRICTION := 1100.0
const STEP_FRAMES := [0, 2]
const STEP_SQUASH := Vector2(1.04, 0.96)

signal levantou

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

## Sentado em sofá/cadeira. `pode_levantar` = false enquanto uma cutscene controla a cena.
var sentado := false
var pode_levantar := true
var _saida := Vector2.ZERO

var _facing := "up"
var _input_locked := false
var _walk_tween: Tween

func _ready() -> void:
	add_to_group("player")
	sprite.frame_changed.connect(_on_frame_changed)

func lock_input(locked: bool) -> void:
	_input_locked = locked
	if locked:
		velocity = Vector2.ZERO
		sprite.play("idle_%s" % _facing)

## Anda sozinho até um ponto, sem física (entrada na fase e momentos roteirizados).
func walk_to(target: Vector2, speed := SPEED * 0.7) -> void:
	lock_input(true)
	var direction := target - global_position
	if absf(direction.x) > absf(direction.y):
		_facing = "right" if direction.x > 0 else "left"
	else:
		_facing = "down" if direction.y > 0 else "up"
	sprite.play("walk_%s" % _facing)
	_walk_tween = create_tween()
	_walk_tween.tween_property(self, "global_position", target, direction.length() / speed)
	await _walk_tween.finished
	sprite.play("idle_%s" % _facing)

## Anda até o assento e senta virado para `direcao` ("down", "up", "left", "right").
func sentar(assento: Vector2, direcao: String, saida: Vector2) -> void:
	lock_input(true)
	_saida = saida
	await walk_to(assento, SPEED * 0.9)
	_facing = direcao
	sprite.play("sit_" + direcao)
	sentado = true

func levantar() -> void:
	if not sentado:
		return
	sentado = false
	sprite.play("idle_" + _facing)
	await walk_to(_saida, SPEED * 0.9)
	lock_input(false)
	levantou.emit()

## Comer sentado (de lado): leva o garfo à boca em loop.
func comer(ligado: bool) -> void:
	if sentado and _facing in ["left", "right"]:
		sprite.play(("eat_" if ligado else "sit_") + _facing)

func face(direction: String) -> void:
	_facing = direction
	sprite.play("idle_%s" % _facing)

func stop_walk() -> void:
	if _walk_tween:
		_walk_tween.kill()
	sprite.play("idle_%s" % _facing)

func _physics_process(delta: float) -> void:
	if sentado and pode_levantar:
		var mexeu := Input.get_vector("move_left", "move_right", "move_up", "move_down") != Vector2.ZERO
		if mexeu or Input.is_action_just_pressed("interact"):
			levantar()
		return
	if _input_locked:
		return
	var input_vector := Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	).limit_length(1.0)
	if input_vector == Vector2.ZERO:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	else:
		velocity = velocity.move_toward(input_vector * SPEED, ACCELERATION * delta)
	move_and_slide()
	_update_animation(input_vector)

func _update_animation(input_vector: Vector2) -> void:
	if input_vector == Vector2.ZERO:
		sprite.speed_scale = 1.0
		sprite.play("idle_%s" % _facing)
		return
	if absf(input_vector.x) > absf(input_vector.y):
		_facing = "right" if input_vector.x > 0 else "left"
	else:
		_facing = "down" if input_vector.y > 0 else "up"
	sprite.play("walk_%s" % _facing)
	sprite.speed_scale = clampf(velocity.length() / SPEED, 0.5, 1.0)

func _on_frame_changed() -> void:
	if not sprite.animation.begins_with("walk") or sprite.frame not in STEP_FRAMES:
		return
	Audio.step()
	sprite.scale = STEP_SQUASH
	create_tween().tween_property(sprite, "scale", Vector2.ONE, 0.14).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
