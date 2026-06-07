extends Control



func _ready():
	# O menu começa escondido quando a fase inicia
	visible = false

func _input(event):
	# Abre ou fecha o pause ao apertar a tecla ESC ou clique no botão de pause se tiver
	if event.is_action_pressed("ui_cancel"):
		alternar_pause()

func alternar_pause():
	# Inverte a visibilidade do menu (se está visível esconde, se está escondido mostra)
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
