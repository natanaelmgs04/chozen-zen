extends Node

## Ferramenta de dev: carrega uma cena, simula ações, salva um PNG e fecha.
## Uso:
##   godot --path . res://tools/screenshot_runner.tscn -- --scene=res://scenes/phase1_casa.tscn
##       --out=C:/tmp/shot.png [--wait=0.5]
##       [--skip-intro] [--momento=1] [--flags=a,b] [--energy=10]
##       [--player=X,Y] [--mae=X,Y] [--still] [--press=move_up] [--hold=1.0]
##       [--talk] [--open=chegada|jantar|noite] [--choose=2] [--continue] [--pause]

var _args := {}

func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		var kv := arg.trim_prefix("--").split("=", true, 1)
		_args[kv[0]] = kv[1] if kv.size() > 1 else "true"
	if not _args.has("typing"):
		Settings.text_speed = 2
	# falas com retrato avançam sozinhas (senão a cena esperaria um toque em E)
	Dialogo.avanco_automatico = true
	var scene: Node = load(_args.get("scene", "res://scenes/main_menu.tscn")).instantiate()
	# O runner roda sempre (para os timers); a cena testada deve pausar normalmente.
	scene.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(scene)
	await get_tree().process_frame

	if _args.has("flags"):
		for flag in _args["flags"].split(","):
			GameState.flags[flag] = true
	if _args.has("energy"):
		GameState.apply_energy_delta(int(_args["energy"]) - GameState.energy)
	if _args.has("skip-intro"):
		scene.pular_entrada()
	if _args.has("momento"):
		scene._set_momento(int(_args["momento"]))
	if _args.has("mae"):
		var mae := scene.get_node("Entities/Mae")
		mae.global_position = _vec(_args["mae"])
		if _args.has("still"):
			mae.waypoints.clear()
	if _args.has("player"):
		var player := scene.get_node("Entities/Player")
		player.global_position = _vec(_args["player"])
		player.get_node("Camera2D").reset_smoothing()
	if _args.has("press"):
		Input.action_press(_args["press"])
		await get_tree().create_timer(float(_args.get("hold", "1.0"))).timeout
		Input.action_release(_args["press"])
	if _args.has("sentar"):
		scene.casa._on_interagiu({"tipo": "sentar"}, _args["sentar"])
	if _args.has("interagir"):
		scene.casa._on_interagiu({"tipo": _args["interagir"]}, "")
	if _args.has("talk"):
		scene._on_mae_talk_requested()
	if _args.has("open"):
		var id: String = _args["open"]
		var evento: Dictionary = {
			"chegada": Fase1Roteiro.chegada(false), "jantar": Fase1Roteiro.jantar(), "noite": Fase1Roteiro.NOITE,
		}[id]
		scene._abrir_evento(id, evento, scene.get_node("Entities/Mae").global_position)
	await get_tree().create_timer(float(_args.get("wait", "0.5"))).timeout
	if _args.has("choose"):
		var decision: Node = scene.get_node("DecisionUI")
		decision.options_container.get_child(int(_args["choose"])).pressed.emit()
		await get_tree().create_timer(float(_args.get("choose-wait", "0.6"))).timeout
		if _args.has("continue"):
			decision._on_continue_pressed()
			await get_tree().create_timer(0.6).timeout
	if _args.has("pause"):
		scene.get_node("PauseMenu").open()
		await get_tree().create_timer(0.3).timeout
	if _args.has("open-node"):
		scene.get_node(_args["open-node"]).open()
		await get_tree().create_timer(0.4).timeout

	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(_args["out"])
	print("screenshot: ", _args["out"])
	get_tree().quit()

func _vec(text: String) -> Vector2:
	var parts := text.split(",")
	return Vector2(float(parts[0]), float(parts[1]))
