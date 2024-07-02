extends Node2D
var count := 0
const WIDTH := 100
const HEIGHT := 70
var mgh := MapGenHandler.new()
var mgm := MapGenManager.new()
var sot := []


func _ready() -> void:
	randomize()
	#sot = mgh.generateBlankMap(HEIGHT, WIDTH, mgh.wallTile)
	sot = mgm.generateBlobbyMap(WIDTH,HEIGHT)
	mgh.printMap(sot)
	sot = mgh.checkAndConnectIfAllSectionsOfACertainTileAreConnected(mgh.floorTile, sot)
	mgh.printMap(sot)
	


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("r"):
		get_tree().reload_current_scene()
	if Input.is_action_just_pressed("step"):
		mgh.setFastNoiseLiteSeed( randi() )
		sot = mgh.applyFastValueNoise(0.30, 0.5, mgh.floorTile, sot)
		
		#else:
			#sot = mgh.applyConnectionsToAllSections(2, mgh.floorTile, sot)
		count += 1 
		sot = mgh.drawBorder(mgh.wallTile, sot)
		mgh.printMap(sot)
		
	if Input.is_action_just_pressed("w"):
		sot = mgh.drawToFillInPatchesOfASizeByTileType( 50, mgh.floorTile,mgh.wallTile, sot )
		sot = mgh.applyConnectionToClosestSections( 2, 2, mgh.floorTile, sot )
		#sot = mgh.applyConnectionsToAllSections(2, mgh.floorTile, sot)
		mgh.printMap(sot)
