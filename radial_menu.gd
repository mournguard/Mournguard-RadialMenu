@tool
class_name RadialMenu extends Control

const RADIAL_MENU_SIZE: float = 320
const RADIAL_MENU = preload("./RadialMenu.tscn")
const MOUSE_ANCHOR_LINE = preload("../Mournguard-Utils/MouseAnchorLine/MouseAnchorLine.tscn")

static var RadialMenuLock: Lock = Lock.new("RadialMenu")

static var SlowdownRequestInstance := SlowdownRequest.new("Radial Menu")

static var CurrentMenu: RadialMenu:
	set(_v):
		CurrentMenu = _v
		if CurrentMenu: Game.register_slowdown(SlowdownRequestInstance)
		else: Game.unregister_slowdown(SlowdownRequestInstance)
static var AnchorLine: MouseAnchorLine

static func Open(_options: Array, _position: Vector2, _track: Node3D = null, _more_text: String = "More...") -> RadialMenu:
	Close()

	var menu := RADIAL_MENU.instantiate()
	menu.more_text = _more_text
	menu.options = _options

	AnchorLine = MOUSE_ANCHOR_LINE.instantiate()

	if _track:
		menu._track_target = _track
		menu._track_position()
	else:
		menu.find_child("Layers").position = _position - Vector2.ONE * RADIAL_MENU_SIZE / 2
		AnchorLine.origin = _position

	AnchorLine.target = _position
	menu.add_child(AnchorLine)

	menu._center_cursor()

	EnableLocks()

	UI.add_temp_interface(menu as Control)

	CurrentMenu = menu
	return menu

static func Close() -> void:
	if CurrentMenu and is_instance_valid(CurrentMenu):
		CurrentMenu.close()

static func IsOpened() -> bool:
	return !!CurrentMenu

static func EnableLocks() -> void:
	Controllable.Locks.lock(RadialMenuLock)
	OverheadLabel.HiddenLocks.lock(RadialMenuLock)
	Interactable.ToggleHighlights(false)

static func DisableLocks() -> void:
	Controllable.Locks.unlock(RadialMenuLock)
	OverheadLabel.HiddenLocks.unlock(RadialMenuLock)
	Interactable.ResetHighlights()

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

var _track_target: Node3D

var more_text: String = ""

func _process(_delta: float) -> void:
	if !_track_target || !_track_target.is_inside_tree(): return
	_track_position()

func _update() -> void:
	NodeTools.Wipe(%Layers)
	base_layer = RadialMenuLayer.Construct(self, options)
	%Layers.add_child(base_layer)

func _track_position() -> void:
	var screen_position := Game.get_viewport().get_camera_3d().unproject_position(_track_target.global_position)
	%Layers.position = screen_position - Vector2.ONE * RADIAL_MENU_SIZE / 2
	AnchorLine.origin = screen_position

func _input(event: InputEvent) -> void:
	if !RadialMenu.CurrentMenu: return

	if event.is_released() and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		get_viewport().set_input_as_handled()
		if current_layer != base_layer:
			previous()
		else:
			close.call_deferred()

func _unhandled_input(event: InputEvent) -> void:
	if !RadialMenu.CurrentMenu: return

	# Other unhandled input at this point should close the menu
	if event.is_released() and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		get_viewport().set_input_as_handled()
		RadialMenu.Close.call_deferred()

func _center_cursor() -> void:
	var transform := Game.get_viewport().get_final_transform()
	Input.warp_mouse((%Layers.position + Vector2.ONE * RADIAL_MENU_SIZE / 2) * transform.get_scale() + transform.origin)

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

	_center_cursor()

func close() -> void:
	if CurrentMenu == self:
		CurrentMenu = null
	UI.remove_temp_interface(self)
	visible = false
	queue_free()
	DisableLocks()
