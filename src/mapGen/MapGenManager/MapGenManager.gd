extends Node
class_name MapGenManager

var height : int
var width : int
enum TILES { WALL, FLOOR }
#
var mgh: MapGenHandler = MapGenHandler.new()
var map := []

var thread := Thread.new()
var isRunning := false
signal mapGenDone 


func genSimpleMap() -> Array:
	var m := []
	startThread("smth")
	return m 



func startThread(params) -> void:
	print(params, " this was printed from the start of thread")
	if isRunning:
		return
	isRunning = true
	var s := func(x):
		genMap("IDK SMTH PROPERT")
	thread.start( s  ,Thread.PRIORITY_HIGH )
	pass

func genMap (p1) -> void:
	print("this was generaeted", p1)
	emit_signal("mapGenDone")


func setWidthAndHeight( _w, _h ) -> void:
	width = _w
	height = _h

