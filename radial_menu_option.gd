class_name RadialMenuOption

var display_name: String
var callable: Callable

func _init(_name:String, _callable: Callable) -> void:
	display_name = _name
	callable = _callable
