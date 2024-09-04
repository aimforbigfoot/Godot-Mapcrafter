extends Node2D
const HEIGHT := 30
const WIDTH := 50
var ttt := MapGenHandler.new()


func _ready() -> void:
	var map := []
	map = ttt.generateBlankMap(WIDTH,HEIGHT, ttt.wallTile)
	for i in 5:
		map = ttt.drawRandomWalk(  ttt.getARandomPointInMap(map), 100, ttt.floorTile, 2, map)
	map = ttt.applyConnectionsLinearly( ttt.floorTile, ttt.floorTile, map )
	ttt.printMap(map)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("r"):
		get_tree().reload_current_scene()
