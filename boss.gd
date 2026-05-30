extends CharacterBody2D

@export var player: CharacterBody2D
@export var weapon: CharacterBody2D
@export var map: PackedByteArray

@onready var sprite: Sprite2D = $Sprite2D
@onready var colliderF1: CollisionShape2D = $CollisionFase1
@onready var AIController: AIControllerMovement = $AIMoveController

enum BossState { FASE1, FASE1_DASH, FASE2 }
var current_state: BossState = BossState.FASE1

var bullet := preload("res://Projectiles.tscn")

signal boss_dead()

var health := 500.0

var previous_distance_to_player := 9999.0

var dashSpeed := 300.0
var dashCooldown := 2.0
var dashTimer := 3.0
var dashDuration: Vector2i = Vector2i(3, 6)
var dashDurationTimer := 0.0
var dashDirection := Vector2()

var damage := 50

var shootCooldown := 1.0
var shootTimer:= 2.0

var speed = 200
var jumpCD := 1.5
var jumpTimer := 0.0
const JUMP_VELOCITY = 300.0

var input_vector: Vector2

func _ready() -> void:
	AIController.process_mode = PROCESS_MODE_DISABLED
	

func _physics_process(delta: float) -> void:
	collisionDetection()
	match current_state:
		BossState.FASE1:
			fase1(delta)
		BossState.FASE1_DASH:
			dash(delta)
		BossState.FASE2:
			fase2(delta)

	$DamageTaken.text = str(health)
	move_and_slide()

func collisionDetection():
	for i in get_slide_collision_count():
		if(get_slide_collision(i).get_collider() == player):
			player.takeDamage(damage)
		if(get_slide_collision(i).get_collider() == weapon):
			takeDamage(weapon.damage)

func takeDamage(amount: int) -> void:
	health -= amount
	if health <= 0:
		boss_dead.emit()
		queue_free()
	elif health <= 200:
		current_state = BossState.FASE2
		AIController.process_mode = PROCESS_MODE_INHERIT
		colliderF1.disabled = true
	
func fase1(delta: float) -> void:
	velocity.y = sin(Time.get_ticks_msec() * 0.004) * speed
	velocity.x = cos(Time.get_ticks_msec() * 0.004) * speed
	dashTimer -= delta
	if dashTimer <= 0:
		dashTimer = dashCooldown
		dashDirection = (player.global_position - global_position).normalized()
		current_state = BossState.FASE1_DASH
	
func dash(delta: float) -> void:
	velocity = dashDirection * dashSpeed
	dashDurationTimer -= delta
	if dashDurationTimer < 0:
		dashDurationTimer = randi_range(dashDuration.x, dashDuration.y)
		current_state = BossState.FASE1
	
func fase2(delta: float) -> void:
	jumpAction(delta)
	sprite.texture = load("res://resources/characters/boss/ArchmageF2.png")
	if not is_on_floor():
		velocity += get_gravity() * delta
	moveAction()
	shootTimer -= delta
	if(shootTimer < 0):
		shootTimer = shootCooldown
		throwMagic()
func moveAction():
	if input_vector.x > 0:
		velocity.x = speed * input_vector.x
		$Sprite2D.flip_h = true
	elif input_vector.x < 0:
		velocity.x = speed * input_vector.x
		$Sprite2D.flip_h = false
	else:
		velocity.x = 0

func throwMagic():
	var newBullet = bullet.instantiate()
	newBullet.dir = input_vector
	newBullet.shooter = self
	newBullet.init_position = global_position + Vector2(1,1)
	add_child(newBullet)
	await get_tree().create_timer(0.7).timeout

func jumpAction(delta: float):
	if not is_on_floor():
		velocity += get_gravity() * delta
	elif (is_on_floor() and jumpTimer < 0)	:
		velocity.y = -JUMP_VELOCITY
		jumpTimer = jumpCD
	jumpTimer -= delta
