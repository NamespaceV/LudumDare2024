class_name EnemyForEditor
extends Node2D

var hover:bool

var time:float
var letter:String

signal on_clicked (e:EnemyForEditor)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.get_mouse_button_mask() & MOUSE_BUTTON_MASK_LEFT:
		if hover:
			on_clicked.emit(self)
			hover = false


func _on_area_2d_mouse_entered():
	$AnimatedSprite2D.modulate = Color.BLACK
	hover = true


func _on_area_2d_mouse_exited():
	$AnimatedSprite2D.modulate = Color.WHITE
	hover = false
