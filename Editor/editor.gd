extends Node2D

@export_file("*.tres") var track_path = "res://Track/track_1.tres"
var track : TrackR

func _ready():
	track = load(track_path)
	$Path.text = track_path
	var e_sc = load("res://Editor/EnemyForEditor.tscn")
	for note in track.notes:
		
		var e = e_sc.instantiate()
		$Lanes/Enemies.add_child(e)
		e.position = Vector2(148 + note.offset * 200,524) 

func _process(delta):
	pass
