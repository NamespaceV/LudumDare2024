extends Node2D

@export_file("*.tres") var track_path = "res://Track/track_1.tres"
var track : TrackR

const PIXELS_PER_SECOND = 500

var current_time = 0
var time_scale = 1./4 # 60. / BPM

@onready var enemy_icon_scene = load("res://Editor/EnemyForEditor.tscn")

func _ready():
	open_track(track_path)

func open_track(path:String):
	track_path = path
	$Path.text = path
	track = load(path)
	time_scale = 60.0 / track.bpm
	load_track()

func load_track(keep_music_going = false):
	if not keep_music_going:
		$TRACK.stream = load(track.audio_file)
	for c in $Lanes/Enemies.get_children():
		c.queue_free()
	for note in track.notes:
		for i in range(MainGame.inputs.size()):
			var ch = MainGame.inputs[i]
			if not ch in note.notes:
				continue
			spawn_enemy_icon(note.offset, ch)

func spawn_enemy_icon(time, letter):
	var e = enemy_icon_scene.instantiate() as EnemyForEditor
	e.time = time
	e.letter = letter
	$Lanes/Enemies.add_child(e)
	var letterIdx = MainGame.inputs.find(letter)
	e.position = Vector2(148 + time * PIXELS_PER_SECOND,524 + letterIdx * 150)
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
	load_track(true)

func align(time:float):
	# align to beat (timescale has beet period in seconds)
	
	# last beat passed:
	
	var last_beat = time - (fmod(time, time_scale))
#	if $TRACK.playing:
#		print("%.3f" % time," -> ", "%.3f" % last_beat)
	if time > last_beat + time_scale/2 :
#		print("aligned to -> ", "%.3f" % (last_beat + time_scale))
		return last_beat + time_scale
	else:
		return last_beat

func add_note(time:float, letter:String):
	time = align(time)
	print("add ", letter, " ", str(time))
	spawn_enemy_icon(time, letter)
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
	if $TRACK.playing:
		current_time = $TRACK.get_playback_position()
	$TimeOffset.text = ("%.3f s" % current_time) + \
		"\n aligned= %.3f s" % align(current_time) + \
		"\n scale " + str(time_scale) + \
		"\n max " + ("%.2f s" % get_track_length())
	if Input.is_action_just_pressed("edit_next"):
		#current_time += time_scale
		toggle_music()
	if Input.is_action_just_pressed("edit_prev"):
		current_time -= 1
	if Input.is_action_just_pressed("edit_scale_zoom_in"):
		time_scale /= 2
	if Input.is_action_just_pressed("edit_scale_zoom_out"):
		time_scale *= 2
	if Input.is_action_just_pressed("edit_sync_to_scale"):
		current_time = floorf(current_time)
	$Lanes/Enemies.position.x = 733 - current_time * PIXELS_PER_SECOND
	$Lanes/Start.position.x = $Lanes/Enemies.position.x
	$Line2D/Aligned.position.x = PIXELS_PER_SECOND * ( align(current_time) - current_time )
	
	for i in range(MainGame.inputs.size()):
		var ch = MainGame.inputs[i]
		if Input.is_action_just_pressed(ch):
			add_note(current_time, ch)

	process_mouse()

var mouse_down_last_click = false
var mouse_start_pos : Vector2

func process_mouse():
	if $TRACK.playing:
		mouse_down_last_click = false
		return
	var mouse_pos = get_viewport().get_mouse_position()
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if not mouse_down_last_click:
			mouse_start_pos = mouse_pos
		mouse_down_last_click = true

		var diff = (mouse_pos - mouse_start_pos).x
		current_time -= diff / PIXELS_PER_SECOND

		mouse_start_pos = mouse_pos
	else:
		mouse_down_last_click = false
		


func get_track_length():
	if track.notes.size() == 0:
		return 0
	return track.notes[track.notes.size()-1].offset

func _on_open_button_pressed():
	$FileDialog.show()

func _on_file_dialog_file_selected(path):
	open_track(path)

func _on_save_button__pressed():
	track.sort()
	ResourceSaver.save(track)


func _on_option_button_item_selected(index):
	var t : String = $OptionButton.get_item_text(index)
	AudioServer.playback_speed_scale = float(t.trim_prefix("x"))

func _on_button_play_pressed():
	AudioServer.playback_speed_scale = 1
	get_tree().change_scene_to_file("res://main_scene.tscn")

func _on_button_preview_pressed():
	pass
	#toggle_music()

func toggle_music():
	if not $TRACK.playing:
		if current_time < 0:
			current_time = 0
		$TRACK.play(current_time)
	else:
		$TRACK.stop()

