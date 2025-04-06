extends Panel

signal transition_finished

var shader_mat : ShaderMaterial

const duration = 1.0   # トランジション時間
var shader_value := 0.0    # シェーダに渡す値
var is_fading := false  # 処理のスイッチ
var fade_in = true

func _init() -> void:
	shader_mat = material as ShaderMaterial

func _ready() -> void:
	is_fading = true
	shader_value = 0.0

func fade_out():
	fade_in = false
	is_fading = true
	await transition_finished

func _process(delta: float):
	# トランジション(フェード)処理
	if is_fading:
		if fade_in:
			shader_value = min(1.0, shader_value + delta / duration)
			# シェーダマテリアルに値をセット
			shader_mat.set_shader_parameter("Value", shader_value)
			if shader_value >= 1.0:
				is_fading = false
				transition_finished.emit()
		else:
			shader_value = max(0.0, shader_value - delta / duration)
			if shader_value <= 0.0:
				is_fading = false
				transition_finished.emit()
