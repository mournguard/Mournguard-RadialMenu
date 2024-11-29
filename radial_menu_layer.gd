@tool
class_name RadialMenuLayer extends Control

const RADIAL_MENU_LAYER = preload("./RadialMenuLayer.tscn")

static func Construct(_menu: RadialMenu, _options: Array) -> RadialMenuLayer:
	var layer: Control = RADIAL_MENU_LAYER.instantiate()
	layer.menu = _menu
	layer.options = _options
	return layer

var menu: RadialMenu
var parent_slot: RadialMenuSlot
var options: Array:
	set(v):
		options = v
		_update()

func _enter_tree() -> void:
	var p := get_parent()

	if p is RadialMenuSlot: to_slot()
	else: to_menu()

	%MouseCatcher.visible = p is RadialMenuSlot
	show_behind_parent = p is RadialMenuSlot
	visible = p.get_parent() == menu.current_layer if p is RadialMenuSlot else true

func _update() -> void:
	var i := 1
	for option in options:
		var button := get_node("Slot"+str(i)) as RadialMenuSlot

		if i == 8 and options.size() > 8:
			button.text = menu.more_text
			button.submenu = RadialMenuLayer.Construct(menu, options.slice(8))
			button.pressed.connect(func() -> void: menu.next(button.submenu))
			return
		else: i += 1

		if option is Array and option.size():
			button.text = menu.more_text
			button.submenu = RadialMenuLayer.Construct(menu, option)
			button.pressed.connect(func() -> void: menu.next(button.submenu))
		elif option is RadialMenuOption:
			button.text = option.display_name
			button.pressed.connect(func() -> void: option.callable.call())
		else:
			button.visible = false

	while i <= 8:
		var button := get_node("Slot"+str(i)) as RadialMenuSlot
		button.visible = false
		i += 1

func to_slot() -> void:
	position = - Vector2.ONE * RadialMenu.RADIAL_MENU_SIZE / 2 + Vector2.ONE * RadialMenuSlot.SIZE / 2
	scale = Vector2.ONE * 0.3
	modulate.a = 0.5

func to_menu() -> void:
	position = Vector2.ZERO
	scale = Vector2.ONE
	modulate.a = 1
