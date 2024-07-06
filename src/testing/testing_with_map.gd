extends Node2D

var floorTiles := [ Vector2i(0,0), Vector2i(1,0),Vector2i(2,0),Vector2i(3,0),Vector2i(4,0), Vector2i(5,0), Vector2i(6,0), Vector2i(7,0) ]
var wallTiles := [Vector2i(10,17)]
var mapToUse := []
const HEIGHT := 500
const WIDTH := 500
var mgh := MapGenHandler.new()


func _ready() -> void:
	randomize()
	mgh.setFastNoiseLiteSeed( randi() )
	mapToUse = mgh.generateBlankMap(HEIGHT, WIDTH, mgh.wallTile )
	mapToUse = mgh.applyFastPerlinNoise( 0.07, 0.5, mgh.floorTile, mapToUse )
	mapToUse = mgh.applyConnectionToClosestSections(2, 2, mgh.floorTile, mapToUse)
	mapToUse = mgh.drawBorder( 2, mgh.wallTile, mapToUse )

	setMapToTileset()


func setMapToTileset() -> void:
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


