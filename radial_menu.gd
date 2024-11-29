@tool
class_name RadialMenu extends Control

const RADIAL_MENU_SIZE: float = 320
const RADIAL_MENU = preload("./RadialMenu.tscn")
const MOUSE_ANCHOR_LINE = preload("../Mournguard-Utils/MouseAnchorLine/MouseAnchorLine.tscn")

static var CurrentMenu: RadialMenu
static var AnchorLine: MouseAnchorLine

static func Open(_options: Array, _position: Vector2, _more_text: String) -> RadialMenu:
	if CurrentMenu and is_instance_valid(CurrentMenu):
		CurrentMenu.close()

	var menu := RADIAL_MENU.instantiate()
	menu.more_text = _more_text
	menu.options = _options
	menu.position = _position - Vector2.ONE * RADIAL_MENU_SIZE / 2
	UI.add_child(menu)

	AnchorLine = MOUSE_ANCHOR_LINE.instantiate()
	AnchorLine.origin = _position
	menu.add_child(AnchorLine)

	CurrentMenu = menu
	return menu

var base_layer: RadialMenuLayer
var current_layer: RadialMenuLayer:
	get():
		var last_layer: RadialMenuLayer
		for c in %Layers.get_children():
			if c is RadialMenuLayer:
				last_layer = c
		return last_layer

var options: Array:
	set(v):
		options = v
		_update()

var _opening: bool = true

var more_text: String = ""

func _update() -> void:
	NodeTools.Wipe(%Layers)
	base_layer = RadialMenuLayer.Construct(self, options)
	%Layers.add_child(base_layer)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_released() and event.button_index == MOUSE_BUTTON_RIGHT:
			if _opening:
				_opening = false
			else: previous()

func previous() -> void:
	if current_layer:
		var last_layer := current_layer
		%Layers.remove_child(last_layer)
		if last_layer.parent_slot:
			last_layer.to_slot()
			last_layer.parent_slot.add_child(last_layer)
		else:
			last_layer.queue_free()

	if current_layer:
		current_layer.visible = true
	else: close()

func next(new_layer: RadialMenuLayer) -> void:
	if new_layer.is_inside_tree():
		new_layer.get_parent().remove_child(new_layer)

	for c in %Layers.get_children():
		c.visible = false

	%Layers.add_child(new_layer)

func close() -> void:
	if CurrentMenu == self:
		CurrentMenu = null
	visible = false
	queue_free()
