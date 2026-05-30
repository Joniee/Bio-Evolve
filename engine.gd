extends Node2D

@export var enemiesBasics: Node2D
@export var enemiesNode: Node2D
@export var player: CharacterBody2D
@export var weapon: CharacterBody2D
@export var map: Node2D

const MAX_ENEMIES = 4
var enemies := Dictionary()
var initEnemy := Array()
var enemy_base := preload("res://Enemies.tscn")
var boss := preload("res://Boss.tscn")

var world_level := 1.0
var enemies_alive := 0
var bosses_alive := 0

var deads := 0


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


func _process(delta: float) -> void:
	randomize()
	if(randi_range(0, 200) < 1 and enemies_alive < MAX_ENEMIES):
		spawnEnemy()
	if(world_level > 200.0 and bosses_alive < 1):
		bosses_alive += 1
		spawnBoss()
	
func spawnEnemy() -> void:
	var newEnemy = enemy_base.instantiate() as CharacterBody2D
	newEnemy.player = player
	newEnemy.weapon = weapon
	newEnemy.map = map.map
	newEnemy.enemy_dead.connect(_on_enemy_dead)
	var spawnArea = randi_range(0,1)
	if spawnArea == 0:	newEnemy.position.x = player.position.x - (80*16)
	else: newEnemy.position.x = player.position.x + (80*16)
	enemiesBasics.add_child(newEnemy)
	var specieSelection = randi_range(0, initEnemy.size()-1)
	var selectedEnemy = true
	var enemyData = enemies[initEnemy[specieSelection]]
	while (selectedEnemy):
		if(!enemyData["evolves_to"].is_empty()):
			var evolutionSelection = randi_range(0, enemyData["evolves_to"].size()-1)
			var auxEnemyData = enemies[enemyData["evolves_to"][evolutionSelection]]
			if(auxEnemyData["required_world_level"] < world_level):
				enemyData = auxEnemyData
			else:
				selectedEnemy = false
		else:
			selectedEnemy = false
	enemies_alive += 1
	newEnemy.setEnemy(enemyData)

func spawnBoss() -> void:
	var newBoss = boss.instantiate() as CharacterBody2D
	newBoss.player = player
	newBoss.weapon = weapon
	newBoss.map = map.map
	newBoss.global_position = player.global_position
	newBoss.global_position.y -= 90
	newBoss.boss_dead.connect(_on_boss_dead)
	enemiesNode.add_child(newBoss)

func _on_enemy_dead(inc: float):
	enemies_alive -= 1
	world_level += inc
	pass
	
func _on_boss_dead():
	bosses_alive -= 1
	get_tree().change_scene_to_file("res://Main menu.tscn")
