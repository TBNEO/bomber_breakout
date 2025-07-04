extends TileMapLayer
class_name DisplayGrid

@onready var physgrid: PhysGrid = $Physgrid

func _ready() -> void:
	physgrid.updated_s.connect(update_display)

func update_display() -> void:
	for k in physgrid.DisplayData.keys():
		var v = physgrid.DisplayData.get(k)
		match v:
			physgrid.BLOCKTYPE.Wood:
				set_cell(k, 1, Vector2i(0,0))
			physgrid.BLOCKTYPE.Bomb:
				set_cell(k, 1, Vector2i(1,0))
			physgrid.BLOCKTYPE.Steel:
				set_cell(k, 1, Vector2i(2,0))
			physgrid.BLOCKTYPE.Water:
				set_cell(k, 1, Vector2i(3,0))
			physgrid.BLOCKTYPE.Oil:
				set_cell(k, 1, Vector2i(4,0))
			physgrid.BLOCKTYPE.Acid:
				set_cell(k, 1, Vector2i(5,0))
			_:
				erase_cell(k)
			

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("click"):
		physgrid.detonate(local_to_map(get_local_mouse_position()))
