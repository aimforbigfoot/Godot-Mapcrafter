 #Welcome to the MapGenHandler V1
# This library helps you generate a bunch of 2d array maps in a simple binary fashion with walls and floors
# It is highly customizable and flexible and can be used to generate a whole host of maps 
extends Node
class_name MapGenHandler

enum TILES { WALL, FLOOR }
var wallTile := TILES.WALL
var floorTile := TILES.FLOOR




# ######################################## #
#
#
#
#			MAP MODIFICATIONS 
#	modifications are algos that use other cells
#	or place cells in a defined manner based 
#	on math or some math function
#
#
# ######################################## #


func applyStochasticCellularAutomota(map:Array, cellToSet:int,  randomChance:float=0.5) -> Array:
	var mapCopy := map.duplicate(true)
	var y := 0
	for row in map:
		var x:= 0 
		for cell in row:
			if cell == cellToSet:
				if randf() < randomChance:
					for dx in range(-1,2):
						for dy in range(-1,2):
							if (dx != 0 and dy != 0) or ( dx == 0 or dy == 0 ) :
								var accX :int= x + dx 
								var accY :int= y + dy
								if getCell(accX, accY, map) != cellToSet:
									mapCopy = setCell(accX,accY, cellToSet, map)
			x+= 1
		y+= 1
	return mapCopy


func applyRadialSymmetry(map: Array) -> Array:
	var map_copy = map.duplicate(true)
	var height = map.size()
	var width = map[0].size()

	for y in range( 0, int(floor(height / 2)) ):
		for x in range( 0, int(floor( width/2 )) ):
			var value = map[y][x]
			map_copy[y][x] = value  # Top-left
			map_copy[y][width - 1 - x] = value  # Top-right
			map_copy[height - 1 - y][x] = value  # Bottom-left
			map_copy[height - 1 - y][width - 1 - x] = value  # Bottom-right
	return map_copy


func applyMirrorVertical(map: Array, flipFromLeftToRight:bool=true) -> Array:
	var map_copy = map.duplicate(true)
	var height = map.size()
	var width = map[0].size()

	if flipFromLeftToRight:
		for y in range(height):
			for x in range(0, getHalfWayOfLength(width) ):
				var value = map[y][x]
				map_copy[y][width - 1 - x] = value  # Reflect across the vertical centerline
	else:
		for y in range(height):
			for x in range(getHalfWayOfLength(width), width):
				var value = map[y][x]
				map_copy[y][width - 1 - x] = value  # Reflect across the vertical centerline
	return map_copy

func applyMirrorHorizontal(map: Array, flipFromTopToBottom: bool=true) -> Array:
	var map_copy = map.duplicate(true)
	var height = map.size()
	var width = map[0].size()

	if flipFromTopToBottom:
		for y in range( 0, getHalfWayOfLength(height) ):
			for x in range(width):
				var value = map[y][x]
				map_copy[height - 1 - y][x] = value  # Reflect across the horizontal centerline
	else:
		for y in range( getHalfWayOfLength(height), height):
			for x in range(width):
				var value = map[y][x]
				map_copy[height - 1 - y][x] = value  # Reflect across the horizontal centerline
	return map_copy


func applyFastPerlinNoise(freqVal:float, thresholdValue:float,  cellToSet:int, map:Array ) -> Array:
	var a := map.duplicate(true)
	var fnl := FastNoiseLite.new()
	fnl.noise_type = FastNoiseLite.TYPE_PERLIN
	fnl.frequency = freqVal
	for y in map.size():
		for x in map[y].size():
			var fnlNoise := fnl.get_noise_2d( x,y  )
			print(fnlNoise)
			if fnlNoise < thresholdValue:
				a = setCell(x,y, cellToSet, a)
	return a



# Apply cellular automaton (Conway's Game of Life)
func apply_cellular_automaton(map: Array, generations: int) -> Array:
	var map_copy = map.duplicate(true)
	var height = map.size()
	var width = map[0].size()

	for generation in range(generations):
		var new_map = map_copy.duplicate(true)
		for y in range(height):
			for x in range(width):
				var alive_neighbors = count_alive_neighbors(x, y, map_copy)
				if map_copy[y][x] == TILES.FLOOR:
					new_map[y][x] = TILES.FLOOR if alive_neighbors in range(2, 4) else TILES.WALL
				else:
					new_map[y][x] = TILES.FLOOR if alive_neighbors == 3 else TILES.WALL
		map_copy = new_map
	return map_copy


# ######################################## #
#
#
#
#			MAP MUTATORS
#	functions are drawing algos applied to your map
#
#
# ######################################## #


func drawRandomLine( startPoint:Vector2i, endPoint:Vector2i, lineSize:int, stepsToTake:int, cellToSet:int, map:Array ) -> Array:
	var a := map.duplicate(true)
	var currPos := startPoint
	for i in stepsToTake:
		var diff := (endPoint- currPos  )
		var dirToMoveIn : Vector2i
		if randf() < 0.5:
			dirToMoveIn = Vector2i( sign(diff.x), 0 ) 
		else:
			dirToMoveIn = Vector2i( 0, sign(diff.y) ) 
		currPos += dirToMoveIn
		print(currPos, endPoint)
		for dx in range( -lineSize, lineSize  ):
			for dy in range( -lineSize, lineSize ):
				a = setCell( currPos.x + dx, currPos.y + dy, cellToSet, a )
	return a



func drawBox(startPoint:Vector2i, size:int,  cellToSet:int, map:Array) -> Array:
	var a := map.duplicate(true)
	for y in range( -size+startPoint.y, size+1+startPoint.y ):
		for x in range( -size+startPoint.x, size+1+startPoint.x ):
			a = setCell(x,y, cellToSet, a)
	return a 


# ensures that a map will always have walls, is an optional and opininated function
# this does not need to be used at 
func drawBorder(cellToSet:int, map:Array) -> Array:
	var heightAndWidth := getMapHeightAndWidth(map)
	var height :int= heightAndWidth[0]
	var width :int= heightAndWidth[1]
	var a := map.duplicate(true)
	for y in height:
		a[y][0] = cellToSet
		a[y][width-1] = cellToSet
	for x in width:
		a[0][x] = cellToSet
		a[height-1][x] = cellToSet
	return a 


func drawRandomWalk( startPos:Vector2i, steps:int, cellToSet:int, map:Array  ) -> Array:
	var a :=map.duplicate(true)
	var currPos := startPos
	for i in steps:
		var xDir := randi_range(-1,1)
		var yDir := 0
		if !(xDir == -1 or xDir == 1):
			yDir = 1 if randf() < 0.5 else -1
		var dir := Vector2i( xDir ,  yDir ) 
		currPos += dir
		a = setCell(currPos.x, currPos.y, cellToSet, map )
	return a


func drawCircle(centerOfCircle: Vector2, radius: int, cellToSet: int,map: Array) -> Array:
	var map_copy = map.duplicate(true)
	var cx = centerOfCircle.x
	var cy = centerOfCircle.y

	for y in range(cy - radius, cy + radius + 1):
		for x in range(cx - radius, cx + radius + 1):
			if (x - cx) * (x - cx) + (y - cy) * (y - cy) <= radius * radius:
				setCell(x, y, cellToSet, map_copy)
	return map_copy


func drawSquare(top_left: Vector2, size: int, cellToSet: int, map: Array) -> Array:
	var a := map.duplicate(true)
	for y in range(top_left.y, top_left.y + size):
		for x in range(top_left.x, top_left.x + size):
			a = setCell(x, y, cellToSet, a)
	return a



func drawSquareEveryNthTiles(square_size: int, every_x_tiles: int, padding: int, cellToSet: int, map: Array) -> Array:
	var map_copy = map.duplicate(true)
	var width = map[0].size()
	var height = map.size()

	for y in range(0, height, every_x_tiles):
		for x in range(0, width, every_x_tiles):
			var top_left = Vector2(x + padding, y + padding)
			map_copy = drawSquare(top_left, square_size, cellToSet, map_copy)
	return map_copy




# ######################################## #
#
#
#
#			BASIC MAP FUNCTIONS 
#
#
#
# ######################################## #

#Generate a map -> generates a 2d array with at a given height and width
func generateMap(height:int, width:int, cellToSetWith:int=TILES.WALL) -> Array:
	var a := []
	for y in height:
		a.append([])
		for x in width:
			a[y].append(cellToSetWith)
	return a

# Sets a cell by checking the width and height of the map to ensure cell placement always happens
# can be cusomtized to handle placing outside or looping around
func setCell ( x:int, y:int, cellToSet:int, map:Array ) -> Array:
	var res := getMapHeightAndWidth(map)
	var height :int= res[0]
	var width :int= res[1]
	if x < width and x >= 0 and y < height and y >= 0:	
		map[y][x] = cellToSet
	return map

func getCell( x:int, y:int, map:Array ) -> int:
	var cellType := -1
	var res := getMapHeightAndWidth(map)
	var height :int= res[0]
	var width :int= res[1]
	if x < width and x >= 0 and y < height and y >= 0:
		cellType = map[y][x]
	return cellType

# prints a map to the godot terminal with X as Wall and _ as floors
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

# just returns a random tile
func getRandomTileType() -> int:
	return TILES.WALL if randf() < 0.5 else TILES.FLOOR

func getMapHeightAndWidth(map:Array) -> Array:
	return [  len(map)  , len(map[0])  ]

func getHalfWayOfLength(width:int) -> int:
	return int( floor( width/2 ) )


# ######################################## #
#
#
#
#			ADVANCED MAP FUNCTIONS 
#	this will return advanced information about the map
#
#
# ######################################## #

func getLesserTile( map:Array ) -> void:
	var countOfTiles := {}
	for tile in TILES:
		countOfTiles[tile] = 0
	for row in map:
		for cell in row:
			match cell:
				
				TILES.FLOOR:
					countOfTiles["FLOOR"] += 1
				TILES.WALL:
					countOfTiles["WALL"] += 1
	var countOfTilesArray := countOfTiles.values()
	countOfTilesArray.sort()
	countOfTilesArray.reverse()
	var leastCountInCountOFTiles :int= countOfTilesArray[  countOfTilesArray.size()-1  ]
	
	prints(countOfTiles.values(), leastCountInCountOFTiles,countOfTilesArray)
	for thing in countOfTiles:
		if countOfTiles[thing] == leastCountInCountOFTiles:
			print("this is the least tile rn: ", thing)
	

# Function to perform flood fill and return a section
func flood_fill(map: Array, start_pos: Vector2, tile_type: int, visited: Dictionary) -> Array:
	var directions = [
		Vector2(1, 0),
		Vector2(-1, 0),
		Vector2(0, 1),
		Vector2(0, -1)
	]
	var stack = [start_pos]
	var section = []
	var width = map[0].size()
	var height = map.size()

	while stack.size() > 0:
		var pos = stack.pop_back()
		var x = pos.x
		var y = pos.y

		if x < 0 or x >= width or y < 0 or y >= height:
			continue
		if visited.has(Vector2(x, y)):
			continue
		if map[y][x] != tile_type:
			continue

		visited[Vector2(x, y)] = true
		section.append(Vector2(x, y))

		for direction in directions:
			stack.append(Vector2(x + direction.x, y + direction.y))

	return section

# Function to get all sections in the map
func getSections(map: Array) -> Array:
	var visited = {}
	var sections = []

	for y in range(map.size()):
		for x in range(map[0].size()):
			if not visited.has(Vector2(x, y)):
				var tile_type = map[y][x]
				var section = flood_fill(map, Vector2(x, y), tile_type, visited)
				if section.size() > 0:
					sections.append(section)

	return sections

func getARandomSection( map:Array )-> Array:
	var randSection : Array
	var sections := getSections(map)
	randSection = sections[  floor( randf() * sections.size() )  ]
	return randSection

func turnRandomSectionIntoAnother(cellToTurnInto:int, map:Array) -> Array:
	var a := map.duplicate(true)
	var section := getARandomSection(map)
	for cell in section:
		a = setCell(cell.x, cell.y, cellToTurnInto, a)
	return a


# Helper function to count alive neighbors
func count_alive_neighbors(x: int, y: int, map: Array) -> int:
	var count = 0
	for dy in range(-1, 2):
		for dx in range(-1, 2):
			if dx == 0 and dy == 0:
				continue
			var nx = x + dx
			var ny = y + dy
			if nx >= 0 and nx < map[0].size() and ny >= 0 and ny < map.size():
				if map[ny][nx] == TILES.FLOOR:
					count += 1
	return count
