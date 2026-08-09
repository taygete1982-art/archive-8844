shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture;
uniform vec2 light1_pos = vec2(0.5, 0.15);
uniform vec2 light2_pos = vec2(0.25, 0.85);
uniform vec2 light3_pos = vec2(0.75, 0.85);
uniform vec3 light_color = vec3(1.0, 0.85, 0.55);
uniform float light_radius : hint_range(0.0, 1.0) = 0.25;
uniform float light_intensity : hint_range(0.0, 2.0) = 0.18;

void fragment() {
	vec2 uv = SCREEN_UV;
	vec4 base = texture(screen_texture, uv);

	float dist1 = distance(uv, light1_pos);
	float dist2 = distance(uv, light2_pos);
	float dist3 = distance(uv, light3_pos);

	float glow1 = smoothstep(light_radius, 0.0, dist1);
	float glow2 = smoothstep(light_radius, 0.0, dist2);
	float glow3 = smoothstep(light_radius, 0.0, dist3);

	float total_glow = (glow1 + glow2 + glow3) * light_intensity;

	vec3 lit = base.rgb + light_color * total_glow;

	COLOR = vec4(lit, base.a);
}