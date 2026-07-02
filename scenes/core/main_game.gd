extends Control

@onready var visual_layer: Control = $VisualLayer
@onready var dialogue_ui = $UILayer/DialogueUI


func _ready() -> void:
	# Custom mouse cursor
	var puzzle_cursor = preload("res://assets/cursor.png")
	var hotspot = Vector2(7, 2)
	Input.set_custom_mouse_cursor(puzzle_cursor, Input.CURSOR_ARROW, hotspot)
	Input.set_custom_mouse_cursor(puzzle_cursor, Input.CURSOR_POINTING_HAND, hotspot)
	
	# For testing purposes, use dispersion event cg.
	var test_asset_path: String = "res://assets/cgs/cg_ch3_prism_dispersion.png"
	visual_layer.display_scene(visual_layer.VisualType.EVENT_CG, test_asset_path)
	
	var zach_font_color = Color("#003D7A")
	var zach_bg_color = Color("#99CCFF")
	dialogue_ui.update_speaker("Zach", zach_font_color, zach_bg_color)
	
	var physics_line = "When white light passes through a prism, it separates into a spectrum of colors. This is known as [color=#FF7F00][url=dispersion_def]dispersion[/url][/color]."
	dialogue_ui.update_dialogue(physics_line)
