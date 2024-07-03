 #Welcome to the MapGenHandler V1
# This library helps you generate a bunch of 2d array maps in a simple binary fashion with walls and floors
# It is highly customizable and flexible and can be used to generate a whole host of maps 
extends Node
class_name MapGenHandler
var fnl := FastNoiseLite.new()

enum TILES { WALL, FLOOR, INTEREST, EXTRA }
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

# this will only copy top left and place it around
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
	fnl.noise_type = FastNoiseLite.TYPE_PERLIN
	fnl.frequency = freqVal
	for y in map.size():
		for x in map[y].size():
			var fnlNoise :float= abs(fnl.get_noise_2d( x,y  ))
			if fnlNoise < thresholdValue:
				a = setCell(x,y, cellToSet, a)
	return a
func applyFastValueNoise( freqVal:float, thresholdValue:float, cellToSet:int, map:Array ) -> Array:
	var a := map.duplicate(true)
	fnl.noise_type = FastNoiseLite.TYPE_VALUE
	fnl.frequency = freqVal
	for y in map.size():
		for x in map[y].size():
			var fnlNoise :float =fnl.get_noise_2d(x,y) * 10
			if fnlNoise < thresholdValue:
				a = setCell(x,y, cellToSet, a)
		
	return a
# Apply cellular automaton (Conway's Game of Life)
func applyCellularAutomata(generations: int, cellToApplyWith:int, cellToBlankWith:int, map: Array) -> Array:
	var map_copy :Array= map.duplicate(true)
	var height :int= map.size()
	var width :int= map[0].size()

	for generation in range(generations):
		var new_map := map_copy.duplicate(true)
		for y in range(height):
			for x in range(width):
				var alive_neighbors := countNeighborsOfCertainCellType(x, y, cellToApplyWith, map_copy)
				if map_copy[y][x] == cellToApplyWith:
					new_map[y][x] = cellToApplyWith if alive_neighbors in range(2, 4) else cellToBlankWith
				else:
					new_map[y][x] = cellToApplyWith if alive_neighbors == 3 else cellToBlankWith
		map_copy = new_map
	return map_copy
func applyErosion(iterations: int, cellToApplyWith:int, cellToGetRidOf:int, map: Array) -> Array:
	var map_copy := map.duplicate(true)
	var height := map.size()
	var width :int= map[0].size()
	var neighborsCount := 4 if randf() < 0.5 else 5

	for i in range(iterations):
		for y in range(height):
			for x in range(width):
				if map_copy[y][x] == cellToGetRidOf:
					var neighbors = countNeighborsOfCertainCellType(x, y, cellToApplyWith, map_copy)
					if neighbors >= neighborsCount:
						map_copy[y][x] = cellToApplyWith
	return map_copy
# Function to connect all sections
func applyConnectionsToAllSections(connectionSize:int, tile_type: int, map: Array) -> Array:
	var sections = getSections(map)
	var centroids = []
	
	for section in sections:
		centroids.append(calculateCentroid(section))
	var map_copy = map.duplicate(true)
	for i in range(centroids.size() - 1):
		map_copy = drawCorridor(centroids[i], centroids[i + 1], tile_type, connectionSize, map_copy)
	return map_copy
#this may not seem to do anything cuz this will truly just grab a random section and turn all the tiles
# in that section into another tile, 
func applySpecificTileToARandomSetOfTiles(cellToGetSelectionOf:int, cellToTurnInto:int, map:Array) -> Array:
	var a := map.duplicate(true)
	var section :=  getARandomSectionByTile(cellToGetSelectionOf, map)
	for cell in section:
		a = setCell(cell.x, cell.y, cellToTurnInto, a)
	return a


func applyConnectionToClosestSections(corridor_size: int, max_connections: int, tile_type: int, map: Array) -> Array:
	var sections = getSections(map)
	var map_copy = map.duplicate(true)
	var connections_made = {}

	# Calculate centroids for all sections
	var centroids = []
	for section in sections:
		centroids.append(calculateCentroid(section))

	# Connect sections
	for i in range(centroids.size()):
		var connections = 0
		var distances = []

		# Calculate distances to all other centroids
		for j in range(centroids.size()):
			if i != j:
				distances.append({"index": j, "distance": distance(centroids[i], centroids[j])})

		# Sort distances
		distances.sort_custom(func(a, b): return a["distance"] < b["distance"])

		# Connect to the closest sections
		for dist in distances:
			if connections >= max_connections:
				break
			var j = dist["index"]
			var connection_key = min(i, j) * 1000 + max(i, j)  # Unique key for each pair
			if not connections_made.has(connection_key):
				map_copy = drawCorridor(centroids[i], centroids[j], tile_type, corridor_size, map_copy)
				connections_made[connection_key] = true
				connections += 1

	return map_copy

func applyExpandedTiles(expansionSize: int, tileToSet: int, map: Array) -> Array:
	var map_copy = map.duplicate(true)
	var width = map[0].size()
	var height = map.size()

	for y in range(height):
		for x in range(width):
			if map[y][x] == tileToSet:
				for dx in range(-expansionSize, expansionSize + 1):
					for dy in range(-expansionSize, expansionSize + 1):
						var newX = x + dx
						var newY = y + dy
						setCell(newX, newY, tileToSet, map_copy)

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


func drawLine( startPoint:Vector2i, endPoint:Vector2i, lineSize:int, stepsToTake:int, cellToSet:int, map:Array ) -> Array:
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
func drawBorder(border_size: int, cellToSet: int, map: Array) -> Array:
	var heightAndWidth := getMapHeightAndWidth(map)
	var height: int = heightAndWidth[0]
	var width: int = heightAndWidth[1]
	var a := map.duplicate(true)
	
	for y in range(height):
		for i in range(border_size):
			if y < height:
				if 0 + i < width:
					a[y][0 + i] = cellToSet
				if width - 1 - i >= 0:
					a[y][width - 1 - i] = cellToSet

	for x in range(width):
		for i in range(border_size):
			if 0 + i < height:
				a[0 + i][x] = cellToSet
			if height - 1 - i >= 0:
				a[height - 1 - i][x] = cellToSet

	return a

func drawRandomWalk(startPos: Vector2i, steps: int, cellToSet: int, thickness: int, map: Array) -> Array:
	var a = map.duplicate(true)
	var currPos = startPos
	for i in range(steps):
		var xDir = randi_range(-1, 1)
		var yDir = 0
		if xDir == 0:  # If there's no horizontal movement, choose vertical movement
			yDir = 1 if randf() < 0.5 else -1
		var dir = Vector2i(xDir, yDir)
		currPos += dir
		# Apply thickness to the walk
		for dx in range(-thickness, thickness + 1):
			for dy in range(-thickness, thickness + 1):
				if dx * dx + dy * dy <= thickness * thickness:
					a = setCell(currPos.x + dx, currPos.y + dy, cellToSet, a)
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
# Function to create a corridor between two points with a specified size
func drawCorridor(start: Vector2, end: Vector2, tile_type: int, corridor_size: int, map: Array) -> Array:
	var mapCopy = map.duplicate(true)
	var x0 = int(start.x)
	var y0 = int(start.y)
	var x1 = int(end.x)
	var y1 = int(end.y)

	var dx = abs(x1 - x0)
	var dy = abs(y1 - y0)
	var step_x = 1 if x0 < x1 else -1
	var step_y = 1 if y0 < y1 else -1
	var err = dx - dy

	while true:
		for offset_x in range(-corridor_size, corridor_size + 1):
			for offset_y in range(-corridor_size, corridor_size + 1):
				mapCopy = setCell(x0 + offset_x, y0 + offset_y, tile_type, mapCopy)
		if x0 == x1 and y0 == y1:
			break
		var e2 = err * 2
		if e2 > -dy:
			err -= dy
			x0 += step_x
		if e2 < dx:
			err += dx
			y0 += step_y
	return mapCopy

func drawToFillInPatchesOfASizeByTileType(min_size: int, cellToCheck:int, cellToFillWith:int, map: Array, ) -> Array:
	var sections = getSections(map)
	var map_copy = map.duplicate(true)
	for section in sections:
		if section:
			
			var firstPos :Vector2= section[0]
			if getCell(firstPos.x, firstPos.y, map_copy) == cellToCheck:
				if section.size() < min_size:
					for pos in section:
						map_copy = setCell( pos.x, pos.y, cellToFillWith, map_copy )

	return map_copy

# ######################################## #
#
#
#
#			BASIC MAP FUNCTIONS 
#	functiosn that make map mods and data collection from the map
#	a lot easier for the developer (you) :) 
#
#
# ######################################## #

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
# just returns a random tile
func getRandomTileType( arrOfPossibleTiles:Array ) -> int:
	return arrOfPossibleTiles[ floor( randf() * arrOfPossibleTiles.size() )  ]
func getMapHeightAndWidth(map:Array) -> Array:
	return [  len(map)  , len(map[0])  ]
func getHalfWayOfLength(width:int) -> int:
	return int( floor( width/2 ) )
func getARandomPointInMap(map:Array) -> Vector2i:
	var height := map.size()
	var width :int= map[0].size()
	return Vector2i( 
		randi_range( 0, width ), 
		randi_range(0, height) )
func setFastNoiseLiteSeed(_seed:int) -> void:
	fnl.seed = _seed
	# Function to calculate distance between two points
func distance(p1: Vector2, p2: Vector2) -> float:
	return sqrt(pow(p1.x - p2.x, 2) + pow(p1.y - p2.y, 2))

# prints a map to the godot terminal with X as Wall and _ as floors
func printMap(map:Array) -> void:
	print("\n")
	var aToPrint := []
	for row in map:
		#print(row)
		aToPrint.append([])
		var sToPrint := ''
		for tile in row:
			if tile == wallTile:
				sToPrint += "⬛"
			elif tile == floorTile:
				sToPrint += "🟩"
			elif tile == TILES.INTEREST:
				sToPrint += "🟨"
			else:
				sToPrint += "🔴"
		print(sToPrint)


# ######################################## #
#
#
#
#			ADVANCED MAP FUNCTIONS 
#	this will return advanced information about the map
#
#
# ######################################## #

# Function to count the occurrences of each tile type in the map
func countTiles(map: Array) -> Dictionary:
	var countOfTiles = {}
	for row in map:
		for cell in row:
			if not countOfTiles.has(cell):
				countOfTiles[cell] = 0
			countOfTiles[cell] += 1
	return countOfTiles

# Function to get the tile type with the least occurrences in the map
func getLeastCommonTile(map: Array) -> int:
	var countOfTiles = countTiles(map)
	var minCount = INF
	var leastCommonTile = -1

	for tile in countOfTiles.keys():
		if countOfTiles[tile] < minCount:
			minCount = countOfTiles[tile]
			leastCommonTile = tile

	return leastCommonTile

# Function to perform flood fill and return a section
func getAllTilesOfSameTypeWithFloodFill(map: Array, start_pos: Vector2, tile_type: int, visited: Dictionary) -> Array:
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


# Helper function to count alive neighbors
func countNeighborsOfCertainCellType(x: int, y: int, cellToCheck:int, map: Array) -> int:
	var count = 0
	for dy in range(-1, 2):
		for dx in range(-1, 2):
			if dx == 0 and dy == 0:
				continue
			var nx = x + dx
			var ny = y + dy
			if getCell(nx,ny, map) ==  cellToCheck:
				count += 1
	return count

func identifyPointsOfInterestOnMapByTileType( tileToCheck:int,map:Array) -> Array:
	var a := map.duplicate(true)
	var sectionsByTileType := getSectionsOfACertainTile(tileToCheck, map)
	for section in sectionsByTileType:
		var centerOfSection := findCenterTileGivenASection( section )
		setCell( centerOfSection.x, centerOfSection.y, 6, a )
	return a

# ######################################## #
#
#
#
#			MAP SECTION FUNCTIONS 
#	functions that relate to sections of a map
#	and their manipulation / calulation
#
#
# ######################################## #

# Function to get all sections in the map
func getSections(map: Array) -> Array:
	var visited = {}
	var sections = []
	for y in range(map.size()):
		for x in range(map[0].size()):
			if not visited.has(Vector2(x, y)):
				var tile_type = map[y][x]
				var section = getAllTilesOfSameTypeWithFloodFill(map, Vector2(x, y), tile_type, visited)
				if section.size() > 0:
					sections.append(section)
	return sections
# Function to get all sections of a certain tile type
func getSectionsOfACertainTile(tile_type: int, map: Array) -> Array:
	var visited = {}
	var sections = []

	for y in range(map.size()):
		for x in range(map[0].size()):
			if not visited.has(Vector2(x, y)) and map[y][x] == tile_type:
				var section = getAllTilesOfSameTypeWithFloodFill(map, Vector2(x, y), tile_type, visited)
				if section.size() > 0:
					sections.append(section)
	return sections
func getARandomSection( sections:Array , map:Array )-> Array:
	var randSection : Array
	randSection = sections[  floor( randf() * sections.size() )  ]
	return randSection
func getARandomSectionByTile( cellToGetSelectionOf:int, map:Array  ) -> Array:
	return getARandomSection(  getSectionsOfACertainTile(cellToGetSelectionOf, map), map)

# Function to get the largest section of a certain tile type
func getLargestSectionOfTileType(tile_type: int, map: Array) -> Array:
	var sections = getSectionsOfACertainTile(tile_type, map)
	var largest_section = []
	var max_size = 0
	for section in sections:
		if section.size() > max_size:
			largest_section = section
			max_size = section.size()
	return largest_section
func findCenterTileGivenASection(section: Array) -> Vector2:
	if section.size() == 0:
		return Vector2(-1, -1)  # Return an invalid position if the section is empty
	var sum_x = 0
	var sum_y = 0
	for pos in section:
		sum_x += pos.x
		sum_y += pos.y
	var center_x = int(round(float(sum_x) / section.size()))
	var center_y = int(round(float(sum_y) / section.size()))

	return Vector2(center_x, center_y)


func checkAndConnectIfAllSectionsOfACertainTileAreConnected(tileToCheck:int, mapToCheck:Array) -> Array:
	var a := mapToCheck.duplicate(true)
	var sectionsByTile = getSectionsOfACertainTile(tileToCheck, mapToCheck)
	var i := 0 
	for section in sectionsByTile:
		if i < sectionsByTile.size()-1:
			var points := closestPointsBetweenSections( sectionsByTile[i], sectionsByTile[i+1]  )
			var point1 :Vector2= points[0]
			var point2 :Vector2= points[1]
			a = drawLine( point1, point2, 2, 200, tileToCheck, a )
		else:
			break
		i += 1
	if sectionsByTile.size() > 1:
		print("these are not connected")
		for section in sectionsByTile:
			pass
	return a 
	
# Function to calculate the closest points between two sections
func closestPointsBetweenSections(section1: Array, section2: Array) -> Array:
	var min_distance = INF
	var closest_pair = [Vector2(), Vector2()]

	for point1 in section1:
		for point2 in section2:
			var dist = distance(point1, point2)
			if dist < min_distance:
				min_distance = dist
				closest_pair[0] = point1
				closest_pair[1] = point2

	return closest_pair


# Function to calculate the centroid of a section
func calculateCentroid(section: Array) -> Vector2:
	var sum_x = 0
	var sum_y = 0
	for pos in section:
		sum_x += pos.x
		sum_y += pos.y
	return Vector2(sum_x / section.size(), sum_y / section.size())


func totalDistance(selected_points: Array) -> float:
	var total = 0.0
	for i in range(selected_points.size()):
		for j in range(i + 1, selected_points.size()):
			total += distance(selected_points[i], selected_points[j])
	return total

func findSmallestSquare(points: Array) -> Array:
	if points.size() == 0:
		return [0,0]

	var min_x :int= points[0].x
	var max_x :int= points[0].x
	var min_y :int= points[0].y
	var max_y :int= points[0].y

	for point in points:
		if point.x < min_x:
			min_x = point.x
		if point.x > max_x:
			max_x = point.x
		if point.y < min_y:
			min_y = point.y
		if point.y > max_y:
			max_y = point.y

	var width = max_x - min_x + 1
	var height = max_y - min_y + 1
	return [width, height]

# Function to find the most N distant points in a section using Farthest Point Sampling
func findMostDistantPoints(section: Array, numPoints: int) -> Array:
	if section.size() <= numPoints:
		return section  # If there are fewer points than numPoints, return all points

	var selectedPoints = []
	var distances = []

	# Start with an arbitrary point (first point)
	selectedPoints.append(section[0])

	# Initialize distances from the first point to all other points
	for point in section:
		distances.append(distance(section[0], point))

	# Select the farthest point in each iteration
	for smth in range(numPoints - 1):
		var maxDistance = -1
		var maxIndex = -1

		# Find the point with the maximum distance to the selected points
		for i in range(section.size()):
			if distances[i] > maxDistance:
				maxDistance = distances[i]
				maxIndex = i

		# Add the farthest point to the selected points
		selectedPoints.append(section[maxIndex])

		# Update the distances to the new selected point
		for i in range(section.size()):
			distances[i] = min(distances[i], distance(section[maxIndex], section[i]))

	return selectedPoints


# Function to find the minimum distance of a point to any wall in the map
func minDistanceToWall(point: Vector2, walls: Array) -> float:
	var minDistance = INF
	for wall in walls:
		var dist = distance(point, wall)
		if dist < minDistance:
			minDistance = dist
	return minDistance

# Function to find the most N distant points in a section using Farthest Point Sampling, ensuring points are not too near walls
func findMostDistantPointsWithPaddingFromWall(section: Array, walls: Array, num_points: int, min_dist_from_wall: float) -> Array:
	if section.size() <= num_points:
		return section  # If there are fewer points than num_points, return all points

	var selected_points = []
	var distances = []
	var valid_points = []

	# Filter points that are not too near a wall
	for point in section:
		if minDistanceToWall(point, walls) >= min_dist_from_wall:
			valid_points.append(point)

	if valid_points.size() == 0:
		return []  # No valid points found

	# Start with an arbitrary point (first point)
	selected_points.append(valid_points.pop_back())

	# Initialize distances from the first point to all other points
	for point in valid_points:
		distances.append({"point": point, "distance": distance(selected_points[0], point)})

	# Select the farthest point in each iteration
	for xxxxx in range(num_points - 1):
		if distances.size() == 0:
			break

		# Find the point with the maximum distance
		distances.sort_custom(func(a, b): return a["distance"] > b["distance"])
		var farthest = distances.pop_front()
		selected_points.append(farthest["point"])

		# Update the distances to the new selected point
		for i in range(distances.size()):
			distances[i]["distance"] = min(distances[i]["distance"], distance(farthest["point"], distances[i]["point"]))

	return selected_points
# ######################################## #
#
#
#
#			MAP GENERATORS
#	functions that help make a blank map
#
#
# ######################################## #


#Generate a map -> generates a 2d array with at a given height and width
func generateBlankMap(height:int, width:int, cellToSetWith:int) -> Array:
	var a := []
	for y in height:
		a.append([])
		for x in width:
			a[y].append(cellToSetWith)
	return a
# Generate a map with a border of specified thickness
func generateBorderedMap(width: int, height: int, border_tile: int, inner_tile: int, border_thickness: int = 1) -> Array:
	var map = []
	for y in range(height):
		var row = []
		for x in range(width):
			if y < border_thickness or y >= height - border_thickness or x < border_thickness or x >= width - border_thickness:
				row.append(border_tile)
			else:
				row.append(inner_tile)
		map.append(row)
	return map
# Generate a diagonal stripes pattern map with customizable stripe width and direction
func generateDiagonalStripesMap(width: int, height: int, tile_type1: int, tile_type2: int, stripe_width: int = 1, reverse_direction: bool = false) -> Array:
	var map = []
	for y in range(height):
		var row = []
		for x in range(width):
			var diagonal_index = x + y if reverse_direction else x - y
			# Use integer division to determine which stripe we're in
			var stripe_index = (diagonal_index / stripe_width) % 2
			row.append(tile_type1 if stripe_index == 0 else tile_type2)
		map.append(row)
	return map
# Generate a row by row pattern map with a specified row thickness
func generateRowMap(width: int, height: int, tile_type1: int, tile_type2: int, row_thickness: int) -> Array:
	var map = []
	for y in range(height):
		var row = []
		var current_tile_type = tile_type1 if (y / row_thickness) % 2 == 0 else tile_type2
		for x in range(width):
			row.append(current_tile_type)
		map.append(row)
	return map
# Generate a column by column pattern map with a specified column thickness
func generateColumnMap(width: int, height: int, tile_type1: int, tile_type2: int, column_thickness: int) -> Array:
	var map = []
	for y in range(height):
		var row = []
		for x in range(width):
			var current_tile_type = tile_type1 if (x / column_thickness) % 2 == 0 else tile_type2
			row.append(current_tile_type)
		map.append(row)
	return map
# Generate a checkerboard pattern map with a specified square size
func generateCheckerboardMap(width: int, height: int, tile_type1: int, tile_type2: int, square_size: int) -> Array:
	var map = []
	for y in range(height):
		var row = []
		for x in range(width):
			var checker_x = (x / square_size) % 2
			var checker_y = (y / square_size) % 2
			row.append(tile_type1 if (checker_x + checker_y) % 2 == 0 else tile_type2)
		map.append(row)
	return map
# TO DO
# I need functiosn that go into a random section of tile and place a specific feature into it
# perhaps a function that only goes into the top left and then youd apply radial symmetry to that stuff
