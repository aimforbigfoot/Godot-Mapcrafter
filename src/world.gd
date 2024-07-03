extends Node2D
var count := 0
const WIDTH := 100
const HEIGHT := 70
var mgh := MapGenHandler.new()
var mgm := MapGenManager.new()
var sot := []
var thread := Thread.new()
var is_running := false
signal mapGenDone 


func _ready() -> void:
	mapGenDone.connect(printMapGen)
	randomize()
	seed(randi())
	startThread()
	


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("r"):
		get_tree().reload_current_scene()
	if Input.is_action_just_pressed("step"):
		pass
	if Input.is_action_just_pressed("w"):
		pass


func printMapGen( res:Array ) -> void:
	stopThread()
	mgh.printMap(res)
	mgh.printMap(sot)
	

# Function to start the calculation thread
func startThread() -> void:
	if is_running:
		return
	is_running = true
	thread.start(_thread_function)

# Function to stop the thread
func stopThread() -> void:
	if is_running:
		thread.wait_to_finish()
		is_running = false

# The function that runs in the thread
func _thread_function():
	print("Starting Generator")
	sot = mgh.generateBlankMap(HEIGHT,  WIDTH, mgh.wallTile)
	print("Made Blank Map")
	sot = mgh.applyFastValueNoise( 0.19, 0.55, mgh.floorTile, sot )
	print("Placed Fast Noise With Least Common Tile")
	var circlePoints = mgh.findMostDistantPoints( mgh.getLargestSectionOfTileType(mgh.floorTile, sot), 32)
	print("Found Points For Circles")
	for point in circlePoints:
		sot = mgh.drawCircle( Vector2( point.x, point.y ), 5, mgh.getLeastCommonTile( sot ) , sot )
	print("Placed Circles Everwhere")
	sot = mgh.applyMirrorVertical(sot, true)
	print("applied radial symmetry")
	sot = mgh.drawBorder(1, mgh.wallTile, sot)
	print("placing final border")
	sot = mgh.applyConnectionToClosestSections( 1, 2, mgh.floorTile, sot )
	print("connecting all sections of floor again")
	var points = mgh.findMostDistantPointsWithPaddingFromWall( mgh.getLargestSectionOfTileType(mgh.floorTile, sot),  mgh.getLargestSectionOfTileType(mgh.wallTile, sot), 16, 2  )
	print("Found Points Of Interest Away From Walls")
	for point in points:
		sot = mgh.setCell( point.x, point.y, mgh.TILES.EXTRA, sot)
	print("Placed RED CELL for interest points")
	call_deferred( "emit_signal","mapGenDone", sot  )
	is_running = false
