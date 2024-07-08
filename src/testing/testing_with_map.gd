extends Node2D

var floorTiles := [ Vector2i(0,0), Vector2i(1,0),Vector2i(2,0),Vector2i(3,0),Vector2i(4,0), Vector2i(5,0), Vector2i(6,0), Vector2i(7,0) ]
var wallTiles := [Vector2i(10,17)]
var mapToUse := []
var poi := []
var sot := []
var rpoints := []
const HEIGHT := 100
const WIDTH := 100
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
	
	#sot = mgh.generateBlankMap(HEIGHT,WIDTH, mgh.wallTile)
	#for i in 16:
		#sot = mgh.drawCircle( mgh.getARandomPointInMap(sot), randi_range(5,10), mgh.floorTile, sot )
	#sot = mgh.applyLinearConnectionToSections(1,mgh.floorTile,sot)
	print("\n NEW MAP")
	mapToUse = mgh.generateBlankMap(HEIGHT, WIDTH, mgh.wallTile )
	print("made blank map")
	mapToUse = mgh.applyFastPerlinNoise( 0.01, 0.5, mgh.floorTile, mapToUse )
	print("applied noise")
	mapToUse = mgh.drawBorder( 2, mgh.wallTile, mapToUse )
	print("drew border, done map")
	mapToUse = mgh.applyLinearConnectionToSections(2, mgh.floorTile, mapToUse)
	print("applied connections ")
	poi = mgh.findMostDistantPoints( mgh.getLargestSectionOfTileType(mgh.floorTile, mapToUse), 32 )
	print("found points of interest")
	for i in range(0,33):
		rpoints.append( mgh.getARandomTileByTileType( mgh.floorTile, mapToUse  ) )
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
				$TileMap.set_cell( 0, Vector2i(x,y), 0, floorTiles[ floor( min( randf()*floorTiles.size() - 0.5, 0 ) ) ]  )
				
			x+= 1
		y += 1
	for point in poi:
		$TileMap.set_cell( 0, Vector2i(point.x,point.y), 0,Vector2i(4,2)  )
	for point in rpoints:
		$TileMap.set_cell( 0, Vector2i(point.x,point.y), 0,Vector2i(0,9)  )

