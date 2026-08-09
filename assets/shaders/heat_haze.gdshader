shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture;
uniform float speed : hint_range(0.0, 2.0) = 0.06;
uniform float intensity : hint_range(0.0, 20.0) = 0.08;
uniform float frequency : hint_range(0.0, 50.0) = 6.0;

void fragment() {
	vec2 uv = SCREEN_UV;
	// Только верхние 10% экрана — едва заметное дыхание воздуха
	float fade = smoothstep(0.1, 0.0, uv.y);
	float time = TIME * speed;

	float wave = sin(uv.y * frequency + time) * intensity * 0.001 * fade;
	wave += sin(uv.x * frequency * 0.7 + time * 1.3) * intensity * 0.0007 * fade;

	uv.x += wave;
	COLOR = texture(screen_texture, uv);
}