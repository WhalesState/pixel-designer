shader_type canvas_item;

const float precision = 0.05;

uniform vec2 rect_size = vec2(64.0);
uniform vec2 frame_size = vec2(24.0);
uniform float h_frames = 1.0;
uniform float v_frames = 1.0;
uniform float frame = 0.0;

uniform vec4 id_0: source_color = vec4(0.0, 0.0, 0.0, 1.0); // black
uniform vec4 id_1: source_color = vec4(1.0, 0.0, 0.0, 1.0); // red
uniform vec4 id_2: source_color = vec4(0.0, 1.0, 0.0, 1.0); // green
uniform vec4 id_3: source_color = vec4(0.0, 0.0, 1.0, 1.0); // blue
uniform vec4 id_4: source_color = vec4(0.2, 0.2, 0.2, 1.0); // dark gray
uniform vec4 id_5: source_color = vec4(1.0, 0.0, 1.0, 1.0); // magneta
uniform vec4 id_6: source_color = vec4(0.0, 1.0, 1.0, 1.0); // cyan
uniform vec4 id_7: source_color = vec4(1.0, 1.0, 0.0, 1.0); // yellow
uniform vec4 id_8: source_color = vec4(0.6, 0.0, 0.0, 1.0); // maroon
uniform vec4 id_9: source_color = vec4(1.0, 0.4, 0.0, 1.0); // Orange
uniform vec4 id_10: source_color = vec4(0.4, 0.0, 1.0, 1.0); // Purple
uniform vec4 id_11: source_color = vec4(0.4, 0.4, 0.4, 1.0); // gray
uniform vec4 id_12: source_color = vec4(0.0, 0.6, 0.0, 1.0); // dark green
uniform vec4 id_13: source_color = vec4(1.0, 0.6, 0.0, 1.0); // orange-ish
uniform vec4 id_14: source_color = vec4(0.6, 0.6, 0.0, 1.0); // olive
uniform vec4 id_15: source_color = vec4(0.8, 0.8, 0.8, 1.0); // silver
uniform vec4 id_16: source_color = vec4(0.6, 0.0, 0.6, 1.0); // purple-ish
uniform vec4 id_17: source_color = vec4(0.0, 0.6, 0.6, 1.0); // teal
uniform vec4 id_18: source_color = vec4(0.0, 0.0, 0.6, 1.0); // navy
uniform vec4 id_19: source_color = vec4(1.0, 1.0, 0.6, 1.0); // light yellow
uniform vec4 id_20: source_color = vec4(0.6, 1.0, 0.0, 1.0); // lime green
uniform vec4 id_21: source_color = vec4(0.0, 1.0, 0.6, 1.0); // spring green
uniform vec4 id_22: source_color = vec4(0.6, 0.0, 1.0, 1.0); // violet
uniform vec4 id_23: source_color = vec4(0.0, 0.6, 1.0, 1.0); // sky blue
uniform vec4 id_24: source_color = vec4(1.0, 0.6, 0.4, 1.0); // light orange
uniform vec4 id_25: source_color = vec4(1.0, 0.0, 0.6, 1.0); // rose
uniform vec4 id_26: source_color = vec4(1.0, 0.8, 0.8, 1.0); // pink
uniform vec4 id_27: source_color = vec4(0.0, 0.8, 0.8, 1.0); // aqua
uniform vec4 id_28: source_color = vec4(1.0, 0.4, 0.2, 1.0); // tomatoe
uniform vec4 id_29: source_color = vec4(1.0, 0.8, 0.0, 1.0); // gold
uniform vec4 id_30: source_color = vec4(0.6, 0.2, 0.2, 1.0); // brown
uniform vec4 id_31: source_color = vec4(1.0, 1.0, 1.0, 1.0); // white

uniform vec4 col_0: source_color = vec4(0.0, 0.0, 0.0, 1.0); // black
uniform vec4 col_1: source_color = vec4(1.0, 0.0, 0.0, 1.0); // red
uniform vec4 col_2: source_color = vec4(0.0, 1.0, 0.0, 1.0); // green
uniform vec4 col_3: source_color = vec4(0.0, 0.0, 1.0, 1.0); // blue
uniform vec4 col_4: source_color = vec4(0.2, 0.2, 0.2, 1.0); // dark gray
uniform vec4 col_5: source_color = vec4(1.0, 0.0, 1.0, 1.0); // magneta
uniform vec4 col_6: source_color = vec4(0.0, 1.0, 1.0, 1.0); // cyan
uniform vec4 col_7: source_color = vec4(1.0, 1.0, 0.0, 1.0); // yellow
uniform vec4 col_8: source_color = vec4(0.6, 0.0, 0.0, 1.0); // maroon
uniform vec4 col_9: source_color = vec4(1.0, 0.4, 0.0, 1.0); // Orange
uniform vec4 col_10: source_color = vec4(0.4, 0.0, 1.0, 1.0); // Purple
uniform vec4 col_11: source_color = vec4(0.4, 0.4, 0.4, 1.0); // gray
uniform vec4 col_12: source_color = vec4(0.0, 0.6, 0.0, 1.0); // dark green
uniform vec4 col_13: source_color = vec4(1.0, 0.6, 0.0, 1.0); // orange-ish
uniform vec4 col_14: source_color = vec4(0.6, 0.6, 0.0, 1.0); // olive
uniform vec4 col_15: source_color = vec4(0.8, 0.8, 0.8, 1.0); // silver
uniform vec4 col_16: source_color = vec4(0.6, 0.0, 0.6, 1.0); // purple-ish
uniform vec4 col_17: source_color = vec4(0.0, 0.6, 0.6, 1.0); // teal
uniform vec4 col_18: source_color = vec4(0.0, 0.0, 0.6, 1.0); // navy
uniform vec4 col_19: source_color = vec4(1.0, 1.0, 0.6, 1.0); // light yellow
uniform vec4 col_20: source_color = vec4(0.6, 1.0, 0.0, 1.0); // lime green
uniform vec4 col_21: source_color = vec4(0.0, 1.0, 0.6, 1.0); // spring green
uniform vec4 col_22: source_color = vec4(0.6, 0.0, 1.0, 1.0); // violet
uniform vec4 col_23: source_color = vec4(0.0, 0.6, 1.0, 1.0); // sky blue
uniform vec4 col_24: source_color = vec4(1.0, 0.6, 0.4, 1.0); // light orange
uniform vec4 col_25: source_color = vec4(1.0, 0.0, 0.6, 1.0); // rose
uniform vec4 col_26: source_color = vec4(1.0, 0.8, 0.8, 1.0); // pink
uniform vec4 col_27: source_color = vec4(0.0, 0.8, 0.8, 1.0); // aqua
uniform vec4 col_28: source_color = vec4(1.0, 0.4, 0.2, 1.0); // tomatoe
uniform vec4 col_29: source_color = vec4(1.0, 0.8, 0.0, 1.0); // gold
uniform vec4 col_30: source_color = vec4(0.6, 0.2, 0.2, 1.0); // brown
uniform vec4 col_31: source_color = vec4(1.0, 1.0, 1.0, 1.0); // white

vec4 swap_color(vec4 color) {
	vec4 original_colors[32] = vec4[32] (
		id_0, id_1, id_2, id_3, id_4, id_5, id_6, id_7, id_8, id_9, id_10, id_11,
		id_12, id_13, id_14, id_15, id_16, id_17, id_18, id_19, id_20, id_21, id_22,
		id_23, id_24, id_25, id_26, id_27, id_28, id_29, id_30, id_31 
	);
	vec4 replace_colors[32] = vec4[32] (
		col_0 , col_1, col_2, col_3, col_4, col_5, col_6, col_7, col_8, col_9, col_10, col_11,
		col_12, col_13, col_14, col_15, col_16, col_17, col_18, col_19, col_20, col_21,
		col_22, col_23, col_24, col_25, col_26, col_27, col_28, col_29, col_30, col_31
	);
	for (int i = 0; i < 32; i ++) {
		if (distance(color, original_colors[i]) <= precision) {
			return replace_colors[i];
		}
	}
	return color;
}

void fragment() {
	vec2 uv = UV;
	uv /= rect_size/frame_size;
	uv.x += float(int(frame) % int(h_frames))/h_frames;
	uv.y += floor((frame + 1.0)/h_frames)/v_frames;
	COLOR = swap_color(texture(TEXTURE, uv));
}
