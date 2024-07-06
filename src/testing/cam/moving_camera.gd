extends Node2D

func _physics_process(delta: float) -> void:
	var dir := Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down")  - Input.get_action_strength("ui_up") 
	)
	global_position += dir * 50

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("mouseWheelDown"):
		$Camera2D.zoom -= Vector2(0.1,0.1)

	if event.is_action_pressed("mouseWheelUp"):
		$Camera2D.zoom += Vector2(0.1,0.1)
	if Input.is_action_just_pressed("r"):
		get_tree().reload_current_scene()
