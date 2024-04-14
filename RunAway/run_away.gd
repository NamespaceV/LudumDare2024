extends Node2D


func _ready():
	$CPUParticles2D.restart()
	$Timer.wait_time = $CPUParticles2D.lifetime + 2
	$Timer.start()

func _on_timer_timeout():
	queue_free()
