extends Node
class_name AIControllerMovement


@export var sensor_node: Node
var enemy: CharacterBody2D

var weightMatrix: Array = []

const L_RATE = 0.04

const AUTO_SAVE_INTERVAL = 5.0
var save_timer := 0.0

const PATH = "res://resources/AIController/move.json"
const PATH_INIT = "res://resources/AIController/move_init.json"


func _ready() -> void:
	enemy = get_parent() as CharacterBody2D

	if not load_weights():
		initialize_random_weights()
		save_weights()

func _physics_process(delta: float) -> void:
	if not sensor_node or not enemy or not enemy.player:
		return
		
	var vision = sensor_node.get_8_wayVision(enemy.global_position, enemy.map, 16, Vector2i(512,64))
	var dir_to_player = enemy.global_position.direction_to(enemy.player.global_position)

	# Vector (10 elementos en total):
	# Indices [0..7]   -> Sensor 8WayVision (1.0 = Vacío, 0.0 = Colisión)
	# Indices [8..9]   -> Vector director hacia el jugador (X, Y)
	var entradas = []
	for v in vision:
		entradas.append(v)
	entradas.append(dir_to_player.x)
	entradas.append(dir_to_player.y)

	var out_x := 0.0
	var out_y := 0.0
	
	for i in range(10):
		out_x += entradas[i] * weightMatrix[0][i]
		out_y += entradas[i] * weightMatrix[1][i]
		
	enemy.input_vector.x = tanh(out_x)
	enemy.input_vector.y = tanh(out_y)
	_process_learning(entradas)

	save_timer += delta
	if save_timer >= AUTO_SAVE_INTERVAL:
		save_timer = 0.0
		save_weights()

func _process_learning(entradas: Array) -> void:
	var reward := 0.0

	for i in range(8):
		if entradas[i] < 0.15:
			reward -= 0.5

	var current_dist = enemy.global_position.distance_to(enemy.player.global_position)
	if current_dist < enemy.previous_distance_to_player:
		reward += 0.15
	else:
		reward -= 0.15
		
	enemy.previous_distance_to_player = current_dist


	if reward < 0:
		for i in range(10):
			weightMatrix[0][i] += randf_range(-L_RATE, L_RATE) * entradas[i]
			weightMatrix[1][i] += randf_range(-L_RATE, L_RATE) * entradas[i]

func initialize_random_weights() -> void:
	weightMatrix = [[], []] # Fila 0 para X, Fila 1 para Y
	for i in range(10):
		weightMatrix[0].append(randf_range(-1.0, 1.0))
		weightMatrix[1].append(randf_range(-1.0, 1.0))

func save_weights() -> void:
	var file = FileAccess.open(PATH, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(weightMatrix)
		file.store_string(json_string)
		file.close()

func load_weights() -> bool:
	if not FileAccess.file_exists(PATH):
		var file = FileAccess.open(PATH_INIT, FileAccess.READ)
		if file:
			var json_string = file.get_as_text()
			file.close()
			var json = JSON.new()
			if json.parse(json_string) == OK:
				weightMatrix = json.data
				return true
	else:
		var file = FileAccess.open(PATH, FileAccess.READ)
		if file:
			var json_string = file.get_as_text()
			file.close()
			var json = JSON.new()
			if json.parse(json_string) == OK:
				weightMatrix = json.data
				return true
	return false

func _exit_tree() -> void:
	save_weights()
