extends CanvasLayer

## Cartão de narrativa em tela cheia: abertura do capítulo, resumo do dia e fim de jogo.

signal button_pressed(index: int)

@onready var title_label: Label = %CardTitle
@onready var subtitle_label: Label = %CardSubtitle
@onready var body_label: RichTextLabel = %CardBody
@onready var footer_label: Label = %CardFooter
@onready var buttons_box: HBoxContainer = %CardButtons

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

func show_card(title: String, subtitle: String, body: String, buttons: Array[String], footer := "") -> void:
	title_label.text = title
	subtitle_label.text = subtitle
	subtitle_label.visible = subtitle != ""
	body_label.text = body
	footer_label.text = footer
	footer_label.visible = footer != ""
	for child in buttons_box.get_children():
		child.queue_free()
	for i in buttons.size():
		var button := Button.new()
		button.text = buttons[i]
		button.custom_minimum_size = Vector2(200, 48)
		button.pressed.connect(_on_button.bind(i))
		buttons_box.add_child(button)
	visible = true
	get_tree().paused = true
	Audio.sfx("open")
	var panel: Control = $Backdrop/Panel
	panel.pivot_offset = panel.size / 2
	panel.scale = Vector2.ONE * 0.94
	panel.modulate.a = 0.0
	$Backdrop.modulate.a = 0.0
	var tween := create_tween().set_parallel()
	tween.tween_property($Backdrop, "modulate:a", 1.0, 0.3)
	tween.tween_property(panel, "scale", Vector2.ONE, 0.32).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(panel, "modulate:a", 1.0, 0.25)
	buttons_box.get_child(0).grab_focus.call_deferred()

func _on_button(index: int) -> void:
	visible = false
	get_tree().paused = false
	button_pressed.emit(index)
