extends Sprite2D

var base_position

@export var period_in_seconds : float = 10.0
@export var amplitude : Vector2 = Vector2(0, 10.0)

func _ready():
	base_position = position

func _process(_delta):
	position = base_position + amplitude * sin(2*PI*Time.get_ticks_msec()/1000.0/period_in_seconds)
