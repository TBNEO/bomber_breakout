extends CharacterBody2D

const SPEED: float = 400.0
var direction: Vector2 = Vector2.UP
var bounces: int = 0
var start_position: Vector2 = Vector2.ZERO
var complete: bool = false

signal detonate

const EXPLOSIVE = preload("res://player/explosive.tscn")

func _physics_process(delta: float) -> void:
	if !complete:
		velocity = direction * SPEED
		
		if is_on_wall():
			velocity = velocity.bounce(get_wall_normal())
			var ex = EXPLOSIVE.instantiate()
			get_tree().root.add_child(ex)
			ex.position = position
			ex.rotation = get_wall_normal().angle()
			detonate.connect(ex.boom)
			bounces += 1
		
		move_and_slide()
		
		if bounces >= 3:
			velocity = Vector2.ZERO
			global_position = start_position
			complete = true
			
			await get_tree().create_timer(1.0).timeout
			detonate.emit()
	
	
