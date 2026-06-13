extends Control

func _ready():
	visible = false

# Inverte a visibilidade do menu
func alternar_pause():
	visible = not visible
	# Pausa ou despausa o motor de jogo da Godot
	get_tree().paused = visible

# --- CONEXÃO DOS BOTÕES ---
func _on_botao_continuar_pressed():
	alternar_pause() 

func _on_botao_reiniciar_pressed():
	get_tree().paused = false 
	get_tree().reload_current_scene() 

func _on_botao_menu_pressed():
	get_tree().paused = false 
	get_tree().change_scene_to_file("res://menu/seletor_fases.tscn")
