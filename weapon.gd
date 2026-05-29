extends CharacterBody2D

const SPEED = deg_to_rad(5)

const attack_cooldown = 0.5
var attack_timer := 0.5

const change_weapon_cooldown = 0.2
var change_weapon_timer = 0.2

var current_weapon := "sword_of_thieves"
var weapons := Dictionary()

var look_direction := Vector2()
var bullet := preload("res://Projectiles.tscn")
var arrow := preload("res://Arrow.tscn")

var damage = 15

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var json_data = get_meta("WeaponsR") as JSON
	var data = json_data.data
	weapons.clear()
	visible = false
	$CollisionWeapon.disabled = true
	
	for weapon in data.get("weapons", []):
		weapons[weapon["id"]] = weapon


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	attack_timer -= delta
	change_weapon_timer -= delta
	
	
	var weapon_position = weapons.keys().find(current_weapon)
	if(Input.is_action_just_pressed("change_weapon_right") and change_weapon_timer < 0):
		weapon_position += 1
		if weapon_position > 2:
			weapon_position = 0
		attack_timer = attack_cooldown
		current_weapon = weapons.keys()[weapon_position]
		get_child(1).texture = load(weapons[current_weapon]["path"])
		setMarc()
		change_weapon_timer = change_weapon_cooldown
	if(Input.is_action_just_pressed("change_weapon_left") and change_weapon_timer < 0):
		weapon_position -= 1
		if weapon_position < 0:
			weapon_position = weapons.keys().size()-1
		attack_timer = attack_cooldown
		current_weapon = weapons.keys()[weapon_position]
		get_child(1).texture = load(weapons[current_weapon]["path"])
		setMarc()
		change_weapon_timer = change_weapon_cooldown
	match current_weapon:
		"sword_of_thieves":
			if (rotation > 0 and rotation < deg_to_rad(130)):
				rotation += SPEED
			if (rotation < 0 and rotation > deg_to_rad(-130)):
				rotation -= SPEED
			if (rotation > deg_to_rad(130) or rotation < deg_to_rad(-130)):
				rotation = 0
				visible = false
				$CollisionWeapon.disabled = true
		"bow_of_the_nether":
			pass
		"wand_of_the_moon":
			pass
	
	
	if ((Input.is_action_pressed("action") or Input.is_action_pressed("joystick_action")) and attack_timer <= 0):
		aim_direction()
		match current_weapon:
			"sword_of_thieves":
				swingAttack()
				attack_timer = attack_cooldown
			"bow_of_the_nether":
				throwArrow()
				attack_timer = attack_cooldown * 2
			"wand_of_the_moon":
				throwMagic()
				attack_timer = attack_cooldown / 2
		
	

func aim_direction():
	if((Input.is_action_pressed("action"))):
		look_direction = (get_global_mouse_position() - global_position).normalized()
	elif(Input.is_action_pressed("joystick_action")):
		var raw_x = Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)
		var raw_y = Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
		var raw_vector = Vector2(raw_x, raw_y)
		if raw_vector.length() > 0.12:
			look_direction = raw_vector.normalized()
	

func swingAttack():
	if (Input.is_action_pressed("action") and attack_timer <= 0 and rotation == 0):
		visible = true
		$CollisionWeapon.disabled = false
		if(look_direction.x > 0):
			rotation = SPEED
		else:
			rotation = -SPEED
		attack_timer = attack_cooldown
	
#It throws a projectile affected by gravity.
func throwArrow():
	visible = true
	rotation = look_direction.normalized().angle() + deg_to_rad(90)
	var newBullet = arrow.instantiate()
	newBullet.dir = look_direction
	newBullet.shooter = get_parent()
	newBullet.init_position = global_position
	add_child(newBullet)
	await get_tree().create_timer(0.5).timeout
	visible = false

func throwMagic():
	visible = true
	rotation = look_direction.normalized().angle() + deg_to_rad(90)
	var newBullet = bullet.instantiate()
	newBullet.dir = look_direction
	newBullet.shooter = get_parent()
	newBullet.init_position = global_position + Vector2(1,1)
	add_child(newBullet)
	await get_tree().create_timer(0.7).timeout
	visible = false

	
func setMarc():
	match current_weapon:
		"sword_of_thieves":
			$"../CanvasLayer/Marc".position = Vector2(35, 47)
			$"../CanvasLayer/VBoxContainer/Label".text = weapons[current_weapon]["name"]
			print("cambio a espada")
		"bow_of_the_nether":
			$"../CanvasLayer/Marc".position = Vector2(71, 47)
			$"../CanvasLayer/VBoxContainer/Label".text = weapons[current_weapon]["name"]
			print("cambio a arco")
		"wand_of_the_moon":
			$"../CanvasLayer/Marc".position = Vector2(107, 47)
			$"../CanvasLayer/VBoxContainer/Label".text = weapons[current_weapon]["name"]
			print("cambio a mago")
