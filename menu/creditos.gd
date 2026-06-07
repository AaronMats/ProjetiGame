extends Control

func _on_texture_button_pressed() -> void:
	# volta para o menu principal 
	get_tree().change_scene_to_file("res://menu/menu_principal.tscn")
