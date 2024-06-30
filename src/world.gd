extends Node2D
const WIDTH := 60
const HEIGHT := 18
var sot := []
var mgh : MapGenHandler = MapGenHandler.new()
var count := 0

func _ready() -> void:
	sot = mgh.generateMap(HEIGHT, WIDTH)
	sot = mgh.setCell( 20,10, mgh.TILES.FLOOR , sot )
	mgh.printMap(sot)



func _input(event: InputEvent) -> void:
	if event.is_action_pressed("r"):
		get_tree().reload_current_scene()
	if Input.is_action_just_pressed("step"):
		count += 1
		
		#if count <= 3:
			#sot = mgh.drawRandomLine( Vector2i(0,0), Vector2(190,16), 1, 500, mgh.floorTile, sot )
		if count >= 20:
			sot = mgh.turnRandomSectionIntoAnother( mgh.getRandomTileType(), sot )
		sot = mgh.applyStochasticCellularAutomota(sot, mgh.floorTile, 0.1)
		sot = mgh.drawBox( Vector2i(randi_range(3,190),randi_range(3,18)), randi_range(4,10), mgh.floorTile, sot)
		#sot = mgh.mirrorVertical(sot, true)
		#sot = mgh.applyRadialSymmetry( sot )
		sot = mgh.drawBorder(mgh.wallTile, sot)
		sot = mgh.drawRandomWalk(Vector2i( randi_range(2, 198), randi_range(2,14)  ) , 100, mgh.floorTile, sot)
		mgh.getLesserTile(sot)
		mgh.printMap(sot)

	if Input.is_action_just_pressed("w"):
		var sections = mgh.getSections(sot)
		var newBlankMap := mgh.generateMap(HEIGHT, WIDTH)
		var emojis := [ "T", "X", "A", "B", "D", 'E', "Q", "P", "S", "6","0", "V","M","W","L"]
		var i := 0 
		for section in sections:
			for cell in section:
				newBlankMap[cell.y][cell.x] = emojis[i]
			i += 1
				
		for row in newBlankMap:
			for cell in row:
				pass
			print(row)
		print(sections)
		
