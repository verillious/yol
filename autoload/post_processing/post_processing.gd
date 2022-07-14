extends CanvasLayer

var _impact_duration := 0.0


func _process(delta: float) -> void:
	if not _impact_duration <= 0.0:
		_impact_duration = max(0.0, _impact_duration - delta)
		if _impact_duration == 0.0:
			set_pixel_size()
			set_vignette()
			set_ca()


func toggle_crt(enabled := true) -> void:
	get_node("CRT").material.set_shader_param("show_horizontal_scan_lines", enabled)


func toggle_blur(enabled := true) -> void:
	get_node("Blur").visible = enabled


func toggle_tv(enabled := true) -> void:
	get_node("TV").visible = enabled


func toggle_sharpen(enabled := true) -> void:
	get_node("Sharpness").visible = enabled


func toggle_grain(enabled := true) -> void:
	get_node("CRT").material.set_shader_param("show_grain", enabled)


func toggle_vignette(enabled := true) -> void:
	get_node("CRT").material.set_shader_param("show_vignette", enabled)


func toggle_dirt(enabled := true) -> void:
	get_node("Dirt").visible = enabled


func set_ca(new_amount := 0.75) -> void:
	get_node("CRT").material.set_shader_param("aberration_amount", new_amount)


func toggle_ca(enabled := true) -> void:
	get_node("CRT").material.set_shader_param("show_ca", enabled)


func set_pixel_size(pixel_size := 0) -> void:
	get_node("CRT").material.set_shader_param("pixel_size", pixel_size)


func set_vignette(new_size := 4.0, new_opacity := 0.15) -> void:
	get_node("CRT").material.set_shader_param("vignette_size", new_size)
	get_node("CRT").material.set_shader_param("vignette_opacity", new_opacity)


func impact(size := 2, duration := 0.1) -> void:
	set_pixel_size(size)
	set_vignette(2.0 + size * 2)
	set_ca(size * 3)
	_impact_duration = duration
