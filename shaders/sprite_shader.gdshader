/* Authors:
	Hue shift -> https://github.com/vmedea
		https://gist.github.com/mairod/a75e7b44f68110e1576d77419d608786?permalink_comment_id=4438484#gistcomment-4438484
	Dither -> https://godotshaders.com/author/whiteshampoo/
		https://godotshaders.com/shader/color-reduction-and-dither/
	Color quantization -> https://gamedev.stackexchange.com/questions/111319/webgl-color-quantization */

shader_type canvas_item;
render_mode unshaded;

group_uniforms colors;
uniform bool use_256_colors = false;
uniform bool invert_colors = false;
uniform float hue : hint_range(0.0, 359.0, 1.0) = 0.0;
uniform float brightness = 1.0;
uniform float contrast = 1.0;
uniform float gamma = 1.0;
uniform float alpha_limit : hint_range(0.0, 1.0) = 0.0;
uniform float lock_alpha : hint_range(0.0, 1.0) = 0.0;

group_uniforms posterize;
uniform bool posterize = false;
uniform float posterize_levels : hint_range(0.1, 5.0) = 1.0;
uniform float dither : hint_range(0.0, 0.5) = 0.0;
uniform bool invert_dither_x = true;
uniform bool invert_dither_y = true;

group_uniforms grayscale;
uniform bool grayscale = false;
uniform bool limit = false;
uniform float limit_range : hint_range(1.0, 32.0) = 8.0;
uniform bool use_levels = false;
uniform sampler2D levels : hint_default_black;

vec3 hue_shift(vec3 color, float dhue) {
	float s = sin(dhue);
	float c = cos(dhue);
	return (color * c) + (color * s) * mat3(
		vec3(0.167444, 0.329213, -0.496657),
		vec3(-0.327948, 0.035669, 0.292279),
		vec3(1.250268, -1.047561, -0.202707)
	) + dot(vec3(0.299, 0.587, 0.114), color) * (1.0 - c);
}

void fragment() {
	if (hue != 0.0) {
		COLOR.rgb = hue_shift(COLOR.rgb, radians(hue));
	}
	if (brightness != 1.0) {
		COLOR.rgb += brightness - 1.0;
	}
	if (contrast != 1.0) {
		COLOR.rgb = ((COLOR.rgb - 0.5f) * max(contrast, 0)) + 0.5;
	}
	if (gamma != 1.0) {
		COLOR.rgb = pow(COLOR.rgb, vec3(gamma));
	}
	if (alpha_limit > 0.0 && COLOR.a < 1.0 && COLOR.a < alpha_limit) {
		COLOR.a = 0.0;
	}
	if (lock_alpha > 0.0 && COLOR.a > 0.0 && COLOR.a < lock_alpha) {
		COLOR.a = 1.0;
	}
	if (posterize) {
		float colors = 6.0;
		float a = floor(mod(SCREEN_UV.x / SCREEN_PIXEL_SIZE.x, 2.0));
		if (invert_dither_x) {
			a = 1.0 - a;
		}
		float b = floor(mod(SCREEN_UV.y / SCREEN_PIXEL_SIZE.y, 2.0));
		if (invert_dither_y) {
			b = 1.0 - b;
		}
		float c = mod(a + b, 2.0);
		vec3 col = COLOR.rgb;
		vec3 res = vec3(8.0, 8.0, 4.0) * posterize_levels;
		COLOR.rgb = (floor(col.rgb * (res - 1.0) + 0.5 + dither) / (res - 1.0)) * c;
		c = 1.0 - c;
		COLOR.rgb += (floor(col.rgb * (res - 1.0) + 0.5 - dither) / (res - 1.0)) * c;
	}
	if (use_256_colors) {
		vec3 color_resolution = vec3(8.0, 8.0, 4.0);
		vec3 color_bands = floor(COLOR.rgb * color_resolution) / (color_resolution - 1.0);
		COLOR = vec4(min(color_bands, 1.0), COLOR.a);
	}
	if (grayscale) {
		float input = dot(COLOR.rgb, vec3(0.299, 0.587, 0.114));
		if (limit) {
			float range = limit_range - 1.0;
			input = floor(input * range) / range;
		}
		vec4 adjusted = use_levels ? texture(levels, vec2(input, 0.0)) : vec4(vec3(input), COLOR.a);
		COLOR = mix(COLOR, adjusted, COLOR.a);
	}
	if (invert_colors) {
		COLOR.rgb = 1.0 - COLOR.rgb;
	}
}
