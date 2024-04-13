class_name MainGame
extends Node2D

var base_position

@export var amplitude : Vector2 = Vector2(0, -500.0)
@export var track : TrackR = preload("res://Track/track_1.tres")
var song_time :float = 0
var points :float = 0
var go_down = false
var hp = 100

#@export
@onready
var nodes : Array[Marker2D] = [
	$Marker2D as Marker2D,
	$Marker2D2 as Marker2D,
	$Marker2D3 as Marker2D,
]
@onready
var paths : Array[Path2D] = [
	$Path2D as Path2D,
	$Path2D2 as Path2D,
	$Path2D3 as Path2D,
]
@export var explosion_scene : PackedScene = load("res://Explosion/Explosion.tscn")
@export var bottom:Marker2D

@export var enemies = [] # Array[Array[Enemy]]

const AFTER_LAST_NOTE_DELAY = 0.5

var idx:int

const inputs = ["q","w","e"]

func clear_enemies():
	for lane in enemies:
		for e in lane:
			if not is_instance_valid(e):
				continue
			e.kill()
	enemies.clear()
	for _i in range(inputs.size()):
		enemies.append([])

func reset_level():
	hp = 100
	points = 0
	song_time = 0
	idx = 0
	$WIN.hide()
	$FAIL.hide()
	clear_enemies()
	$TRACK.seek(0)
	$TRACK.play()

func _ready():
	base_position = position
	reset_level()

func _process(delta):
	$HpBar.value = hp
	$"../Timer".text = "Time: " + str(song_time) +"\n Pts: " + str(int(points))

	if check_end_conditions():
		return

	song_time += delta
	process_input()
#	if go_down:
#		position = base_position + amplitude * clampf(song_time/0.5, 0,1)
	check_spawn_enemies_and_idx()

func check_end_conditions() -> bool:
	if hp <= 0:
		$FAIL.show()
		$TRACK.stop()
		return true
		
	if idx > track.notes.size():
		return true

	if idx == track.notes.size() and \
			song_time > track.notes[idx-1].offset + \
			Enemy.TRACK_TIME_OFFSET_SECONDS + AFTER_LAST_NOTE_DELAY:
		points += hp * 15
		idx += 1
		$WIN.show()
		$TRACK.stop()
		return true
	
	return false

func process_input():
	for i in range(inputs.size()):
		if Input.is_action_just_pressed(inputs[i]):
			spawn_explosion(i)

func check_spawn_enemies_and_idx():
	if idx >= track.notes.size():
		return
	
	if song_time > track.notes[idx].offset - Enemy.TRACK_TIME_OFFSET_SECONDS:
		var n = track.notes[idx].notes
		for i in range(inputs.size()):
			if inputs[i] in n:
				spawn_enemy(i).name = "Enemy_" \
					+ inputs[i] +"_"\
					+ str(int(track.notes[idx].offset*100))
		idx += 1

func spawn_explosion(id:int):
	var ex = explosion_scene.instantiate()
	add_child(ex)
	ex.position = nodes[id].position
	
	var lane = enemies[id]
	var to_remove = []
	for _e in lane:
		if not is_instance_valid(_e):
			to_remove.append(_e)
			continue
		var e = _e as Enemy
		print (e.name, " song time: ", song_time,  " dif: ", e.pct - e.TRACK_TIME_OFFSET_SECONDS)

		if e.near_kill_zone():
			points += 100
			e.kill()
			ex.hit()
	for _e in to_remove:
		lane.remove_at(lane.find(_e))

func spawn_enemy(id:int):
	var e = Enemy.spawn_enemy_on(paths[id])
	enemies[id].append(e)
	e.run_away.connect(enemy_run_away)
	return e

func enemy_run_away():
	hp -= 10
	if hp <= 0:
		$FAIL.show()

func _on_play_button_pressed():
	go_down = true
	song_time = -0
	idx = 0
	$VBoxContainer/PlayButton.hide()


func _on_button_pressed():
	get_tree().change_scene_to_file("res://Editor/editor.tscn")


func _on_button_restart_pressed():
	reset_level()
