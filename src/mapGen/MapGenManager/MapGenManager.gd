extends Node
class_name MapGenManager

enum TILES { WALL, FLOOR }
var mgh: MapGenHandler = MapGenHandler.new()

# Function to generate an interesting map
func generateBlobbyMap(width: int, height: int) -> Array:
	randomize()
	var map = []

	# Apply various functions sequentially to generate the map
	map = mgh.generateCheckerboardMap(width, height, TILES.WALL, TILES.FLOOR, 10)
	map = mgh.applyStochasticCellularAutomota(map, TILES.FLOOR, 0.2)
	map = mgh.applyCellularAutomata(3, TILES.FLOOR, TILES.WALL, map)
	map = mgh.applyErosion(2, TILES.FLOOR, TILES.WALL, map)
	map = mgh.applyConnectionsToAllSections(1, TILES.FLOOR, map)
	map = mgh.drawBorder(TILES.WALL, map)
	return map

func boxyMap(width:int, height:int) -> Array:
	var map = mgh.generateBlankMap(height, width, TILES.WALL)
	for i in randi_range(4,10):
		var start_pos = mgh.getARandomPointInMap(map)
		var sizeOfBox := randi_range(5,10)
		map = mgh.drawBox( start_pos, sizeOfBox, TILES.FLOOR, map )
	map = mgh.applyConnectionsToAllSections(2, TILES.FLOOR, map)
	map = mgh.drawBorder(TILES.WALL, map)
	return map


func circlyMap(width:int, height:int) -> Array:
	var map = mgh.generateBlankMap(height, width, TILES.WALL)
	for i in randi_range(4,10):
		var start_pos = mgh.getARandomPointInMap(map)
		var radius := randi_range(5,10)
		map = mgh.drawCircle( start_pos, radius, TILES.FLOOR, map )
	map = mgh.applyStochasticCellularAutomota(map, TILES.FLOOR, randf() )
	map = mgh.applyConnectionsToAllSections(2, TILES.FLOOR, map)
	map = mgh.drawBorder(TILES.WALL, map)
	return map

func circleArena(width:int, height:int) -> Array:
	var map: = mgh.generateBlankMap(height,width, TILES.WALL)
	var halfWidth :int= floor(width/2) 
	var halfHeight :int= floor(height/2)
	var centerPos := Vector2i( halfWidth, halfHeight )
	var minRaidus :int= min(  halfHeight, halfWidth   )
	map = mgh.drawCircle( centerPos,  minRaidus, TILES.FLOOR,map  )
	
	
	return map


func lotsOfWalks( width:int, height:int ) -> Array:
	var randBorderWidth:= randi_range(2,6)
	var map = mgh.generateBorderedMap(width,height, TILES.WALL, TILES.FLOOR, randBorderWidth)
	var randPos= mgh.getARandomPointInMap(map)
	var stepAmt := randi_range(100,300)
	for i in randi_range(4,10):
		map = mgh.drawRandomWalk(randPos,stepAmt, TILES.WALL, randBorderWidth-1, map)
		
	map = mgh.applyConnectionsToAllSections(2, TILES.FLOOR, map)
		
	return map

func createComplexMap(width: int, height: int) -> Array:
	var map = mgh.generateBlankMap(height, width, TILES.WALL)
	var freqVal := randf_range(0.001, 0.01)
	var thresholdVal:= randf_range(0.01,0.05)
	map = mgh.applyFastPerlinNoise(  freqVal, thresholdVal, TILES.FLOOR, map)
	#map = mgh.applyRadialSymmetry(map)
	var start_pos = mgh.getARandomPointInMap(map)
	var end_pos = mgh.getARandomPointInMap(map)
	#map = mgh.drawRandomWalk(start_pos, 100, TILES.FLOOR, map)
	map = mgh.drawBorder(TILES.WALL, map)
	map = mgh.applyConnectionsToAllSections(1, TILES.FLOOR, map)
	map = mgh.drawBorder(TILES.WALL, map)
	
	prints("FreqVal: ", freqVal)
	prints("ThresholdVal: ", thresholdVal)
	return map


func createTunnelFilledMap(width: int, height: int) -> Array:
	var map = mgh.generateBlankMap(height, width, TILES.WALL)
	var freqVal := randf_range(0.004, 0.005)
	var thresholdVal:= randf_range(0.01,0.03)
	map = mgh.applyFastPerlinNoise(  freqVal, thresholdVal, TILES.FLOOR, map)
	#map = mgh.applyRadialSymmetry(map)
	for i in 4:
		var start_pos = mgh.getARandomPointInMap(map)
		var end_pos = mgh.getARandomPointInMap(map)
		map = mgh.drawRandomWalk(start_pos, 100, TILES.FLOOR, 2, map)
	
	map = mgh.drawBorder(TILES.WALL, map)
	map = mgh.applyConnectionsToAllSections(1, TILES.FLOOR, map)
	map = mgh.drawBorder(TILES.WALL, map)
	
	prints("FreqVal: ", freqVal)
	prints("ThresholdVal: ", thresholdVal)
	return map



func printMap(map) -> void:
	print("\n")
	var aToPrint := []
	for row in map:
		#print(row)
		aToPrint.append([])
		var sToPrint := ''
		for tile in row:
			if tile== TILES.WALL:
				sToPrint += "X"
			else:
				sToPrint += "_"
		print(sToPrint)
