shader_type canvas_item;

// Pós-processamento das cutscenes: gradação de cor por clima, vinheta, granulação de filme,
// aberração cromática, desfoque (profundidade de campo), flash, negativo e linhas de impacto.
// Tudo com amostras manuais (sem mipmap), para funcionar igual na web (Compatibility).

uniform sampler2D tela : hint_screen_texture, filter_linear;
uniform float saturacao = 1.0;
uniform float contraste = 1.0;
uniform float brilho = 0.0;
uniform vec3 tinta = vec3(1.0);
uniform float vinheta = 0.28;
uniform float grao = 0.035;
uniform float aberracao = 0.0;      // em pixels
uniform float desfoque = 0.0;       // raio em pixels
uniform float flash = 0.0;
uniform vec3 cor_flash = vec3(1.0);
uniform float negativo = 0.0;
uniform float linhas = 0.0;         // linhas de velocidade radiais (anime/Persona)
uniform vec2 centro_linhas = vec2(0.5, 0.5);
uniform float faixa_luz = 0.0;      // brilho suave nas altas luzes (bloom barato)

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

vec3 amostra(vec2 uv, vec2 pixel) {
	if (desfoque <= 0.01) {
		return texture(tela, uv).rgb;
	}
	vec2 px = pixel * desfoque;
	vec3 soma = texture(tela, uv).rgb * 0.2;
	soma += texture(tela, uv + vec2(px.x, 0.0)).rgb * 0.1;
	soma += texture(tela, uv - vec2(px.x, 0.0)).rgb * 0.1;
	soma += texture(tela, uv + vec2(0.0, px.y)).rgb * 0.1;
	soma += texture(tela, uv - vec2(0.0, px.y)).rgb * 0.1;
	soma += texture(tela, uv + px).rgb * 0.1;
	soma += texture(tela, uv - px).rgb * 0.1;
	soma += texture(tela, uv + vec2(px.x, -px.y)).rgb * 0.1;
	soma += texture(tela, uv + vec2(-px.x, px.y)).rgb * 0.1;
	return soma;
}

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 d = uv - 0.5;
	vec3 c;
	if (aberracao > 0.01) {
		vec2 off = normalize(d + 0.0001) * aberracao * SCREEN_PIXEL_SIZE * length(d) * 2.0;
		c.r = amostra(uv + off, SCREEN_PIXEL_SIZE).r;
		c.g = amostra(uv, SCREEN_PIXEL_SIZE).g;
		c.b = amostra(uv - off, SCREEN_PIXEL_SIZE).b;
	} else {
		c = amostra(uv, SCREEN_PIXEL_SIZE);
	}
	// brilho nas luzes altas
	float luz = max(max(c.r, c.g), c.b);
	c += smoothstep(0.75, 1.0, luz) * faixa_luz * vec3(1.0, 0.92, 0.8);
	// gradação de cor
	float luma = dot(c, vec3(0.299, 0.587, 0.114));
	c = mix(vec3(luma), c, saturacao);
	c = (c - 0.5) * contraste + 0.5 + brilho;
	c *= tinta;
	c = mix(c, vec3(1.0) - c, negativo);
	// linhas de velocidade a partir do centro da ação
	if (linhas > 0.01) {
		vec2 r = (uv - centro_linhas) * vec2(SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x, 1.0);
		float ang = atan(r.y, r.x);
		float faixa = hash(vec2(floor(ang * 70.0), floor(TIME * 18.0)));
		float raio = smoothstep(0.18, 0.75, length(r));
		c = mix(c, vec3(1.0), step(0.78, faixa) * raio * linhas);
	}
	// vinheta
	c *= 1.0 - vinheta * smoothstep(0.35, 0.95, length(d * vec2(1.1, 1.25)) * 1.4);
	// granulação de filme
	c += (hash(uv * 1000.0 + fract(TIME) * 61.0) - 0.5) * grao;
	c = mix(c, cor_flash, flash);
	COLOR = vec4(c, 1.0);
}
