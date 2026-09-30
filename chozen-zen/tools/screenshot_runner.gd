extends Node

## Ferramenta de dev: carrega uma cena, opcionalmente simula input, salva um PNG e fecha.
## Uso:
##   godot --path . res://tools/screenshot_runner.tscn -- --scene=res://scenes/phase1_casa.tscn
##       --out=C:/tmp/shot.png [--player=X,Y] [--mae=X,Y] [--still] [--press=move_up]
##       [--hold=1.0] [--wait=1.0] [--talk] [--choose=2]

var _args := {}

func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		var kv := arg.trim_prefix("--").split("=", true, 1)
		_args[kv[0]] = kv[1] if kv.size() > 1 else "true"
	var scene: Node = load(_args.get("scene", "res://scenes/main_menu.tscn")).instantiate()
	# O runner roda sempre (para os timers); a cena testada deve pausar normalmente.
	scene.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(scene)
	await get_tree().process_frame

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
	if _args.has("talk"):
		scene._on_mae_talk_requested()
	await get_tree().create_timer(float(_args.get("wait", "0.5"))).timeout
	if _args.has("choose"):
		var options: Node = scene.get_node("DecisionUI").options_container
		options.get_child(int(_args["choose"])).pressed.emit()
		await get_tree().create_timer(0.6).timeout

	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(_args["out"])
	print("screenshot: ", _args["out"])
	get_tree().quit()

func _vec(text: String) -> Vector2:
	var parts := text.split(",")
	return Vector2(float(parts[0]), float(parts[1]))
