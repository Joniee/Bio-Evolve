extends Label

var cooldown = 1.0
var show_timer = 0.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	show_timer -= 0.7 * delta
	
	if(show_timer <= 0.0):
		visible = false
		

func show_information(data: String) ->void:
	text = data
	visible = true
	show_timer = cooldown
	print("show")
