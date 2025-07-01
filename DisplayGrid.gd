extends TileMapLayer
class_name DisplayGrid

@onready var physgrid: PhysGrid = $Physgrid

func _ready() -> void:
	physgrid.updated.connect(update_display)

func update_display() -> void:
	pass
