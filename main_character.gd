extends CharacterBody2D

const SPEED = 250.0
const JUMP_VELOCITY = -450.0
const SPAWN_POINT = Vector2i(0, -200)

const ATTACK_COOLDOWN = 0.5
const TAKEDAMAGE_COOLDOWN = 0.2
var attack_timer := 0.0
var invulnerability_timer := 0.0
var health := 100
var max_life_points := 500
var status := "Alive"
var debuff := Dictionary()

func _physics_process(delta: float) -> void:
	
	$MainCharacter.color = Color.AQUA

	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY


	var direction := Input.get_axis("move_left", "move_right")
	
	if direction:
		velocity.x = direction * SPEED
		
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if(invulnerability_timer > 0):
		invulnerability_timer -= 0.1 * delta
	$DamageTaken.text = "LP: " + str(health)
	stats()
	set_meta("Pos", Vector2(position.x, position.y))
	move_and_slide()

func takeDamage(damage: float) -> void:
	if(invulnerability_timer <= 0.0):
		health -= damage
		position.x -= 10
		$StatUpdated.show_information(str(damage))
		invulnerability_timer = TAKEDAMAGE_COOLDOWN
	
func stats() -> void:
	if(health > 500):
		health = max_life_points
	if(health <= 0):
		position = SPAWN_POINT
		owner.deads += 1
		health = 100
		
