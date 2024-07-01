extends Node2D
const WIDTH := 150
const HEIGHT := 30
var sot := []
var count := 0
var mgm := MapGenManager.new()
func _ready() -> void:
	randomize()
	sot = mgm.createComplexMap(WIDTH,HEIGHT)
	pass


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("r"):
		get_tree().reload_current_scene()
	if Input.is_action_just_pressed("step"):
		mgm.printMap(sot)
		seed( randi() )
		sot = mgm.circleArena(WIDTH,HEIGHT)
