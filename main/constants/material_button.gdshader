shader_type canvas_item;

const float precision = 0.1;

// outline
uniform vec4 id_0: source_color = vec4(0.0, 0.0, 0.0, 1.0); // black
uniform vec4 id_1: source_color = vec4(0.2, 0.2, 0.2, 1.0); // dark gray
// shading
uniform vec4 id_2: source_color = vec4(0.0, 0.0, 1.0, 1.0); // blue
uniform vec4 id_3: source_color = vec4(1.0, 0.0, 0.0, 1.0); // red
uniform vec4 id_4: source_color = vec4(0.0, 1.0, 0.0, 1.0); // green
uniform vec4 id_5: source_color = vec4(1.0, 0.0, 1.0, 1.0); // magneta
uniform vec4 id_6: source_color = vec4(1.0, 1.0, 0.0, 1.0); // yellow
uniform vec4 id_7: source_color = vec4(0.0, 1.0, 1.0, 1.0); // cyan
// highlight
uniform vec4 id_8: source_color = vec4(1.0, 1.0, 1.0, 1.0); // white
// shadow
uniform vec4 id_9: source_color = vec4(0.4, 0.4, 0.4, 1.0); // gray

uniform vec4 col_0: source_color = vec4(0.0, 0.0, 0.0, 1.0); // black
uniform vec4 col_1: source_color = vec4(0.2, 0.2, 0.2, 1.0); // dark gray
uniform vec4 col_2: source_color = vec4(0.0, 0.0, 1.0, 1.0); // blue
uniform vec4 col_3: source_color = vec4(1.0, 0.0, 0.0, 1.0); // red
uniform vec4 col_4: source_color = vec4(0.0, 1.0, 0.0, 1.0); // green
uniform vec4 col_5: source_color = vec4(1.0, 0.0, 1.0, 1.0); // magneta
uniform vec4 col_6: source_color = vec4(1.0, 1.0, 0.0, 1.0); // yellow
uniform vec4 col_7: source_color = vec4(0.0, 1.0, 1.0, 1.0); // cyan 
uniform vec4 col_8: source_color = vec4(1.0, 1.0, 1.0, 1.0); // white
uniform vec4 col_9: source_color = vec4(0.4, 0.4, 0.4, 1.0); // gray

vec4 swap_color(vec4 color) {
	vec4 original_colors[10] = vec4[10] (
		id_0, id_1, id_2, id_3, id_4, id_5, id_6, id_7, id_8, id_9
	);
	vec4 replace_colors[10] = vec4[10] (
		col_0 , col_1, col_2, col_3, col_4, col_5, col_6, col_7, col_8, col_9
	);
	for (int i = 0; i < 10; i ++) {
		if (distance(color, original_colors[i]) <= precision) {
			return replace_colors[i];
		}
	}
	return color;
}

void fragment() {
	COLOR = swap_color(texture(TEXTURE, UV));
}
