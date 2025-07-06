extends Node2D

func boom() -> void:
	var grid: DisplayGrid = get_tree().get_first_node_in_group("Grid")
	var cell = grid.local_to_map(grid.to_local(global_position))
	grid.physgrid.detonate(cell)
	hide()
