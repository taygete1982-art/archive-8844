shader_type canvas_item;

uniform sampler2D floor_tex;
uniform vec2 sun_dir = vec2(-0.55, -0.83);
uniform vec3 sun_color = vec3(1.0, 0.85, 0.6);
uniform vec3 ambient_color = vec3(0.4, 0.35, 0.3);
uniform float height_scale : hint_range(0.0, 4.0) = 1.4;
uniform float shadow_soft : hint_range(0.0, 1.0) = 0.5;

float height_at(vec2 uv) {
	vec4 c = texture(floor_tex, uv);
	return dot(c.rgb, vec3(0.333));
}

void fragment() {
	vec2 uv = UV;
	vec4 base = texture(floor_tex, uv);

	float e = 1.5 / 1024.0;
	float hx1 = height_at(uv + vec2(e, 0.0));
	float hx0 = height_at(uv - vec2(e, 0.0));
	float hy1 = height_at(uv + vec2(0.0, e));
	float hy0 = height_at(uv - vec2(0.0, e));
	vec3 n = normalize(vec3(-(hx1 - hx0) * height_scale, -(hy1 - hy0) * height_scale, 1.0));

	vec2 sd = normalize(sun_dir);
	vec3 light_dir = normalize(vec3(-sd.x, -sd.y, 0.55));
	float diff = clamp(dot(n, light_dir), 0.0, 1.0);

	float h0 = height_at(uv);
	float shadow = 0.0;
	vec2 p = uv;
	for (int i = 1; i <= 6; i++) {
		p -= sd * e * float(i);
		float hh = height_at(p);
		shadow = max(shadow, (hh - h0) * float(i) * 0.35);
	}
	shadow = clamp(1.0 - shadow * (1.0 + shadow_soft * 2.0), 0.3, 1.0);

	vec3 lit = base.rgb * (ambient_color + sun_color * diff * shadow * 1.1);
	lit += sun_color * pow(diff, 3.0) * 0.12;

	COLOR = vec4(lit, base.a);
}