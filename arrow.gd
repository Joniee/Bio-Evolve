extends CharacterBody2D

var damage = 10
var speed = 600
var dir := Vector2()
var init_position = Vector2()
var gravity_velocity := Vector2(0,0)
var speed_rotation = 0.0

var shooter: CharacterBody2D = null

func _ready() -> void:
	if shooter != null:
		add_collision_exception_with(shooter)
	global_position = init_position
	if get_tree().current_scene:
		call_deferred("reparent", get_tree().current_scene)
	global_rotation = dir.normalized().angle() + deg_to_rad(20)
	

func _process(delta: float) -> void:
	if dir.x > 0.0:
			rotation += deg_to_rad(speed_rotation)
	elif dir.x <= 0.0:
			rotation -= deg_to_rad(speed_rotation)
	if(rotation > deg_to_rad(90) and rotation < deg_to_rad(120)):
		speed_rotation = 0
	gravity_velocity += get_gravity() * delta / 2
	var move = dir.normalized() * speed * delta + gravity_velocity * delta
	var collision = move_and_collide(move, false, 0.08, false)
	if collision:
		if(collision.get_collider().get_class() == "CharacterBody2D" and not collision.get_collider() == shooter):
			if "health" in collision.get_collider():
				collision.get_collider().takeDamage(damage)
		queue_free()
	speed_rotation += 0.005
