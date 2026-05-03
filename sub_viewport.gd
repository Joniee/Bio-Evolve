extends SubViewport


func _ready():
	# Esperamos un frame para asegurar que el mundo esté cargado
	await get_tree().process_frame
	# Conectamos el mundo del minimapa con el mundo del juego principal
	world_2d = get_parent().get_viewport().world_2d


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
