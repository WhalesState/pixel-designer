/* Authors:
	https://godotshaders.com/author/juulpower/
		https://godotshaders.com/shader/2d-outline-inline/
	https://godotshaders.com/author/sirlich/
		https://godotshaders.com/shader/2d-outline-inline-configured-for-canvasgroup */

shader_type canvas_item;
render_mode unshaded;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, repeat_disable, filter_nearest;
uniform vec4 color : source_color = vec4(1.0); // Outline Color.
uniform float alpha : hint_range(0.0, 1.0) = 1; // Global alpha (texture and outlines).
uniform int pattern : hint_range(0, 2) = 0; // 0 = Diamond, 1 = Circle, 2 = Square.
uniform float width : hint_range(0.0, 16.0, 1.0) = 0.0; // values greater than 8 (px) may affect performance.
// Screen limit. Usefull to remove bottom outlines in top down sprites.
uniform float screen_top_limit : hint_range(0.0, 1.0) = 0.0;
uniform float screen_bottom_limit: hint_range(0.0, 1.0) = 1.0;
uniform float screen_left_limit: hint_range(0.0, 1.0) = 0.0;
uniform float screen_right_limit: hint_range(0.0, 1.0) = 1.0;

void fragment() {
	vec4 final_color = textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0);
	if (final_color.a > 0.0001) {
		final_color.rgb /= final_color.a;
	}
	vec4 mixed_color = COLOR * final_color;
	if (width > 0.0 && alpha > 0.0) {
		float outline = 0.0;
		for (float i = -floor(width); i <= floor(width); i++) {
			float x = abs(i) > floor(width) ? floor(width) * sign(i) : i;
			float offset;
			if (pattern == 0) {
				offset = floor(width) - abs(x);
			} else if (pattern == 1) {
				offset = floor(sqrt(pow(floor(width) + 0.5, 2) - x * x));
			} else if (pattern == 2) {
				offset = floor(width);
			}
			for (float j = -ceil(offset); j <= ceil(offset); j++) {
				float y = abs(j) > offset ? offset * sign(j) : j;
				vec2 xy = SCREEN_UV + SCREEN_PIXEL_SIZE * vec2(x, y);
				if ((xy != clamp(xy, vec2(0.0), vec2(1.0)) || texture(SCREEN_TEXTURE, xy).a <= 0.0) == false) {
					outline += texture(SCREEN_TEXTURE, xy).a;
				}
			}
		}
		outline = min(outline, 1.0);
		COLOR = mix(mixed_color, color, outline - final_color.a);
		if (SCREEN_UV.y < screen_top_limit || SCREEN_UV.y > screen_bottom_limit || SCREEN_UV.x < screen_left_limit || SCREEN_UV.x > screen_right_limit) {
			COLOR = mixed_color;
		}
	} else {
		COLOR = mixed_color;
	}
	if (COLOR.a != 0.0) {
		COLOR.a *= alpha;
	}
}
