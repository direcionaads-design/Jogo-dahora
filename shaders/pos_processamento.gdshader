// Pós-processamento estilo "Fears to Fathom":
// cores dessaturadas, tom esverdeado, granulado animado e vinheta.
// Fica num ColorRect que cobre a tela (cenas/ui/pos_processamento.tscn).
// Os valores podem ser ajustados no Inspetor, em Material > Shader Parameters.
shader_type canvas_item;

uniform sampler2D tela : hint_screen_texture, filter_linear;

// 0 = cores normais, 1 = preto e branco.
uniform float dessaturacao : hint_range(0.0, 1.0) = 0.3;
// Multiplica as cores. Levemente verde-acinzentado.
uniform vec3 tom : source_color = vec3(0.94, 1.0, 0.92);
uniform float contraste : hint_range(0.5, 1.5) = 1.05;
// Força do chuvisco/granulado.
uniform float granulado : hint_range(0.0, 0.3) = 0.06;
// Tamanho dos grãos: quantos grãos na largura da tela.
uniform float resolucao_granulado = 480.0;
// Escurecimento das bordas.
uniform float vinheta : hint_range(0.0, 1.5) = 0.55;
// 0 a 1. Use para medo/estresse: fecha a vinheta e tira mais cor.
uniform float medo : hint_range(0.0, 1.0) = 0.0;

float ruido(vec2 p) {
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	vec3 cor = texture(tela, SCREEN_UV).rgb;

	// Dessaturar e tingir.
	float luz = dot(cor, vec3(0.299, 0.587, 0.114));
	cor = mix(cor, vec3(luz), clamp(dessaturacao + medo * 0.4, 0.0, 1.0)) * tom;
	cor = (cor - 0.5) * contraste + 0.5;

	// Granulado: muda a cada quadro (TIME) e respeita a proporção da tela.
	vec2 proporcao = vec2(1.0, SCREEN_PIXEL_SIZE.x / SCREEN_PIXEL_SIZE.y);
	vec2 grao = floor(SCREEN_UV * resolucao_granulado * proporcao);
	float g = ruido(grao + floor(TIME * 24.0) * 17.0) - 0.5;
	cor += g * granulado;

	// Vinheta: escurece do centro para as bordas.
	vec2 d = (SCREEN_UV - 0.5) * vec2(1.0, proporcao.y);
	float v = smoothstep(0.85 - medo * 0.3, 0.25 - medo * 0.15, length(d));
	cor *= mix(1.0, v, vinheta + medo * 0.5);

	COLOR = vec4(clamp(cor, 0.0, 1.0), 1.0);
}
