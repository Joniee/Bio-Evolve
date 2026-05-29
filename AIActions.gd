extends Node
class_name AIControllerActions

# --- NODOS ---
@export var sensor_node: Node  # Tu EnemySensor de C++
var enemy: CharacterBody2D

const PATH = "res://resources/AIController/action.json"

var weight_combat: Array = []  

const L_RATE_COMBAT = 0.15   

var combat_event_score := 0.0

const AUTO_SAVE_INTERVAL = 6.0
var save_timer := 0.0

const attack_cooldown = 0.5
var attack_timer := 0.5


func _ready() -> void:
	enemy = get_parent() as CharacterBody2D

	if not load_complete_brain():
		initialize_all_weights()
		save_complete_brain()

func _physics_process(delta: float) -> void:
	if not sensor_node or not enemy or not enemy.player or not ("actions" in enemy):
		return
		
	var vision = sensor_node.get_8_wayVision(enemy.global_position, enemy.map, 16, Vector2i(512,64))
	var dir_to_player = enemy.global_position.direction_to(enemy.player.global_position)
	
	# Vector (13 elementos en total):
	# Indices [0..7]   -> Sensor 8WayVision (1.0 = Vacío, 0.0 = Colisión)
	# Indices [8..9]   -> Vector director hacia el jugador (X, Y)
	# Index   [10]     -> Habilidad "Scratch" 
	# Index   [11]     -> Habilidad "Dash" 
	# Index   [12]     -> Habilidad "Shoot" 
	var entradas = []
	for v in vision:
		entradas.append(v)
	entradas.append(dir_to_player.x)
	entradas.append(dir_to_player.y)
	
	entradas.append(1.0 if ("scratch" in enemy.actions) else 0.0)
	entradas.append(1.0 if ("dash" in enemy.actions) else 0.0)
	entradas.append(1.0 if ("shoot" in enemy.actions) else 0.0)


	var out_scratch := 0.0
	var out_dash := 0.0
	var out_shoot := 0.0
	for i in range(13):
		out_scratch += entradas[i] * weight_combat[0][i]
		out_dash += entradas[i] * weight_combat[1][i]
		out_shoot += entradas[i] * weight_combat[2][i]
		
	var want_to_scratch = (tanh(out_scratch) > 0.1)
	var want_to_dash = (tanh(out_dash) > 0.1)
	var want_to_shoot = (tanh(out_shoot) > 0.1)

	attack_timer -= delta
	
	if want_to_scratch and "scratch" in enemy.actions and attack_timer < 0:
		enemy.scratchAction()
		attack_timer = attack_cooldown
	if want_to_dash and "dash" in enemy.actions and attack_timer < 0:
		enemy.dashAction()
		attack_timer = attack_cooldown
	if want_to_shoot and "shoot" in enemy.actions and attack_timer < 0:
		enemy.shootAction()
		attack_timer = attack_cooldown
	
	_train_combat(entradas, want_to_scratch, want_to_dash, want_to_shoot)


	save_timer += delta
	if save_timer >= AUTO_SAVE_INTERVAL:
		save_timer = 0.0
		save_complete_brain()

func _train_combat(entradas: Array, want_to_scratch: bool, want_to_dash: bool, want_to_shoot: bool) -> void:
	var reward_combat := 0.0
	var current_dist = enemy.global_position.distance_to(enemy.player.global_position)
	

	if want_to_scratch and "scratch" in enemy.actions:
		if current_dist > 80.0: 
			reward_combat -= 0.5 
			

	if want_to_dash and "dash" in enemy.actions:
		for i in range(8):
			if entradas[i] < 0.2:
				reward_combat -= 0.2 
	
	reward_combat += combat_event_score
	combat_event_score = 0.0 

	if reward_combat < 0:
		for i in range(13):
			if "scratch" in enemy.actions:
				weight_combat[0][i] += randf_range(-L_RATE_COMBAT, L_RATE_COMBAT) * entradas[i]
			if "dash" in enemy.actions:
				weight_combat[1][i] += randf_range(-L_RATE_COMBAT, L_RATE_COMBAT) * entradas[i]
			if "shoot" in enemy.actions:
				weight_combat[2][i] += randf_range(-L_RATE_COMBAT, L_RATE_COMBAT) * entradas[i]

func register_combat_event(score: float) -> void:
	combat_event_score += score

func initialize_all_weights() -> void:

	weight_combat = [[], [], []]
	for i in range(13):
		weight_combat[0].append(randf_range(-1.0, 1.0)) # Pesos Scratch
		weight_combat[1].append(randf_range(-1.0, 1.0)) # Pesos Dash
		weight_combat[2].append(randf_range(-1.0, 1.0)) # Pesos Shoot

func save_complete_brain() -> void:
	var datos_unificados = {
		"weight_combat": weight_combat
	}
	var json_string = JSON.stringify(datos_unificados)

			
	var file = FileAccess.open(PATH, FileAccess.WRITE)
	if file:
		file.store_string(json_string)
		file.close()

func load_complete_brain() -> bool:
	if FileAccess.file_exists(PATH):
		var file = FileAccess.open(PATH, FileAccess.READ)
		if file:
			var json_string = file.get_as_text()
			file.close()
			var json = JSON.new()
			if json.parse(json_string) == OK:
				var datos = json.data
				if _validar_estructura_cerebro(datos):
					weight_combat = datos["weight_combat"]
					return true
				

	if FileAccess.file_exists(PATH):
		var file = FileAccess.open(PATH, FileAccess.READ)
		if file:
			var json_string = file.get_as_text()
			file.close()
			var json = JSON.new()
			if json.parse(json_string) == OK:
				var datos = json.data
				if _validar_estructura_cerebro(datos):
					weight_combat = datos["weight_combat"]
					return true
				
	return false

func _validar_estructura_cerebro(datos: Variant) -> bool:
	if datos.has("weight_combat"):
		var p_com = datos["weight_combat"]
		if p_com.size() == 3 and p_com[0].size() == 13:
			return true
	return false


func _exit_tree() -> void:
	save_complete_brain()
