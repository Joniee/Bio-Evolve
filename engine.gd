extends Node2D

const MAX_ENEMIES = 4
var enemies := Dictionary()
var initEnemy := Array()
var enemy_base := preload("res://Enemies.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var json_data = get_meta("EnemiesR") as JSON
	var data = json_data.data
	enemies.clear()
	
	for enemy in data.get("enemies", []):
		for basic in enemy.get("basic", []):
			enemies[basic["id"]] = basic
			initEnemy.append(basic["id"])
		for evolve in enemy.get("evolves", []):
			enemies[evolve["id"]] = evolve

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	randomize()
	if(randi_range(0, 200) < 1 and get_meta("enemies_alive") < MAX_ENEMIES):
		spawnEnemy()
	print(get_meta("world_level"))
	
func spawnEnemy() -> void:
	enemy_base.instantiate()
	var specieSelection = randi_range(0, initEnemy.size()-1)
	var selectedEnemy = true
	var enemyData = enemies[initEnemy[specieSelection]]
	while (selectedEnemy):
		if(!enemyData["evolves_to"].is_empty()):
			var evolutionSelection = randi_range(0, enemyData["evolves_to"].size()-1)
			var auxEnemyData = enemies[enemyData["evolves_to"][evolutionSelection]]
			if(auxEnemyData["required_world_level"] < get_meta("world_level")):
				enemyData = auxEnemyData
			else:
				selectedEnemy = false
		else:
			selectedEnemy = false
	set_meta("enemies_alive", get_meta("enemies_alive")+1)
	print(enemyData)

	
	
