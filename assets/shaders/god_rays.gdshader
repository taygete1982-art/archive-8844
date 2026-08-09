shader_type canvas_item;

uniform vec2 origin = vec2(0.5, 0.0);
uniform vec3 ray_color = vec3(1.0, 0.85, 0.55);
uniform float alpha_max : hint_range(0.0, 1.0) = 0.15;

void fragment() {
	vec2 p = UV - origin;
	p.y *= 2.2;
	float ang = atan(p.x, -p.y);
	float r = length(p);

	float streaks = sin(ang * 14.0 + 0.5) * 0.5 + 0.5;
	streaks *= sin(ang * 5.18 + 1.7) * 0.5 + 0.5;

	float cone = smoothstep(0.9, 0.2, abs(ang));
	float fade = smoothstep(1.0, 0.15, r);

	COLOR = vec4(ray_color, streaks * cone * fade * alpha_max);
}