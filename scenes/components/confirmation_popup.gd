extends Panel

@onready var cancel_button: Button = $Panel/MarginContainer/Column/ButtonAlignment/CancelButton
@onready var return_button: Button = $Panel/MarginContainer/Column/ButtonAlignment/ReturnButton
@onready var close_panel: PanelContainer = $Panel/ClosePanel

func _ready() -> void:
	cancel_button.pressed.connect(close_popup)
	return_button.pressed.connect(_on_return_pressed)
	close_panel.gui_input.connect(_on_close_panel_gui_input)

func open_popup() -> void:
	show()

func close_popup() -> void:
	hide()

func _on_return_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menus/timeline.tscn")

func _on_close_panel_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		close_popup()
