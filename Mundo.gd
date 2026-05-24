extends Node2D

# --- VARIÁVEIS DO JOGO ---
var total_objetos_fase = 3   # Mude este número para o total de chaves que você colocou na tela
var objetos_encontrados = 0
var total_cliques = 0
var fase_encerrada = false

# --- REFERÊNCIAS DA INTERFACE ---
@onready var label_cliques = $CanvasLayer/LabelCliques
@onready var label_objetos = $CanvasLayer/LabelObjetos
@onready var label_final = $CanvasLayer/LabelFinal
@onready var botao_terminar = $CanvasLayer/BotaoTerminar

func _ready():
	# Configuração inicial do texto na tela
	label_cliques.text = "Cliques: 0"
	label_objetos.text = "Objetos Achados: 0"
	label_final.text = ""

# --- DETECTOR DE CLIQUES GERAIS NO CENÁRIO ---
# Esta função roda sempre que QUALQUER clique acontece na tela
func _input(event):
	if fase_encerrada:
		return # Se o jogo acabou, não conta mais nada
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# --- NOVA CHECAGEM AQUI ---
			# Verifica se o botão terminar está visível E se o mouse está exatamente em cima dele
			if botao_terminar.visible and botao_terminar.get_global_rect().has_point(event.global_position):
				return # Se o clique foi em cima do botão, sai da função sem somar!
		
	if event is InputEventMouseButton:
		# Se o jogador clicou com o botão esquerdo do mouse
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			total_cliques += 1
			label_cliques.text = "Cliques: " + str(total_cliques)

# --- FUNÇÃO GENÉRICA PARA QUANDO ACHA UM OBJETo ---
func objeto_clicado(nome_do_objeto):
	if fase_encerrada:
		return
		
	# 1. Contabiliza o objeto achado e atualiza a interface
	objetos_encontrados += 1
	label_objetos.text = "Objetos Achados: " + str(objetos_encontrados)
	
	# 2. Pega o objeto clicado
	var objeto = get_node(nome_do_objeto)
	
	# Garante que o objeto fique na frente de tudo na tela durante a animação
	if objeto is Node2D:
		objeto.z_index = 10
	
	# 3. CRIANDO A ANIMAÇÃO DE CRESCER SUAVEMENTE
	# Criamos um "gerenciador de transição" (Tween)
	var tween_crescer = create_tween()
	
	# Dizemos: Anime a propriedade "scale" (escala) do 'objeto' para Vector2(3,3) em 0.3 segundos
	# O '.set_trans(Tween.TRANS_BACK)' dá um efeito elástico bem legal no final do crescimento!
	tween_crescer.tween_property(objeto, "scale", Vector2(3, 3), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	# 4. ESPERA: Aguarda a animação de crescer terminar + 1 segundo de folga
	await tween_crescer.finished
	await get_tree().create_timer(1.0).timeout
	
	# 5. CRIANDO A ANIMAÇÃO DE SUMIR SUAVEMENTE (FADE-OUT)
	var tween_sumir = create_tween()
	
	# Color(1, 1, 1, 0) significa manter a cor original mas deixar o 'Alpha' (transparência) em 0
	tween_sumir.tween_property(objeto, "modulate", Color(1, 1, 1, 0), 0.3)
	
	# 6. ESPERA o fade-out terminar para deletar o objeto com segurança
	await tween_sumir.finished
	objeto.queue_free()

# --- SINAIS DAS CHAVES (Conecte cada uma aqui) ---
func _on_Chave_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		objeto_clicado("Obj01")

func _on_Chave2_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		objeto_clicado("Obj02")

func _on_Chave3_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		objeto_clicado("Obj03")

#func _on_Chave4_input_event(viewport, event, shape_idx):
#	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
#		objeto_clicado("Chave4")
#
#func _on_Chave5_input_event(viewport, event, shape_idx):
#	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
#		objeto_clicado("Chave5") 


# --- SINAL DO BOTÃO TERMINAR FASE ---
func _on_BotaoTerminar_pressed():
	if fase_encerrada:
		return
		
	fase_encerrada = true

	
	# Conta matemática para descobrir a porcentagem de acerto
	# Usamos float() para a divisão aceitar números quebrados antes de multiplicar por 100
	var pontuacao = (float(objetos_encontrados) / float(total_objetos_fase)) * 100
	
	# Esconde o botão para o jogador não clicar de novo
	botao_terminar.visible = false
	
	# Mostra o resultado final na tela
	label_final.text = "--- FIM DE JOGO ---\n"
	label_final.text += "Pontuação Final: " + str(int(pontuacao)) + "%\n"
	label_final.text += "Total de Cliques: " + str(total_cliques)
