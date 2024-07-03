extends Node
class_name MapGenManager

var height : int
var width : int
enum TILES { WALL, FLOOR }
#
var mgh: MapGenHandler = MapGenHandler.new()
var map := []

var thread := Thread.new()
var is_running := false
signal mapGenDone 

# Function to start the calculation thread
func startThread() -> void:
	if is_running:
		return []
	is_running = true
	#thread.start(threadedMapGen)
	thread.start( threadedMapGen.bind( " hello", " world" )   )

# Function to stop the thread
func stopThread() -> void:
	if is_running:
		thread.wait_to_finish()
		is_running = false

# The function that runs in the thread
func threadedMapGen(param1, param2) -> Array:
	print(param1, param2)
	print("Starting Generator")
	map = mgh.generateBlankMap(height,  width, mgh.wallTile)
	print("Made Blank Map")
	map = mgh.applyFastValueNoise( 0.19, 0.55, mgh.floorTile, map )
	print("Placed Fast Noise With Least Common Tile")
	var circlePoints = mgh.findMostDistantPoints( mgh.getLargestSectionOfTileType(mgh.floorTile, map), 32)
	print("Found Points For Circles")
	for point in circlePoints:
		map = mgh.drawCircle( Vector2( point.x, point.y ), 5, mgh.getLeastCommonTile( map ) , map )
	print("Placed Circles Everwhere")
	map = mgh.applyMirrorVertical(map, true)
	print("applied radial symmetry")
	map = mgh.drawBorder(1, mgh.wallTile, map)
	print("placing final border")
	map = mgh.applyConnectionToClosestSections( 1, 2, mgh.floorTile, map )
	print("connecting all sections of floor again")
	var points = mgh.findMostDistantPointsWithPaddingFromWall( mgh.getLargestSectionOfTileType(mgh.floorTile, map),  mgh.getLargestSectionOfTileType(mgh.wallTile, map), 16, 2  )
	print("Found Points Of Interest Away From Walls")
	for point in points:
		map = mgh.setCell( point.x, point.y, mgh.TILES.EXTRA, map)
	print("Placed RED CELL for interest points")
	call_deferred( "emit_signal","mapGenDone", map  )
	is_running = false
	return map

func setWidthAndHeight( _w, _h ) -> void:
	width = _w
	height = _h

