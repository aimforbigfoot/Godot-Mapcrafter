extends TileMapLayer

var lightGreenTile := Vector2i(10,4)
var lightBlueTile := Vector2i(29,1)

var darkGreenTile := Vector2i(44,4)
var darkRedTile :=  Vector2i(44,7)


var offsetVar1 := Vector2i(1,0)
var offsetVar2 := Vector2i(2,0)

var floorTile :Vector2i= Vector2i(-1, -1)
var wallTile :Vector2i= Vector2i(-1, -1)


func _ready() -> void:
	setFloorTile()
	setWallTile() 


func setFloorTile() -> void:
	var floorTiles := [ lightBlueTile, lightGreenTile ]
	floorTile = floorTiles[ floor( randf() * floorTiles.size() )  ]

func setWallTile() -> void:
	var wallTiles := [ darkGreenTile, darkRedTile ]
	wallTile = wallTiles[ floor( randf() * wallTiles.size() ) ]

func getFloorTile() -> Vector2i:
	var r := randf()
	if r < 0.78:
		return floorTile
	elif r < 0.89:
		var b := floorTile + offsetVar1
		return b
	else:
		var b := floorTile + offsetVar2
		return b

func getWallTile() -> Vector2i:
	var r := randf()
	if r < 0.95:
		return wallTile
	elif r < 0.98:
		var b := wallTile + offsetVar1
		return b
	else:
		var b := wallTile + offsetVar2
		return b




func getTypeOfTile( tileType:int ) -> Vector2i:
	if tileType == 0:
		return getWallTile()
	else:
		return getFloorTile()





func setTile( x:int, y:int, tileType:int ) -> void:
	set_cell(Vector2i(x,y), 1, getTypeOfTile(tileType), 0  )


func placeWallTile(x:int,y:int) -> void:
#its kinda assumed 0 is floor tile
	setTile( x,y, 0 )

func placeFloorTile(x:int,y:int) -> void:
#its kinda assumed 1 is floor tile
	setTile( x,y, 1 )
