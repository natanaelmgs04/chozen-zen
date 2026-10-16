extends CanvasLayer

## Menu de pause (Esc/P/Start). Só abre durante a exploração, não por cima de diálogos e cartões.

const MAIN_MENU := "res://scenes/main_menu.tscn"

@onready var panel: Control = $Backdrop/Panel
@onready var resume_button: Button = %ResumeButton
@onready var settings_button: Button = %SettingsButton
@onready var controls_button: Button = %ControlsButton
@onready var restart_button: Button = %RestartButton
@onready var menu_button: Button = %MenuButton
@onready var quit_button: Button = %QuitButton
@onready var settings_panel: OverlayPanel = $SettingsPanel
@onready var controls_panel: OverlayPanel = $ControlsPanel

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	resume_button.pressed.connect(close)
	settings_button.pressed.connect(settings_panel.open)
	controls_button.pressed.connect(controls_panel.open)
	settings_panel.closed.connect(settings_button.grab_focus)
	controls_panel.closed.connect(controls_button.grab_focus)
	restart_button.pressed.connect(_on_restart_pressed)
	menu_button.pressed.connect(_on_menu_pressed)
	quit_button.pressed.connect(get_tree().quit)
	# No navegador "Sair" não fecha a aba; esconder evita um botão que não faz nada.
	quit_button.visible = not OS.has_feature("web")
	panel.resized.connect(func() -> void: panel.pivot_offset = panel.size / 2)

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("pause"):
		return
	if visible:
		close()
	elif not get_tree().paused:
		open()
	else:
		return
	get_viewport().set_input_as_handled()

func open() -> void:
	visible = true
	get_tree().paused = true
	Audio.sfx("open")
	Audio.set_music_muffled(true, 0.3)
	panel.scale = Vector2.ONE * 0.95
	panel.modulate.a = 0.0
	var tween := create_tween().set_parallel()
	tween.tween_property(panel, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(panel, "modulate:a", 1.0, 0.18)
	resume_button.grab_focus()

func close() -> void:
	visible = false
	get_tree().paused = false
	Audio.set_music_muffled(get_parent().has_method("is_night") and get_parent().is_night(), 0.3)

func _on_restart_pressed() -> void:
	GameState.reset()
	Transition.reload()

func _on_menu_pressed() -> void:
	Transition.change_scene(MAIN_MENU)
