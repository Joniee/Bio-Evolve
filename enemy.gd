extends CharacterBody2D

@export var player: CharacterBody2D
@export var weapon: Area2D
const SPEED = 100.0
const JUMP_VELOCITY = -400.0
const DAMAGE = 10

var decision_timer := 0.0
var erratic_direction := 0

func _physics_process(delta: float) -> void:
	randomize()
	decision_timer -= delta
	if not is_on_floor():
		velocity += get_gravity() * delta

	var random_jump = randi_range(1, 100)
	# Handle jump.
	if (random_jump > 99) and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := player.global_position.x - global_position.x
	if direction > 5 and direction < 800:
		velocity.x = SPEED
	elif direction < 5 and direction > -800:
		velocity.x = -SPEED
	else:
		if(decision_timer <= 0):
			erratic_direction = randi_range(-1, 1)
			decision_timer = randi_range(0.5, 3.0)
		if (erratic_direction < 0):
			velocity.x = SPEED * 0.5
		elif (erratic_direction > 0):
			velocity.x = -SPEED * 0.5
		else:
			velocity.x = 0
			
	for i in get_slide_collision_count():
		if(get_slide_collision(i).get_collider() == player):
			player.set_meta("Life", player.get_meta("Life")-DAMAGE)
			player.position.x -= 30
	
	
	$DamageTaken.text = str(get_meta("Life"))
	
	if(get_meta("Life") < 0):
		position.x = 0
		set_meta("Life", 50)
		
	move_and_slide()
