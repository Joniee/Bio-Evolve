extends CharacterBody2D

const SPEED = 250.0
const JUMP_VELOCITY = -450.0

const ATTACK_COOLDOWN = 0.5
var attack_timer := 0.0


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
	

	
	
	move_and_slide()

	
