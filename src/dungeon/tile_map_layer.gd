extends TileMapLayer

func _ready() -> void:
	BetterTerrain.set_cell(self, Vector2i(10, 10), 0)
