class_name Pixel

## Desenho em "pixels de arte" de 4 px (a mesma grade dos sprites), para as cutscenes
## parecerem pixel art de verdade e não ilustração vetorial. Coordenadas em unidades (U).

const U := 4.0

## Fonte 3×5 só com os caracteres usados no quadro-negro e nas plaquinhas.
const FONTE := {
	"P": ["111", "101", "111", "100", "100"],
	"R": ["110", "101", "110", "101", "101"],
	"O": ["111", "101", "101", "101", "111"],
	"V": ["101", "101", "101", "101", "010"],
	"A": ["010", "101", "111", "101", "101"],
	"X": ["101", "101", "010", "101", "101"],
	"0": ["111", "101", "101", "101", "111"],
	"1": ["010", "110", "010", "010", "111"],
	"2": ["110", "001", "010", "100", "111"],
	"3": ["110", "001", "010", "001", "110"],
	"4": ["101", "101", "111", "001", "001"],
	"7": ["111", "001", "010", "010", "010"],
	"9": ["111", "101", "111", "001", "111"],
	"+": ["000", "010", "111", "010", "000"],
	"=": ["000", "111", "000", "111", "000"],
	"?": ["110", "001", "010", "000", "010"],
	")": ["100", "010", "010", "010", "100"],
	"-": ["000", "000", "111", "000", "000"],
	" ": ["000", "000", "000", "000", "000"],
}


static func rect(ci: CanvasItem, x: float, y: float, w: float, h: float, cor: Color) -> void:
	ci.draw_rect(Rect2(x * U, y * U, w * U, h * U), cor)


## Retângulo com os cantos "comidos" em 1 unidade, como se faz à mão em pixel art.
static func rect_arredondado(ci: CanvasItem, x: float, y: float, w: float, h: float, cor: Color) -> void:
	rect(ci, x + 1, y, w - 2, h, cor)
	rect(ci, x, y + 1, 1, h - 2, cor)
	rect(ci, x + w - 1, y + 1, 1, h - 2, cor)


static func circulo(ci: CanvasItem, cx: float, cy: float, r: int, cor: Color) -> void:
	for dy in range(-r, r + 1):
		var meia := floori(sqrt(r * r - dy * dy) + 0.5)
		rect(ci, cx - meia, cy + dy, meia * 2 + 1, 1, cor)


## Linha de 1 unidade de espessura, amostrada na grade (sem antisserrilhado).
static func linha(ci: CanvasItem, de: Vector2, ate: Vector2, cor: Color) -> void:
	var passos := maxi(1, ceili(de.distance_to(ate) * 2.0))
	var feitos := {}
	for i in passos + 1:
		var p := de.lerp(ate, float(i) / passos).round()
		if not feitos.has(p):
			feitos[p] = true
			rect(ci, p.x, p.y, 1, 1, cor)


static func texto(ci: CanvasItem, x: float, y: float, conteudo: String, cor: Color) -> void:
	var cursor := x
	for letra in conteudo.to_upper():
		var glifo: Array = FONTE.get(letra, FONTE[" "])
		for linha_i in glifo.size():
			var bits: String = glifo[linha_i]
			for coluna in bits.length():
				if bits[coluna] == "1":
					rect(ci, cursor + coluna, y + linha_i, 1, 1, cor)
		cursor += (glifo[0] as String).length() + 1


## Faixas horizontais de cor (gradiente "em degraus", típico de céu em pixel art).
static func faixas(ci: CanvasItem, x: float, y: float, w: float, h: float, cores: Array, faixa := 6) -> void:
	var n := ceili(h / faixa)
	for i in n:
		var t := float(i) / maxf(1.0, n - 1)
		var pos := t * (cores.size() - 1)
		var a := floori(pos)
		var b := mini(a + 1, cores.size() - 1)
		rect(ci, x, y + i * faixa, w, minf(faixa, h - i * faixa), (cores[a] as Color).lerp(cores[b], pos - a))


## Brilho de luz em anéis concêntricos (pixel art não tem degradê suave).
static func brilho(ci: CanvasItem, cx: float, cy: float, r: int, cor: Color, aneis := 4) -> void:
	for i in aneis:
		var raio := r - floori(float(i * r) / aneis)
		var c := cor
		c.a = cor.a * (i + 1) / aneis * 0.5
		circulo(ci, cx, cy, raio, c)
