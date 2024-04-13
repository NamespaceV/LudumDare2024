class_name TrackPointR
extends Resource

@export var offset : float
@export var notes : String

static func create(_o:float, _n:String) -> TrackPointR:
	var r = TrackPointR.new()
	r.offset = _o
	r.notes = _n
	return r
