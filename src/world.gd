extends Node2D
const WIDTH := 21
const HEIGHT := 21
var sot := []
var mgh : MapGenHelper = MapGenHelper.new()


func _ready() -> void:
	sot = mgh.generateMap(HEIGHT, WIDTH)
	sot = mgh.setCell( 4,4, mgh.TILES.FLOOR , sot )
	mgh.printMap(sot)



func _input(event: InputEvent) -> void:
	if event.is_action_pressed("r"):
		get_tree().reload_current_scene()
	if Input.is_action_just_pressed("step"):
		sot = mgh.stepMap(sot)
		mgh.printMap(sot)


# test 
