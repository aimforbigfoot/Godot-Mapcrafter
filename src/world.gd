extends Node2D
const WIDTH := 21
const HEIGHT := 21
var sot := []

enum TILES { BLANK, CAVE }

func _ready() -> void:
	sot = generateMap()
	setCell( 4,4,TILES.CAVE, sot )
	printMap(sot)
	

func generateMap() -> Array:
	var a := []
	for y in HEIGHT:
		a.append([])
		for x in WIDTH:
			a[y].append(0)
	return a

func stepMap(map:Array) -> Array:
	var mapCopy := map.duplicate(true)
	var y := 0
	for row in map:
		var x:= 0 
		for cell in row:
			if cell == TILES.CAVE:
				for dx in range(-1,2):
					for dy in range(-1,2):
						var accX :int= x + dx 
						var accY :int= y + dy
						if randf() < 0.1:
							mapCopy = setCell(accX,accY, TILES.CAVE, mapCopy)
			x+= 1
		y+= 1
	return mapCopy

func decideWhatToDo() -> void:
	
	pass

func printMap(map) -> void:
	print("\n")
	for row in map:
		print(row)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("r"):
		get_tree().reload_current_scene()
	if Input.is_action_just_pressed("step"):
		sot = stepMap(sot)
		printMap(sot)

func setCell ( x:int, y:int ,cellToSet:int, map:Array ) -> Array:
	if x < WIDTH and x >= 0 and y < HEIGHT and y >= 0:
		map[y ][x] = cellToSet
	return map

# test 
