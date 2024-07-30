extends Node2D
var count := 0
const WIDTH := 90
const HEIGHT := 40
var mgh := MapGenHandler.new()
var sot := []


func _ready() -> void:
	randomize()
	mgh.setFastNoiseLiteSeed(  randi()  )
	sot = mgh.generateBlankMap(HEIGHT,WIDTH, mgh.wallTile)
	sot = mgh.applyRandomCellsToCertainCellType(0.6, mgh.floorTile, sot)
	sot = mgh.applyConwaysGameOfLife(sot, 10, mgh.floorTile, mgh.wallTile)
	sot = mgh.applyExpandedTiles(1, mgh.floorTile, sot)
	sot = mgh.connectClosestSections( mgh.floorTile, mgh.floorTile, sot )
	sot = mgh.applyLinearConnectionToSections(1, mgh.floorTile, sot)
	mgh.printMap(sot )
	

func mapGenDone ( )-> void:
	print("map gen is done")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("r"):
		get_tree().reload_current_scene()
	if Input.is_action_just_pressed("step"):
		pass
	if Input.is_action_just_pressed("w"):
		pass


func printMapGen( res:Array ) -> void:
	mgh.printMap(res)
	mgh.printMap(sot)
	
