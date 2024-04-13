extends Node2D

@export_file("*.tres") var track_path = "res://Track/track_1.tres"
var track : TrackR

const PIXELS_PER_SECOND = 500

var time_offset = 0
var time_scale = 1.0

func _ready():
	open_track(track_path)

func open_track(path:String):
	track_path = path
	$Path.text = path
	track = load(path)
	load_track()

func load_track():
	for c in $Lanes/Enemies.get_children():
		c.queue_free()
	var e_sc = load("res://Editor/EnemyForEditor.tscn")
	for note in track.notes:
		for i in range(MainGame.inputs.size()):
			var ch = MainGame.inputs[i]
			if not ch in note.notes:
				continue
			var e = e_sc.instantiate() as EnemyForEditor
			e.time = note.offset
			e.letter = ch
			$Lanes/Enemies.add_child(e)
			e.position = Vector2(148 + note.offset * PIXELS_PER_SECOND,524 + i * 150)
			e.on_clicked.connect(delete_note_event)

func delete_note_event(e:EnemyForEditor):
	delete_note(e.time, e.letter)

func delete_note(time:float, letter:String):
	print("delete ", letter, " ", str(time))
	for note in track.notes:
		if is_equal_approx(note.offset, time):
			note.notes = note.notes.replace(letter, "")
	var i = 0
	while i < track.notes.size():
		if track.notes[i].notes == "":
			track.notes.remove_at(i)
		else:
			i += 1
	load_track()

func add_note(time:float, letter:String):
	print("add ", letter, " ", str(time))
	var idx = 0
	while track.notes.size() < idx and track.notes[idx].offset < time:
		idx += 1
	if track.notes.size() == idx:
		track.notes.append(TrackPointR.create(time, letter))
	elif is_equal_approx(time, track.notes[idx].offset ):
		if letter not in track.notes[idx].notes:
			track.notes[idx].notes += letter
	else :
		track.notes.insert(idx, TrackPointR.create(time, letter))

func _process(_delta):
	$TimeOffset.text = str(time_offset) + "\n scale " + str(time_scale)
	if Input.is_action_just_pressed("edit_next"):
		time_offset += time_scale
	if Input.is_action_just_pressed("edit_prev"):
		time_offset -= time_scale
	if Input.is_action_just_pressed("edit_scale_zoom_in"):
		time_scale /= 2
	if Input.is_action_just_pressed("edit_scale_zoom_out"):
		time_scale *= 2
	if Input.is_action_just_pressed("edit_sync_to_scale"):
		time_offset = floorf(time_offset)
	$Lanes/Enemies.position.x = - time_offset * PIXELS_PER_SECOND
	for i in range(MainGame.inputs.size()):
		var ch = MainGame.inputs[i]
		if Input.is_action_just_pressed(ch):
			add_note(time_offset, ch)
			load_track()


func _on_open_button_pressed():
	$FileDialog.show()

func _on_file_dialog_file_selected(path):
	open_track(path)

func _on_save_button__pressed():
	ResourceSaver.save(track)

