@tool
class_name PortraitPart extends AnimatedSprite2D
"res://src/common/ui/portrait/portrait.gdshader"
@export_tool_button("Run Test") var run_test_button = run_test
@export_tool_button("Generate Palette") var gen_palette_button = gen_palette
@export_tool_button("Apply Palette to Shader") var set_palette_button = set_palette

@export var palette_img : Texture2D

@export var ref_palette : PackedColorArray
@export var palettes : Array[PackedColorArray]
@export var color_index : int = 0:
	set(v):
		if validate_color_index(v): color_index = v
		apply_color()

func get_palette_img() -> Image:
	if palette_img:
		print(palette_img)
		return palette_img.get_image()
	var parent = get_parent() as Portrait
	if parent and parent.default_palette: return parent.default_palette.get_image()
	return null

func get_color_count() -> int:
	var img : Image = get_palette_img()
	if img: return img.get_height()
	return 0

func validate_color_index(v) -> bool:
	return v < get_color_count()

func apply_color():
	var ref : PackedColorArray
	var rep : PackedColorArray
	var img : Image = get_palette_img()
	var shader : ShaderMaterial = material
	if img and shader:
		for i in img.get_width():
			ref.append(img.get_pixel(i, 0))
			rep.append(img.get_pixel(i, color_index))
		shader.set_shader_parameter("og_color", ref)
		shader.set_shader_parameter("new_color", rep)

func run_test():
	apply_color()

func set_palette():
	var shader : ShaderMaterial = material
	if shader:
		for p in palettes:
			shader.set_shader_parameter("new_color", palettes[color_index])

func gen_palette():
	ref_palette.clear()
	var img = sprite_frames.get_frame_texture(animation, frame).get_image()
	for x in img.get_size().x:
		for y in img.get_size().y:
			var color = img.get_pixel(x, y)
			if not ref_palette.has(color) and color.a > 0:
				ref_palette.append(color)
	var shader : ShaderMaterial = material
	if shader:
		shader.set_shader_parameter("og_color", ref_palette)
