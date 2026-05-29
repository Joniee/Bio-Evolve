extends Label

func _process(delta: float) -> void:
	text = "FPS: " + str(Engine.get_frames_per_second()) + "\nWorld level: " + str(owner.world_level) + "\nDeads: "  + str(owner.deads)
