shader_type canvas_item;

uniform vec2 size = vec2(4.0);
uniform vec2 texture_size = vec2(24);

void fragment() {
	vec2 uv = fract((UV / size) * texture_size/2.0);
	uv -= .5;
	vec3 checker = clamp(vec3(step(uv.x * uv.y, 0.)), vec3(.4), vec3(.6));
	COLOR.rgb = checker;
}