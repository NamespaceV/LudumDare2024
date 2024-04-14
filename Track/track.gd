class_name TrackR
extends Resource

@export var notes: Array[TrackPointR] # must be sorted
@export_file("*.mp3") var audio_file: String
@export_multiline var description:String

func sort():
	notes.sort_custom(func gt(a,b): return a.offset < b.offset)
