shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

uniform vec4 og_color[10] : source_color;
uniform vec4 new_color[10] : source_color;

void fragment() {
	vec4 curr_color = texture(TEXTURE, UV);
	uvec4 uint_curr_color = uvec4(round(curr_color * 255.0));
	for (int i = 0; i < og_color.length(); i++) {
		if (og_color[i].a == 0.0) {
			continue;
		}

	    // Define a threshold for the comparison
		uvec4 uint_og_color = uvec4(round(og_color[i] * 255.0));
		if (uint_curr_color == uint_og_color){
			COLOR = new_color[i];
			break;
		}
		else{
			COLOR = curr_color;
		}
	}
}
