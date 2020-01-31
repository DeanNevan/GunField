extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	var a = [4,2,1]
	a.resize(2)
	print(a)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#$Camera2D.position = $RigidBody2D.position
	pass
