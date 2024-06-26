class_name Enemy
extends Node2D

const SPEED = 0.5
const TRACK_TIME_OFFSET_SECONDS = 0.6 / SPEED # sec
const TOLERANCE_SECONDS = 0.1

var p:Path2D
var pct = 0.

signal run_away(e : Enemy)
var run_away_done

func _ready():
	$AnimatedSprite2D.play()

func _process(delta):
	pct += delta * SPEED
	position = p.position + p.scale * p.curve.sample(0,pct)
	$AnimatedSprite2D/Label.text = str(int(pct * 100))
	if pct/SPEED > TRACK_TIME_OFFSET_SECONDS + TOLERANCE_SECONDS:
		if not run_away_done:
			run_away.emit(self)
			run_away_done = true
	if pct > 1:
		queue_free()

func near_kill_zone():
	return abs(pct/SPEED - TRACK_TIME_OFFSET_SECONDS) < TOLERANCE_SECONDS

func kill():
	hide()
	queue_free()

static func spawn_enemy_on( path : Path2D ) -> Enemy:
	var enemy_scene = preload("res://Enemy/Enemy.tscn")
	var e = enemy_scene.instantiate()
	e.p = path
	path.get_parent().add_child(e)
#	path.get_tree().get_root().add_child(e)
	e.position = path.position + path.scale * path.curve.sample(0,0)
	return e
	
