shader_type canvas_item;

// Silhueta chapada para personagens secundários nas cutscenes.
// "forma" guarda um pouco da luminosidade original para o volume não sumir de vez.
uniform vec4 cor : source_color = vec4(0.18, 0.29, 0.26, 1.0);
uniform float forma = 0.12;

void fragment() {
	vec4 t = texture(TEXTURE, UV);
	float lum = dot(t.rgb, vec3(0.299, 0.587, 0.114));
	COLOR = vec4(cor.rgb + (lum - 0.45) * forma, t.a * cor.a);
}
