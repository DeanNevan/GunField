extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var test := {"test1" : 23, 21 : 12, "yes" : 17}
func _ready():
	var a = list_sort_to_array(test, 2)
	print(a)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func list_sort_to_array(list : Dictionary, list_size := 0):
	var _array = []
	var _values = list.values()
	_values.sort()
	_values.invert()
	if list_size > 0:
		_values.resize(list_size)
	for value in _values:
		for i in list:
			if list.get(i) == value and !_array.has(i):
				_array.append(i)
	return _array
