extends Node2D

## Plano 1 — Sala de aula, dia da prova. Lucas empurra a cola para baixo da cadeira do
## protagonista, a professora encontra e ninguém acredita nele. A gota de suor no Lucas é a
## pista visual de quem era a cola de verdade (paga na Fase 1, se o jogador perguntar a ele).

const PAREDE := Color("e9d9be")
const LAMBRI := Color("a9744b")
const MADEIRA := Color("8a5a3b")
const MADEIRA_ESCURA := Color("6b4429")
const MADEIRA_CLARA := Color("b07a4d")
const CHAO := Color("c79a6a")
const CHAO_LINHA := Color("b7895b")
const QUADRO := Color("2d5145")
const GIZ := Color(0.93, 0.95, 0.9, 0.9)
const CREME := Color("fbf5ec")
const VERDE := Color("2f6b52")
const VERDE_ESCURO := Color("1f4b3b")
const ROSA := Color("d9878a")
const PESSEGO := Color("f4b183")
const METAL := Color("4a4a55")

const COLUNAS := [100, 160, 220]
const FILEIRAS := [62, 102, 142]
## [coluna, fileira, acessório, tom]; o protagonista fica no meio e o Lucas logo atrás.
const COLEGAS := [
	[0, 0, "laco", 0.0], [1, 0, "espetado", 0.05], [2, 0, "longo", -0.02],
	[0, 1, "rabo", 0.03], [2, 1, "", -0.04],
	[0, 2, "coque", 0.02], [2, 2, "espetado", 0.0],
]

var jogador: Aluno
var lucas: Aluno
var professora := Professora.new()
var colegas: Array[Aluno] = []
var papel := Node2D.new()
var _frente := Node2D.new()
var _segundos := 40.0
var _emotes := {}

func _ready() -> void:
	for dados in COLEGAS:
		var aluno := Aluno.new(false, dados[2], dados[3])
		_sentar(aluno, dados[0], dados[1])
		colegas.append(aluno)
	jogador = Aluno.new(true)
	_sentar(jogador, 1, 1)
	lucas = Aluno.new(false, "", 0.06)
	_sentar(lucas, 1, 2)
	_frente.draw.connect(_desenhar_cadeiras)
	add_child(_frente)
	papel.draw.connect(func() -> void:
		Pixel.rect(papel, -2, -1, 5, 3, CREME)
		Pixel.rect(papel, -1, 0, 3, 1, Color("8ec5e8")))
	papel.visible = false
	add_child(papel)
	professora.position = Vector2(140, 58) * Pixel.U
	professora.braco = "ergue"
	add_child(professora)
	_poeira()

## Partículas de poeira no feixe de luz da janela: a sala parece ter ar.
func _poeira() -> void:
	var poeira := CPUParticles2D.new()
	poeira.position = Vector2(70, 60) * Pixel.U
	poeira.amount = 40
	poeira.lifetime = 6.0
	poeira.preprocess = 6.0
	poeira.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	poeira.emission_rect_extents = Vector2(110, 160)
	poeira.direction = Vector2(0.3, 1)
	poeira.spread = 40.0
	poeira.gravity = Vector2(0, 2)
	poeira.initial_velocity_min = 3.0
	poeira.initial_velocity_max = 9.0
	poeira.scale_amount_min = 2.0
	poeira.scale_amount_max = 4.0
	poeira.color = Color(1, 0.95, 0.8, 0.55)
	var fade := Gradient.new()
	fade.set_color(0, Color(1, 1, 1, 0))
	fade.add_point(0.3, Color(1, 1, 1, 1))
	fade.set_color(fade.get_point_count() - 1, Color(1, 1, 1, 0))
	poeira.color_ramp = fade
	add_child(poeira)

func _sentar(aluno: Aluno, coluna: int, fileira: int) -> void:
	aluno.position = Vector2(COLUNAS[coluna] * Pixel.U - 40, FILEIRAS[fileira] * Pixel.U + 8)
	add_child(aluno)

func _process(delta: float) -> void:
	var antes := floori(_segundos)
	_segundos += delta
	if floori(_segundos) != antes:
		queue_redraw()

func emote(alvo: Node2D, tipo: String, duracao := 1.6, deslocamento := Vector2.ZERO) -> void:
	if not _emotes.has(alvo):
		var novo := Emote.new()
		add_child(novo)
		_emotes[alvo] = novo
	var e: Emote = _emotes[alvo]
	e.position = alvo.cabeca + deslocamento
	e.mostrar(tipo, duracao)

func tocar(d: Node) -> void:
	Audio.stop_music(1.0)
	Audio.play_ambience(Audio.AMB_CLASSROOM, 1.0)
	# flashback: tom de memória e um travelling lento abrindo a sala
	d.fx.clima("memoria", 0.0)
	d.enquadrar_ja(Vector2(640, 430), 1.25)
	d.carimbo("14:52", "Mais cedo · Prova de Matemática, 9º B")
	d.enquadrar(Vector2(640, 360), 1.0, 4.0)
	await d.espera(3.0)

	# Plano detalhe: Lucas olha em volta e empurra a cola — em câmera lenta.
	lucas.virar("left")
	await d.espera(0.3)
	lucas.virar("up")
	d.enquadrar(Vector2(612, 575), 2.3, 0.45)
	await d.espera(0.45)
	d.fx.desfocar(0.0)
	d.camera_lenta(0.35)
	Audio.sfx("heartbeat")
	papel.position = Vector2(640, 600)
	papel.visible = true
	Audio.sfx("paper")
	var tween := create_tween().set_parallel()
	tween.tween_property(papel, "position:x", 586.0, 0.7).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(papel, "position:y", 540.0, 0.7).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await tween.finished
	d.camera_lenta(1.0)
	await d.espera(0.4)
	d.enquadrar(Vector2(640, 380), 1.0, 0.7)
	await d.espera(0.5)

	# A professora se vira e desce pelo corredor.
	professora.braco = ""
	professora.de_frente = true
	await d.espera(0.4)
	await professora.andar_ate(Vector2(520, 300), 0.7)
	await professora.andar_ate(Vector2(520, 548), 1.4)
	await d.espera(0.2)

	# Ela encontra a cola: impact frame, a cor some, a câmera sai do eixo, entra a tensão.
	d.enquadrar(Vector2(575, 470), 1.55, 0.18)
	emote(professora, "!", 1.0, Vector2(8, 0))
	d.impacto(professora.cabeca + Vector2(0, 60))
	d.fx.clima("tensao", 0.4)
	d.inclinar(-3.5, 0.6)
	Audio.play_music(Audio.MUSIC_TENSION, 0.4)
	Audio.set_music_muffled(false, 0.1)
	await d.espera(0.8)
	professora.curvada = 1.0
	professora.braco = "abaixa"
	await d.espera(0.3)
	papel.visible = false
	professora.curvada = 0.0
	professora.com_papel = true
	professora.braco = "ergue"
	await d.espera(0.3)
	await d.dizer("professora", "brava", "[shake rate=22 level=9]Colando na prova?![/shake]", "direita")

	# A turma inteira se vira; os cochichos tomam a tela.
	for aluno in colegas:
		aluno.virar(_olhar_para_jogador(aluno))
	emote(colegas[0], "...", 1.8)
	emote(colegas[4], "...", 1.8)
	d.dialogo.murmurios(["ele colou?", "nossa...", "eu sabia", "que vergonha", "sério isso?", "kkkk"], 2.8)
	jogador.virar("left")
	jogador.balancar(6.0)
	emote(jogador, "?!", 0.9)
	d.fx.pulso_aberracao(5.0, 0.6)
	await d.dizer("voce", "surpreso", "N-não! [shake rate=26 level=7]Não é minha![/shake]", "esquerda")
	professora.braco = "aponta"
	await d.dizer("professora", "severa", "Recuperação. Amanhã cedo.
E a escola vai [color=#b9616a]avisar a sua família[/color].", "direita")
	await d.dizer("voce", "triste", "Mas eu não...", "esquerda")
	d.dialogo.fechar()

	# Plano detalhe final: quem desviou o olhar?
	d.inclinar(0.0, 0.5)
	d.fx.clima("frio", 0.8)
	d.enquadrar(Vector2(640, 610), 2.4, 0.9)
	Audio.set_music_muffled(true, 0.8)
	await d.espera(0.9)
	lucas.virar("right")
	emote(lucas, "suor", 2.0, Vector2(30, 16))
	Audio.sfx("heartbeat")
	await d.espera(0.75)
	Audio.sfx("heartbeat")
	await d.espera(1.3)

func _olhar_para_jogador(aluno: Aluno) -> String:
	var centro := jogador.position
	if aluno.position.y < centro.y - 1:
		return "down"
	return "right" if aluno.position.x < centro.x else "left"

func _draw() -> void:
	# parede e lambri
	Pixel.rect(self, -100, -60, 520, 104, PAREDE)
	Pixel.rect(self, -100, 38, 520, 6, LAMBRI)
	Pixel.rect(self, -100, 38, 520, 1, Color("c48e5e"))
	# janela com céu de tarde
	Pixel.rect(self, 14, 5, 54, 30, MADEIRA_ESCURA)
	Pixel.faixas(self, 16, 7, 50, 26, [Color("9ccbe0"), Color("cfe3e6"), Color("f4d9b8")], 4)
	Pixel.rect(self, 22, 12, 10, 2, Color(1, 1, 1, 0.8))
	Pixel.rect(self, 25, 11, 5, 1, Color(1, 1, 1, 0.8))
	Pixel.rect(self, 50, 22, 8, 1, Color(1, 1, 1, 0.6))
	Pixel.rect(self, 40, 7, 2, 26, MADEIRA_ESCURA)
	Pixel.rect(self, 16, 19, 50, 2, MADEIRA_ESCURA)
	Pixel.rect(self, 12, 35, 58, 2, MADEIRA)
	# mural com mapa e cartaz
	Pixel.rect(self, 76, 12, 14, 12, PESSEGO)
	Pixel.rect(self, 78, 15, 5, 4, Color("9ccbe0"))
	Pixel.rect(self, 84, 17, 4, 5, Color("9ccbe0"))
	Pixel.rect(self, 232, 8, 14, 18, ROSA)
	for y in [11, 14, 17]:
		Pixel.rect(self, 234, y, 10, 1, CREME)
	# quadro-negro
	Pixel.rect(self, 98, 4, 124, 33, MADEIRA_ESCURA)
	Pixel.rect(self, 100, 6, 120, 29, QUADRO)
	Pixel.rect(self, 150, 22, 24, 7, Color(1, 1, 1, 0.04))
	Pixel.texto(self, 104, 9, "PROVA", GIZ)
	Pixel.rect(self, 104, 15, 19, 1, Color(GIZ, 0.5))
	Pixel.texto(self, 104, 18, "1) 2X+3=7", GIZ)
	Pixel.texto(self, 104, 26, "2) X+4=9", GIZ)
	Pixel.texto(self, 186, 18, "X=?", GIZ)
	Pixel.rect(self, 98, 36, 124, 2, MADEIRA)
	Pixel.rect(self, 200, 35, 4, 1, CREME)
	# relógio (o ponteiro dos segundos anda de verdade)
	Pixel.circulo(self, 262, 17, 7, VERDE_ESCURO)
	Pixel.circulo(self, 262, 17, 6, CREME)
	var centro := Vector2(262, 17)
	Pixel.linha(self, centro, centro + Vector2(3, 1), VERDE_ESCURO)
	Pixel.linha(self, centro, centro + Vector2(-3, 3), VERDE_ESCURO)
	var angulo := floorf(_segundos) / 60.0 * TAU - PI / 2
	Pixel.linha(self, centro, centro + Vector2.from_angle(angulo) * 5, Color("b9616a"))
	# porta da sala
	Pixel.rect(self, 284, 8, 22, 36, Color("5a3a2a"))
	Pixel.rect(self, 286, 10, 18, 34, MADEIRA)
	Pixel.rect(self, 290, 13, 10, 8, Color("cfe3e6"))
	Pixel.rect(self, 301, 28, 1, 2, Color("e6b422"))
	# chão de tábuas
	Pixel.rect(self, -100, 44, 520, 200, CHAO)
	for linha_i in 28:
		var y := 44 + linha_i * 7
		var desloc := (linha_i * 37) % 60
		for x in range(-160 + desloc, 420, 60):
			if (x + linha_i) % 3 == 0:
				Pixel.rect(self, x, y, 60, 7, CHAO.darkened(0.035))
			Pixel.rect(self, x, y + 1, 1, 6, CHAO_LINHA)
		Pixel.rect(self, -100, y + 6, 520, 1, CHAO_LINHA.lerp(CHAO, 0.4))
	# luz da janela batendo no chão
	var luz := PackedVector2Array([Vector2(16, 44), Vector2(66, 44), Vector2(124, 124), Vector2(66, 124)])
	for i in luz.size():
		luz[i] *= Pixel.U
	draw_colored_polygon(luz, Color(1, 0.92, 0.72, 0.13))
	# mesa da professora
	Pixel.rect(self, 30, 48, 56, 10, MADEIRA)
	Pixel.rect(self, 30, 48, 56, 1, LAMBRI)
	Pixel.rect(self, 32, 58, 52, 8, MADEIRA_ESCURA)
	Pixel.rect(self, 36, 45, 9, 3, ROSA)
	Pixel.rect(self, 37, 43, 7, 2, VERDE)
	Pixel.rect(self, 76, 45, 3, 3, Color("c8412d"))
	Pixel.rect(self, 77, 44, 1, 1, VERDE)
	# carteiras com a prova em cima
	for coluna in COLUNAS:
		for fileira in FILEIRAS:
			Pixel.rect(self, coluna - 14, fileira + 10, 28, 2, Color(0, 0, 0, 0.12))
			Pixel.rect(self, coluna - 13, fileira + 9, 2, 6, MADEIRA_ESCURA)
			Pixel.rect(self, coluna + 11, fileira + 9, 2, 6, MADEIRA_ESCURA)
			Pixel.rect(self, coluna - 14, fileira, 28, 10, MADEIRA_CLARA)
			Pixel.rect(self, coluna - 14, fileira, 28, 1, Color("c99363"))
			Pixel.rect(self, coluna - 14, fileira + 9, 28, 1, MADEIRA)
			Pixel.rect(self, coluna - 13, fileira + 2, 6, 5, CREME)
			Pixel.rect(self, coluna - 12, fileira + 3, 4, 1, Color("c9d6dd"))
			Pixel.rect(self, coluna + 8, fileira + 3, 4, 1, Color("e6b422"))

## Encosto das cadeiras, por cima dos alunos (esconde as pernas: parece que estão sentados).
func _desenhar_cadeiras() -> void:
	for coluna in COLUNAS:
		for fileira in FILEIRAS:
			Pixel.rect(_frente, coluna - 9, fileira + 23, 18, 3, VERDE)
			Pixel.rect(_frente, coluna - 9, fileira + 23, 18, 1, Color("3f8566"))
			Pixel.rect(_frente, coluna - 9, fileira + 26, 18, 2, Color("24543f"))
			Pixel.rect(_frente, coluna - 8, fileira + 28, 1, 6, METAL)
			Pixel.rect(_frente, coluna + 7, fileira + 28, 1, 6, METAL)
