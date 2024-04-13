class_name TrackR
extends Resource

@export var notes: Array[TrackPointR] # must be sorted

func sort():
	notes.sort_custom(func gt(a,b): return a.offset < b.offset)
