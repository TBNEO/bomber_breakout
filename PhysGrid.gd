extends Node
class_name PhysGrid

enum BLOCKTYPE {
	Empty,
	Wood, 
	Bomb, 
	Steel, 
	Water, 
	Oil, 
	Acid
}

class PhysBlock:
	var blockHP: int
	var burning: bool = false
	var fluid: bool
	
	var type: BLOCKTYPE
	var pos: Vector2i
	var neighbors: Dictionary[Vector2i, PhysBlock] = {}
	
	signal destroyed(coord: Vector2i, type: BLOCKTYPE)
	
	func _init(new_type: BLOCKTYPE, coord: Vector2i) -> void:
		pos = coord
		type = new_type
		blockHP = 1
		fluid = false
		if new_type == BLOCKTYPE.Steel:
			blockHP = 3
		elif (
			new_type == BLOCKTYPE.Water or 
			new_type == BLOCKTYPE.Oil or 
			new_type == BLOCKTYPE.Acid
		):
			fluid = true
	
	func update(damage: int, targetcoord: Vector2i) -> void:
		if !fluid:
			pass
		else:
			if damage > 0:
				blockHP -= damage
				if blockHP <= 0:
					if type == BLOCKTYPE.Bomb:
						for n in neighbors.values():
							if n:
								n.update(1, n.pos)
					destroyed.emit()
					type = BLOCKTYPE.Empty

var GRIDDATA: Dictionary[Vector2i, PhysBlock] = {}
var DisplayData: Dictionary[Vector2i, BLOCKTYPE] = {}

signal updated

func _ready() -> void:
	for x in range(16):
		for y in range(16):
			var newblock = PhysBlock.new(BLOCKTYPE.Empty, Vector2i(x,y))
			GRIDDATA[Vector2i(x,y)] = newblock
	for b in GRIDDATA.values():
		var adjacent = {
			b.pos + Vector2i(1,0) : GRIDDATA[b.pos + Vector2i(1,0)],
			b.pos + Vector2i(-1,0) : GRIDDATA[b.pos + Vector2i(-1,0)],
			b.pos + Vector2i(0,1) : GRIDDATA[b.pos + Vector2i(0,1)],
			b.pos + Vector2i(0,-1) : GRIDDATA[b.pos + Vector2i(0,-1)],
		}
		b.neighbors = adjacent

func _process(delta: float) -> void:
	var updategrid = GRIDDATA.duplicate()
	for coord in updategrid.keys():
		var block = updategrid[coord]
		
