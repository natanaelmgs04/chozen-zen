class_name Celular
extends CanvasLayer

## Tela de celular em primeiro plano (Life is Strange / Persona): conversas do grupo da turma
## e do Lucas aparecendo mensagem a mensagem, com "digitando...", notificações e postagens.
## O celular conta a pressão social melhor do que qualquer narrador.

const FONTE := preload("res://ui/font_regular.tres")
const FONTE_NEGRITO := preload("res://ui/font_bold.tres")
const TAMANHO := Vector2(380, 600)
const CORES_NOMES := {
	"Bia": Color("b9616a"), "Duda": Color("b9802a"), "Rafa": Color("4a6fa5"),
	"Lucas": Color("4a6fa5"), "Gui": Color("7a5aa5"), "Mari": Color("2f8f6b"),
}

var _raiz := Control.new()
var _corpo := PanelContainer.new()
var _titulo := Label.new()
var _subtitulo := Label.new()
var _area := Control.new()
var _lista := VBoxContainer.new()
var _hora := Label.new()
var _aberto := false

func _init(camada := 13) -> void:
	layer = camada

func _ready() -> void:
	_raiz.anchor_right = 1.0
	_raiz.anchor_bottom = 1.0
	_raiz.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_raiz)
	var moldura := StyleBoxFlat.new()
	moldura.bg_color = Color("1b2422")
	moldura.set_corner_radius_all(42)
	moldura.set_content_margin_all(14)
	moldura.shadow_color = Color(0, 0, 0, 0.5)
	moldura.shadow_size = 24
	moldura.shadow_offset = Vector2(0, 10)
	_corpo.add_theme_stylebox_override("panel", moldura)
	_corpo.size = TAMANHO
	_corpo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_raiz.add_child(_corpo)
	var tela := PanelContainer.new()
	var estilo_tela := StyleBoxFlat.new()
	estilo_tela.bg_color = Color("f3ece2")
	estilo_tela.set_corner_radius_all(30)
	tela.add_theme_stylebox_override("panel", estilo_tela)
	tela.clip_contents = true
	_corpo.add_child(tela)
	var coluna := VBoxContainer.new()
	coluna.add_theme_constant_override("separation", 0)
	tela.add_child(coluna)
	# barra de status + cabeçalho da conversa
	var topo := PanelContainer.new()
	var estilo_topo := StyleBoxFlat.new()
	estilo_topo.bg_color = Color("2f6b52")
	estilo_topo.corner_radius_top_left = 30
	estilo_topo.corner_radius_top_right = 30
	estilo_topo.content_margin_left = 22
	estilo_topo.content_margin_right = 22
	estilo_topo.content_margin_top = 10
	estilo_topo.content_margin_bottom = 12
	topo.add_theme_stylebox_override("panel", estilo_topo)
	coluna.add_child(topo)
	var cabecalho := VBoxContainer.new()
	cabecalho.add_theme_constant_override("separation", 0)
	topo.add_child(cabecalho)
	_hora.text = "17:48"
	_estilizar(_hora, 13, Color(1, 1, 1, 0.75), true)
	_hora.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cabecalho.add_child(_hora)
	_estilizar(_titulo, 20, Color("fbf5ec"), true)
	cabecalho.add_child(_titulo)
	_estilizar(_subtitulo, 13, Color(1, 1, 1, 0.7), false)
	cabecalho.add_child(_subtitulo)
	_area.custom_minimum_size = Vector2(TAMANHO.x - 28, TAMANHO.y - 120)
	_area.clip_contents = true
	coluna.add_child(_area)
	_lista.add_theme_constant_override("separation", 8)
	_lista.position = Vector2(14, 12)
	_lista.size.x = TAMANHO.x - 56
	_area.add_child(_lista)
	_raiz.visible = false

func abrir(titulo: String, subtitulo := "", hora := "17:48") -> void:
	_titulo.text = titulo
	_subtitulo.text = subtitulo
	_hora.text = hora
	for filho in _lista.get_children():
		filho.queue_free()
	_lista.position.y = 12
	var tela := _raiz.get_viewport_rect().size
	var x := tela.x * 0.5 - TAMANHO.x * 0.5 + 220
	_corpo.position = Vector2(x, tela.y + 20)
	_corpo.rotation_degrees = 6.0
	_corpo.pivot_offset = TAMANHO / 2
	_raiz.visible = true
	_aberto = true
	Audio.sfx("phone")
	var tween := create_tween().set_parallel().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(_corpo, "position:y", (tela.y - TAMANHO.y) / 2, 0.5)
	tween.tween_property(_corpo, "rotation_degrees", -2.0, 0.5)
	await tween.finished

## Uma mensagem. Dos outros: "digitando..." antes. `minha`: balão verde à direita.
func mensagem(de: String, texto: String, minha := false, digitar := 0.7) -> void:
	if not minha and digitar > 0.0:
		var digitando := _balao("digitando...", de, false, true)
		await get_tree().create_timer(digitar).timeout
		digitando.queue_free()
		await get_tree().process_frame
	_balao(texto, de, minha, false)
	Audio.sfx("ping", -4.0 if minha else 0.0, 0.08)
	await get_tree().create_timer(0.45).timeout

## Alguém começa a digitar... e desiste. (Uma pista vale mais do que uma fala.)
func digitando_e_some(de: String, segundos := 1.6) -> void:
	var digitando := _balao("digitando...", de, false, true)
	await get_tree().create_timer(segundos).timeout
	var tween := digitando.create_tween()
	tween.tween_property(digitando, "modulate:a", 0.0, 0.3)
	tween.tween_callback(digitando.queue_free)
	await tween.finished

## Notificação curta que cai do topo da tela do celular.
func notificacao(texto: String) -> void:
	var aviso := _balao(texto, "", false, false, true)
	Audio.sfx("ping", -6.0, 0.15)
	aviso.modulate.a = 0.0
	aviso.create_tween().tween_property(aviso, "modulate:a", 1.0, 0.15)

func fechar() -> void:
	if not _aberto:
		return
	_aberto = false
	var tela := _raiz.get_viewport_rect().size
	var tween := create_tween().set_parallel().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(_corpo, "position:y", tela.y + 40, 0.35)
	tween.tween_property(_corpo, "rotation_degrees", 8.0, 0.35)
	await tween.finished
	_raiz.visible = false

func _balao(texto: String, de: String, minha: bool, digitando: bool, aviso := false) -> Control:
	var linha := HBoxContainer.new()
	linha.alignment = BoxContainer.ALIGNMENT_END if minha else BoxContainer.ALIGNMENT_BEGIN
	if aviso:
		linha.alignment = BoxContainer.ALIGNMENT_CENTER
	var balao := PanelContainer.new()
	var estilo := StyleBoxFlat.new()
	estilo.set_corner_radius_all(16)
	estilo.content_margin_left = 14
	estilo.content_margin_right = 14
	estilo.content_margin_top = 8
	estilo.content_margin_bottom = 9
	if aviso:
		estilo.bg_color = Color("1f4b3b")
	elif minha:
		estilo.bg_color = Color("5fae6e")
		estilo.corner_radius_bottom_right = 4
	else:
		estilo.bg_color = Color("ffffff")
		estilo.corner_radius_bottom_left = 4
	balao.add_theme_stylebox_override("panel", estilo)
	var coluna := VBoxContainer.new()
	coluna.add_theme_constant_override("separation", 1)
	balao.add_child(coluna)
	if de != "" and not minha and not aviso:
		var nome := Label.new()
		_estilizar(nome, 13, CORES_NOMES.get(de, Color("2f6b52")), true)
		nome.text = de
		coluna.add_child(nome)
	var corpo := Label.new()
	corpo.text = texto
	corpo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	corpo.custom_minimum_size.x = mini(texto.length() * 9 + 10, 250)
	var cor := Color("fbf5ec") if (minha or aviso) else Color("24302c")
	if digitando:
		cor = Color("8a8f99")
	_estilizar(corpo, 16, cor, aviso)
	coluna.add_child(corpo)
	linha.add_child(balao)
	_lista.add_child(linha)
	# entrada com "pop" e rolagem automática quando a conversa enche a tela
	balao.pivot_offset = Vector2(0 if not minha else 200, 20)
	balao.scale = Vector2(0.85, 0.85)
	balao.create_tween().tween_property(balao, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_rolar.call_deferred()
	return linha

func _rolar() -> void:
	await get_tree().process_frame
	var excesso := _lista.size.y + 24 - _area.size.y
	if excesso > 0:
		create_tween().tween_property(_lista, "position:y", 12 - excesso, 0.25).set_trans(Tween.TRANS_SINE)

func _estilizar(label: Label, tamanho: int, cor: Color, negrito: bool) -> void:
	label.add_theme_font_override("font", FONTE_NEGRITO if negrito else FONTE)
	label.add_theme_font_size_override("font_size", tamanho)
	label.add_theme_color_override("font_color", cor)
