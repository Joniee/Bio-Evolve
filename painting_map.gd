extends TileMapLayer

const MAX_SIZE = Vector2i(512, 64)
const TILE = 16
const RANGE = Vector2i(100, 64)

var lastTilePlayer = Vector2i(0,0)

@export var player: CharacterBody2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var playerPos = Vector2i(player.get_meta("Pos").x / TILE, player.get_meta("Pos").y / TILE)
	if(!(playerPos.x == lastTilePlayer.x and playerPos.y == lastTilePlayer.y)):
		lastTilePlayer = playerPos
		var map = $"..".getMap()
		
		clear()
		
		
		for i in range(playerPos.x-RANGE.x, playerPos.x+RANGE.x):
			for j in range(playerPos.y-RANGE.y, playerPos.y+RANGE.y):
				var paint = Vector2i(MAX_SIZE.x/2 + i, MAX_SIZE.y/2 + j)
				if paint.x < 0 or paint.x >= MAX_SIZE.x-1 or paint.y < 0 or paint.y >= MAX_SIZE.y-1:
					continue
				if((map[(paint.y * (MAX_SIZE.x-1)) + paint.x]) == 1):
					if((map[((paint.y * (MAX_SIZE.x-1)) + paint.x) - (MAX_SIZE.x - 1)]) == 0):
						set_cell(Vector2i(i, j), 1, Vector2i(0,0))
					else:
						set_cell(Vector2i(i, j), 3, Vector2i(0,0))
					
		
