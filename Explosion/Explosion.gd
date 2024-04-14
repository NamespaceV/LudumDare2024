extends Node2D

var ex_hit:bool

func _ready():
	$Timer.wait_time = $CPUParticles2D.lifetime + 2
	$Timer.start()
	#$CPUParticles2D.restart()
	$Polygon2D.modulate = Color.from_string("ff7a75", Color.ANTIQUE_WHITE)

func _process(_delta):
	pass

func _on_timer_timeout():
	queue_free()

func _on_timer_2_timeout():
	$Polygon2D.hide()
	if not ex_hit:
		queue_free()

func hit():
	ex_hit = true
	$CPUParticles2D.restart()
	$CPUParticles2D.modulate = Color.YELLOW
	$Polygon2D.modulate = Color.YELLOW_GREEN
