extends Node2D

var start_position = Vector2()
var end_position = Vector2()
var team_color = Color.white
var width = 2

var points_array = []
var colors_array = []

var is_freeing = false

func _draw():
	#print(start_position)
	if points_array.size() >= 2:
		draw_polyline_colors(points_array, colors_array, width, true)
	else:
		pass

func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if is_freeing:
		if points_array.size() > 0:
			points_array.pop_front()
	var count = points_array.size()
	colors_array = []
	if count != 0:
		for i in count:
			var color = Color()
			color = Color(1, 1, 1, float(i) / float(count))
			colors_array.append(color)
	update()

func prepare_free():
	is_freeing = true
	#print("prepare to free")
	yield(get_tree().create_timer(4), "timeout")
	#print("free!!!")
	queue_free()
	visible = false
