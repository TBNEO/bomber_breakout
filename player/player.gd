extends CharacterBody2D

const SPEED: float = 400.0
var direction: Vector2 = Vector2.UP
var bounces: int = 0
var start_position: Vector2 = Vector2.ZERO
var started: bool = false
var complete: bool = false

signal detonate

const EXPLOSIVE = preload("res://player/explosive.tscn")

func _ready() -> void:
	start_position = global_position

func _unhandled_input(event: InputEvent) -> void:
	if started: return
	if Input.is_action_just_pressed("click"):
		var dir = get_local_mouse_position().normalized()
		direction = dir
	if Input.is_action_just_pressed("confirm"):
		started = true

func _physics_process(delta: float) -> void:
	if !started: return
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
		
		if bounces >= 3 or global_position.y >= start_position.y or !get_viewport_rect().has_point(global_position):
			velocity = Vector2.ZERO
			global_position = start_position
			complete = true
			
			await get_tree().create_timer(1.0).timeout
			detonate.emit()
	
	
