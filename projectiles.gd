extends CharacterBody2D

var damage = 7
var speed = 500
var dir := Vector2()
var init_position = Vector2()

var shooter: CharacterBody2D = null

func _ready() -> void:
	if shooter != null:
		add_collision_exception_with(shooter)
	global_position = init_position
	if get_tree().current_scene:
		call_deferred("reparent", get_tree().current_scene)

func _process(delta: float) -> void:
	var move = dir.normalized() * speed * delta
	var collision = move_and_collide(move, false, 0.08, false)
	if collision:
		if(collision.get_collider().get_class() == "CharacterBody2D" and not collision.get_collider() == shooter):
			if "health" in collision.get_collider():
				collision.get_collider().takeDamage(damage)
		queue_free()
