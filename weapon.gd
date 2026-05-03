extends StaticBody2D

const SPEED = deg_to_rad(5)

const attack_cooldown = 0.5
var attack_timer := 0.0

var look_direction := Vector2.RIGHT

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (attack_timer > 0):
		attack_timer -= delta
		
	aim_direction()
	
	if (rotation > 0 and rotation < deg_to_rad(130)):
		rotation += SPEED
	if (Input.is_action_pressed("action") and attack_timer <= 0 and rotation == 0):
		visible = true
		$CollisionWeapon.disabled = false
		rotation = SPEED
		attack_timer = attack_cooldown
	if (rotation > deg_to_rad(130)):
		rotation = 0
		visible = false
		$CollisionWeapon.disabled = true
	
	
		
	

func aim_direction():
	var joystick_dir = Vector2(
		Input.get_action_strength("aim_right") - Input.get_action_strength("aim_left"),
		Input.get_action_strength("aim_down") - Input.get_action_strength("aim_up")
	)
	if (joystick_dir.length() > 0.2): 
		# Si el stick se mueve más allá de una zona muerta, usamos el mando
		look_direction = joystick_dir.normalized()
	else:
		# Si no, usamos la posición del ratón relativa al personaje
		look_direction = (get_global_mouse_position() - global_position).normalized()
