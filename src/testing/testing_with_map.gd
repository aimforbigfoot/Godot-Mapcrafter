extends Node2D

var floorTiles := [ Vector2i(0,0), Vector2i(1,0),Vector2i(2,0),Vector2i(3,0),Vector2i(4,0), Vector2i(5,0), Vector2i(6,0), Vector2i(7,0) ]
var wallTiles := [Vector2i(10,17)]
var mapToUse := []
var poi := []
var rpoints := []
const HEIGHT := 200
const WIDTH := 200
var mgh := MapGenHandler.new()
signal mapDone
var t := Thread.new()

func _ready() -> void:
	mapDone.connect(setMapToTileset)
	$TileMap.set_cell( 0, Vector2i(0,0), 0, wallTiles[0]  )
	randomize()
	mgh.setFastNoiseLiteSeed( randi() )
	t.start(genMap,Thread.PRIORITY_HIGH)

func genMap() -> void:
	mapToUse = mgh.generateBlankMap(HEIGHT, WIDTH, mgh.wallTile )
	print("made blank map")
	mapToUse = mgh.applyFastPerlinNoise( 0.07, 0.5, mgh.floorTile, mapToUse )
	print("applied noise")
	mapToUse = mgh.applyRadialSymmetry( mapToUse )
	print("applied radial symmetry")
	mapToUse = mgh.applyStochasticCellularAutomota( mapToUse, mgh.floorTile, 0.2 )
	print("apply random Noise")
	mapToUse = mgh.applyConnectionToClosestSections(2, 2, mgh.floorTile, mapToUse)
	print("applied connections ")
	mapToUse = mgh.drawBorder( 2, mgh.wallTile, mapToUse )
	print("drew border, done map")
	poi = mgh.findMostDistantPoints( mgh.getLargestSectionOfTileType(mgh.floorTile, mapToUse), 32 )
	print("found points of interest")
	for i in range(0,33):
		rpoints.append( mgh.getARandomPointInMap() )
	call_deferred_thread_group( "emit_signal", "mapDone" )

func setMapToTileset() -> void:
	t.wait_to_finish()
	var y := 0
	for row in mapToUse:
		var x := 0
		for cell in row:
			if cell == mgh.wallTile:
				$TileMap.set_cell( 0, Vector2i(x,y), 0, wallTiles[0]  )
			elif cell == mgh.floorTile:
				$TileMap.set_cell( 0, Vector2i(x,y), 0, floorTiles[0]  )
				
			x+= 1
		y += 1
	for point in poi:
		$TileMap.set_cell( 0, Vector2i(point.x,point.y), 0,Vector2i(4,2)  )
		

