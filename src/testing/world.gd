extends Node2D
const HEIGHT := 30
const WIDTH := 50
var ttt := MapGenHandler.new()


func _ready() -> void:
	var map := []
	map = ttt.generateBlankMap(WIDTH,HEIGHT, ttt.wallTile)
	for i in 5:
		map = ttt.drawCircle(  ttt.getARandomPointInMap(map), randi_range(5,10), ttt.floorTile, map)
	ttt.printMap(map)
	map = ttt.drawRandomWalksInsideLargeSectionsOfARandomTileType(5, 10, ttt.floorTile, ttt.wallTile, 1, map)
	ttt.printMap(map)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("r"):
		get_tree().reload_current_scene()
