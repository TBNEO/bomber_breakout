extends Node
class_name PhysGrid

enum BLOCKTYPE {
	Empty,
	Wood, 
	Bomb, 
	Steel, 
	Water, 
	Oil, 
	Acid,
	Keybox
}

class PhysBlock:
	var blockHP: int
	var burning: bool = false
	var fluid: bool
	
	var type: BLOCKTYPE:
		set(value):
			match value:
				BLOCKTYPE.Empty:
					blockHP = 1
					fluid = false
				BLOCKTYPE.Wood:
					blockHP = 1
					fluid = false
				BLOCKTYPE.Steel:
					blockHP = 3
					fluid = false
				BLOCKTYPE.Water:
					blockHP = 1
					fluid = true
				BLOCKTYPE.Oil:
					blockHP = 1
					fluid = true
				BLOCKTYPE.Acid:
					blockHP = 1
					fluid = true
				BLOCKTYPE.Keybox:
					blockHP = 1
					fluid = false
			type = value
	var neighbors: Dictionary[Vector2i, PhysBlock] = {}
	
	var updated: bool = false
	
	func _init(new_type: BLOCKTYPE) -> void:
		type = new_type
	
	func update(damage: int = 0) -> void:
		if fluid:
			var downblock = neighbors.get(Vector2i.DOWN)
			var switch = randi() % 2
			if switch == 0: switch = -1
			var sideblock = neighbors.get(Vector2i(switch, 0))
			if downblock:
				if downblock.type == BLOCKTYPE.Empty:
					downblock.type = type
					type = BLOCKTYPE.Empty
					downblock.updated = true
				elif downblock.type == BLOCKTYPE.Oil and type == BLOCKTYPE.Water:
					downblock.type = BLOCKTYPE.Water
					type = BLOCKTYPE.Oil
					downblock.updated = true
				else:
					if sideblock:
						if sideblock.type == BLOCKTYPE.Empty:
							sideblock.type = type
							type = BLOCKTYPE.Empty
							sideblock.updated = true
			else:
				type = BLOCKTYPE.Empty
		else:
			if damage > 0:
				blockHP -= damage
				if blockHP <= 0 and type != BLOCKTYPE.Empty:
					print("broken")
					if type == BLOCKTYPE.Bomb:
						for n in neighbors.values():
							if n:
								n.update(1)
					type = BLOCKTYPE.Empty
		updated = true

var GRIDDATA: Dictionary[Vector2i, PhysBlock] = {}
var KeyboxList: Array[Vector2i] = []
var DisplayData: Dictionary[Vector2i, BLOCKTYPE] = {}

signal updated_s

var update_tick: int = tickrate
const tickrate: int = 60
var running: bool = false

const GRIDSIZEX: int = 32
const GRIDSIZEY: int = 16

func _process(_delta: float) -> void:
	if !running: return
	if update_tick <= 0:
		update_tick = tickrate
	else:
		update_tick -= 1
		return
	
	var inverse_keys = GRIDDATA.keys().duplicate()
	inverse_keys.reverse()
	for coord in inverse_keys:
		var block = GRIDDATA[coord]
		if !block.updated:
			block.update()
	
	for b in GRIDDATA.values():
		b.updated = false
	
	for v in GRIDDATA.keys():
		DisplayData[v] = GRIDDATA.get(v).type
	updated_s.emit()
	

func detonate(coord: Vector2i) -> void:
	if GRIDDATA.has(coord):
		for c in GRIDDATA[coord].neighbors.values():
			if !c: continue
			c.update(1)
		GRIDDATA[coord].update(1)
	for v in GRIDDATA.keys():
		DisplayData[v] = GRIDDATA.get(v).type
	updated_s.emit()
	if !running: running = true

func generate(dict: Dictionary) -> void:
	for x in range(GRIDSIZEX):
		for y in range(GRIDSIZEY):
			var v = Vector2i(x,y)
			var b = -1
			if dict.has(v):
				b = dict[v]
			var datablock: PhysBlock
			match b:
				-1: 
					datablock = PhysBlock.new(BLOCKTYPE.Empty)
				0:
					datablock = PhysBlock.new(BLOCKTYPE.Wood)
				1: 
					datablock = PhysBlock.new(BLOCKTYPE.Bomb)
				2: 
					datablock = PhysBlock.new(BLOCKTYPE.Steel)
				3: 
					datablock = PhysBlock.new(BLOCKTYPE.Water)
				4: 
					datablock = PhysBlock.new(BLOCKTYPE.Oil)
				5: 
					datablock = PhysBlock.new(BLOCKTYPE.Acid)
				6: 
					datablock = PhysBlock.new(BLOCKTYPE.Keybox)
					KeyboxList.append(v)
			if datablock: 
				GRIDDATA[v] = datablock
	
	for g in GRIDDATA.keys():
		var b = GRIDDATA.get(g)
		var n: Dictionary[Vector2i, PhysBlock] = {
			Vector2i.UP: GRIDDATA.get(g + Vector2i.UP),
			Vector2i.DOWN: GRIDDATA.get(g + Vector2i.DOWN),
			Vector2i.LEFT: GRIDDATA.get(g + Vector2i.LEFT),
			Vector2i.RIGHT: GRIDDATA.get(g + Vector2i.RIGHT)
		}
		b.neighbors = n
	
