class_name RadialMenuSlot extends Button

const SIZE: float = 80

var submenu: RadialMenuLayer:
	set(v):
		submenu = v
		submenu.parent_slot = self
		submenu.to_slot()
		add_child(submenu)
