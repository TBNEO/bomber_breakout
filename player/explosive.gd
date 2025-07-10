extends Node2D

func boom() -> void:
	var grid: DisplayGrid = get_tree().get_first_node_in_group("Grid")
	position = grid.map_to_local(grid.local_to_map(position))
	var cell = grid.local_to_map(global_position)
	grid.physgrid.detonate(cell)
	hide()
