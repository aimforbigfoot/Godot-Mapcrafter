extends Node2D

@onready var mct := $multiColoredTerrains
var mapToUse := []
var poi := []
var rpoints := []
var WIDTH := 20
var HEIGHT := 20
var mgh := MapGenHandler.new()
signal mapDone
var t := Thread.new()


func _ready() -> void:

	WIDTH = randi_range(50, 100)
	HEIGHT = randi_range(20, 75)
	mapDone.connect(setMapToTileset)
	randomize()
	mgh.setFastNoiseLiteSeed( randi() )
	t.start(test,Thread.PRIORITY_HIGH)

func test() -> void:
	mapToUse = mgh.generateBlankMap(WIDTH,HEIGHT,mgh.floorTile)
	var randThreshold := randi_range(2,4)
	for i in randi_range(2, 8):
		mapToUse = mgh.drawSquare( mgh.getARandomPointInMap(mapToUse), 4, mgh.wallTile, mapToUse )
	call_deferred_thread_group( "emit_signal", "mapDone" )

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("step"):
		mapToUse = mgh.applyConnectionsLinearly( mgh.wallTile, mgh.wallTile,mapToUse )
		setMapToTileset()

func genReallyNaturalCaves() -> void:
	mapToUse = mgh.generateBlankMap(HEIGHT, WIDTH, mgh.floorTile)
	print("done map")
	mapToUse = mgh.drawNaturalBorder( 3, 8, mgh.wallTile, mapToUse )
	print("done border")
	mapToUse = mgh.applyFastWorleyNoise(mgh.wallTile, 0.08, 0.5, mapToUse)
	print("done noise")
	mapToUse = mgh.applySmoothing( mapToUse, mgh.wallTile, mgh.floorTile, 2 )
	print("done smoothing")
	mapToUse = mgh.drawBorder(1, mgh.wallTile, mapToUse)
	print("done second border")
	mapToUse = mgh.applyConnectionsWithRandomWalks( mgh.floorTile, mgh.floorTile, 100, mapToUse )
	print("done random connections")
	mapToUse = mgh.applyConnectionWithMST(mgh.floorTile, mapToUse)
	print("done proper connections")
	call_deferred_thread_group( "emit_signal", "mapDone" )

func genMapHollow() -> void:
	print("\n NEW MAP")
	mapToUse = mgh.generateCaveMap(WIDTH, HEIGHT, mgh.wallTile, mgh.floorTile )
	print("made blank map")
	mapToUse = mgh.applyFastPerlinNoise( 0.01, 0.5, mgh.floorTile, mapToUse )
	print("applied noise")
	#mapToUse = mgh.drawBorder( 2, mgh.wallTile, mapToUse )
	print("drew border, done map")
	mapToUse = mgh.applyConnectionsLinearly(mgh.floorTile, mgh.floorTile, mapToUse)
	print("applied connections ")
	#poi = mgh.findMostDistantPoints( mgh.getLargestSectionOfTileType(mgh.floorTile, mapToUse), 32 )
	#print("found points of interest")
	#for i in range(0,33):
		#rpoints.append( mgh.getARandomTileByTileType( mgh.floorTile, mapToUse  ) )
	#print("placed points of interests")
	mapToUse = mgh.drawBorder(3, mgh.wallTile, mapToUse)
	print("placed border")
	call_deferred_thread_group( "emit_signal", "mapDone" )

func genWebbyMap() -> void:
	print("\n new MAP")
	mapToUse = mgh.generateCheckerboardMap(WIDTH, HEIGHT, mgh.floorTile,mgh.wallTile, randi_range(3,8))
	mapToUse = mgh.applyRandomCellsToCertainCellType( 0.1, mgh.floorTile, mapToUse )
	mapToUse = mgh.applyCellularAutomata(4, mgh.wallTile, mgh.floorTile, mapToUse)
	mapToUse = mgh.applyExpandedTiles(1, mgh.wallTile, mapToUse)
	mapToUse = mgh.applyExpandedTiles(1, mgh.floorTile, mapToUse)
	mapToUse = mgh.drawBorder(3, mgh.wallTile, mapToUse)
	mapToUse = mgh.applyConnectionWithMST(mgh.floorTile, mapToUse)
	call_deferred_thread_group( "emit_signal", "mapDone" )

func genConnectedBlobbyRooms() -> void:
	mapToUse = mgh.generateBlankMap(HEIGHT, WIDTH, mgh.wallTile)
	mapToUse = mgh.drawRandomWalk( Vector2i ( int(WIDTH/8), int(HEIGHT/4)), 200, mgh.floorTile, 2, mapToUse   )
	if randf() < 0.5:
		mapToUse = mgh.drawRandomWalk( Vector2i ( int(WIDTH/4)   , int(HEIGHT/4) + 25  ), 200, mgh.floorTile, 2, mapToUse   )
	else:
		mapToUse = mgh.drawRandomWalk( Vector2i ( int(WIDTH/4)   , int(HEIGHT/4) - 10 ), 200, mgh.floorTile, 2, mapToUse   )
	mapToUse = mgh.applyRadialSymmetry(mapToUse)
	mapToUse = mgh.drawRandomWalk( Vector2i ( int(WIDTH/2), int(HEIGHT/2)), 200, mgh.floorTile, 2, mapToUse   )
	
	mapToUse = mgh.drawSquareEveryNthTiles( 3, 6, 6, mgh.wallTile, mapToUse)
	mapToUse = mgh.applyErosion(2, mgh.floorTile, mgh.wallTile, mapToUse)
	mapToUse = mgh.applyExpandedTiles(2, mgh.floorTile, mapToUse)
	mapToUse = mgh.applyConnectionWithMST(mgh.floorTile, mapToUse)
	call_deferred_thread_group( "emit_signal", "mapDone" )

func genCircularRooms() -> void:
	mapToUse = mgh.generateBlankMap(HEIGHT,WIDTH, mgh.wallTile)
	for i in 16:
		var p := mgh.getARandomPointInMap(mapToUse)
		mapToUse = mgh.drawCircle( p, randi_range(5,10), mgh.floorTile, mapToUse )
		
		mapToUse = mgh.drawCrazySporadicWalk( Vector2i(p.x,p.y), randi_range(10,100), mgh.floorTile, 2, mapToUse  )
	mapToUse = mgh.applyConnectionWithMST(mgh.floorTile,mapToUse)
	call_deferred_thread_group( "emit_signal", "mapDone" )

func genVienyMaps() -> void:
	mapToUse = mgh.generateBlankMap(HEIGHT,WIDTH, mgh.wallTile)
	mapToUse = mgh.applyFastPerlinNoise(0.05, 0.4, mgh.floorTile, mapToUse)
	mapToUse = mgh.applyExpandedTiles(1, mgh.floorTile, mapToUse)
	mapToUse = mgh.applyConnectionsWithRandomWalks(mgh.floorTile, mgh.floorTile, 60, mapToUse)
	
	mapToUse = mgh.applyConnectionWithMST(mgh.floorTile, mapToUse)
	call_deferred_thread_group( "emit_signal", "mapDone" )

func genOpenCaveLikeMaps() -> void:
	mapToUse = mgh.generateBlankMap(HEIGHT, WIDTH, mgh.wallTile)
	var countOfTries := 0
	var saver:= 0.01
	while mgh.getPercentOfTiles( mgh.floorTile, mapToUse ) < 0.5:
		
		print(mgh.getPercentOfTiles( mgh.floorTile, mapToUse ))
		var randAmt := randf_range(0.001,0.01)
		mapToUse = mgh.applyFastValueNoise( randAmt, 0.8, mgh.floorTile, mapToUse )
		
		countOfTries += 1
		if countOfTries >= 10:
			saver += randAmt
			mapToUse = mgh.applyFastValueNoise( saver, 0.8, mgh.floorTile, mapToUse )
	
	print("FINAL PERCENTAGE OF FLOOR:", mgh.getPercentOfTiles( mgh.floorTile, mapToUse ))
	mapToUse = mgh.applyExpandedTiles(1, mgh.floorTile, mapToUse)
	
	for i in 10:
		var p := mgh.getARandomPointInMap(mapToUse)
		var cellType := mgh.getCell(p.x, p.y, mapToUse)
		print(cellType)
		var stepCount := randi_range(10,200)
		var thickness := randi_range(1,5)
		if cellType == mgh.floorTile:
			mapToUse = mgh.drawCrazySporadicWalk(p , stepCount, mgh.wallTile, thickness, mapToUse)
		else:
			mapToUse = mgh.drawCrazySporadicWalk(p , stepCount, mgh.floorTile, thickness, mapToUse)
			
	mapToUse = mgh.smoothAndRemoveDebris( mapToUse, mgh.wallTile, mgh.floorTile, 3 )
	
	mapToUse = mgh.applyConnectionWithMST( mgh.floorTill, mapToUse)
	
	mapToUse = mgh.drawBorder(2, mgh.wallTile, mapToUse)
	
	call_deferred_thread_group( "emit_signal", "mapDone" )

func setMapToTileset() -> void:
	t.wait_to_finish()
	var y := 0
	for row in mapToUse:
		var x := 0
		for cell in row:
			if cell == mgh.wallTile:
				mct.placeWallTile(x,y)
				pass
			elif cell == mgh.floorTile:
				mct.placeFloorTile(x,y)
				pass
			elif cell == mgh.TILES.INTEREST:
				mct.setInterestTile(x,y)
			x+= 1
		y += 1
	for point in poi:
		#$TileMap.set_cell( 0, Vector2i(point.x,point.y), 0,Vector2i(4,2)  )
		pass
	for point in rpoints:
		#$TileMap.set_cell( 0, Vector2i(point.x,point.y), 0,Vector2i(0,9)  )
		pass
