extends Node2D


var mapPath := "res://resources/maps/Map.data"
var map : PackedByteArray = PackedByteArray()

func _ready() -> void:
	if not FileAccess.file_exists(mapPath):
		print("Map does not exists: " + mapPath)
		return

	var file = FileAccess.open(mapPath, FileAccess.READ)
	var row = Array()
	var data

	while file.get_position() < file.get_length():
		data = file.get_8()
		if(data != 10):
			map.append(data-48)
	file.close()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func getMap() -> PackedByteArray:
	return map
