extends CharacterBody2D

@export var player: CharacterBody2D
@export var weapon: CharacterBody2D
@export var map: PackedByteArray

signal enemy_dead(increase_world: float)

var bullet := preload("res://Projectiles.tscn")

var enemyName = String()
var armor = 0
var damage = 0
var speed = 0
var min_speed = 0
var maxDashduration = 0.0
var dashDuration = 0.4
var dashCooldown = 1
var dashTimer = 0.0
var actions = []

const JUMP_VELOCITY = 300.0

var decision_timer := 0.0
var erratic_direction := 0
var previous_distance_to_player := 9999.0

var jumpCD := 1.5
var jumpTimer := 0.0

const TAKEDAMAGE_COOLDOWN = 0.05
var invulnerability_timer := 0.0

var max_hp := 50.0
var health := 50.0

var input_vector: Vector2

func setEnemy(enemyData: Variant):
	enemyName = enemyData["name"]
	armor = enemyData["armor"]
	damage = enemyData["damage"]
	min_speed = enemyData["speed"]
	speed = enemyData["speed"]
	max_hp = enemyData["health"]
	health = max_hp
	actions = enemyData["actions"]
	
	var sprite = find_child("Sprite2D", true, false)
	sprite.texture = load(enemyData["path"])
	

func _physics_process(delta: float) -> void:
	jumpAction(delta)
	moveAction()
	dashTimer -= delta
	collisionDetection()
	if(dashTimer < 0):
		speed = min_speed
	
	if(invulnerability_timer > 0):
		invulnerability_timer -= 0.1 * delta
	
	$DamageTaken.text = str(health)
	
	if(health <= 0):
		enemy_dead.emit(2)
		queue_free()
	if(global_position.distance_to(player.global_position) > 2000.0):
		enemy_dead.emit(0.0)
		queue_free()
	move_and_slide()
	
func collisionDetection():
	for i in get_slide_collision_count():
		if(get_slide_collision(i).get_collider() == player):
			player.takeDamage(damage)
		if(get_slide_collision(i).get_collider() == weapon):
			takeDamage(weapon.damage)
	
func moveAction():
	if input_vector.x > 0:
		velocity.x = speed * input_vector.x
		$Sprite2D.flip_h = false
	elif input_vector.x < 0:
		velocity.x = speed * input_vector.x
		$Sprite2D.flip_h = true
	else:
		velocity.x = 0

func jumpAction(delta: float):
	if not is_on_floor():
		velocity += get_gravity() * delta
	elif (is_on_floor() and jumpTimer < 0)	:
		velocity.y = -JUMP_VELOCITY
		jumpTimer = jumpCD
	jumpTimer -= delta
	
func dashAction():
	if input_vector.x > 0 and is_on_floor():
		speed = 0
		get_child(4).self_modulate = Color(0.5, 0.0, 0.0, 1.0)
		await get_tree().create_timer(0.5).timeout
		speed = min_speed
		speed *= 4
		dashTimer = dashDuration
		$Sprite2D.flip_h = false
	elif input_vector.x < 0 and is_on_floor():
		speed = 0
		get_child(4).self_modulate = Color(0.5, 0.0, 0.0, 1.0)
		await get_tree().create_timer(0.5).timeout
		speed = min_speed
		speed *=4
		dashTimer = dashDuration
		$Sprite2D.flip_h = true
	else:
		velocity.x = 0
	get_child(4).self_modulate = Color.WHITE
	
func scratchAction():
	if input_vector.x > 0:
		$Sprite2D.flip_h = false
	elif input_vector.x < 0:
		$Sprite2D.flip_h = true
	else:
		velocity.x = 0
	
func shootAction():
	var newBullet = bullet.instantiate()
	newBullet.dir = global_position.direction_to(player.global_position)
	newBullet.shooter = self
	newBullet.init_position = global_position
	add_child(newBullet)
	
func takeDamage(damage: float) -> void:
	if(invulnerability_timer <= 0.0):
		if(damage-armor < 0):
			damage = 1
		else:
			damage -= armor
		health -= damage
		position.x -= 10
		invulnerability_timer = TAKEDAMAGE_COOLDOWN
