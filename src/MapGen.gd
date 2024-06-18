class_name MapGenHelper
extends Node
enum TILES { WALL, FLOOR }

func generateMap(height, width) -> Array:
	var a := []
	for y in height:
		a.append([])
		for x in width:
			a[y].append(TILES.WALL)
	return a


func setCell ( x:int, y:int, cellToSet:int, map:Array ) -> Array:
	var res := getMapHeightAndWidth(map)
	var HEIGHT :int= res[0]
	var WIDTH :int= res[1]
	if x < WIDTH and x >= 0 and y < HEIGHT and y >= 0:
		map[y][x] = cellToSet
	return map



func stepMap(map:Array) -> Array:
	var mapCopy := map.duplicate(true)
	var y := 0
	for row in map:
		var x:= 0 
		for cell in row:
			if cell == TILES.FLOOR:
				for dx in range(-1,2):
					for dy in range(-1,2):
						var accX :int= x + dx 
						var accY :int= y + dy
						#THIS IS THE MEAT AND POTATOES OF THE FUNCTION 
						if randf() < 0.1:
							mapCopy = setCell(accX,accY, TILES.FLOOR, mapCopy)
			x+= 1
		y+= 1
	return mapCopy


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


func getMapHeightAndWidth(map:Array) -> Array:
	return [  len(map)  , len(map[0])  ]

