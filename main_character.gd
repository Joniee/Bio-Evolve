extends CharacterBody2D

const SPEED = 250.0
const JUMP_VELOCITY = -450.0

const ATTACK_COOLDOWN = 0.5
const TAKEDAMAGE_COOLDOWN = 0.2
var attack_timer := 0.0
var invulnerability_timer := 0.0
var life_points := 100
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
	$DamageTaken.text = "LP: " + str(life_points)
	stats()
	move_and_slide()

func takeDamage(damage: float) -> void:
	if(invulnerability_timer <= 0.0):
		life_points -= damage
		position.x -= 10
		$StatUpdated.show_information(str(damage))
		invulnerability_timer = TAKEDAMAGE_COOLDOWN
	
func stats() -> void:
	if(life_points > 500):
		life_points = max_life_points
	if(life_points <= 0):
		position.x = 0
		life_points = 100
		
