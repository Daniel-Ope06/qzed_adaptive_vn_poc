extends Node

func _ready() -> void:
	var puzzle_cursor = preload("res://assets/cursor.png")
	var hotspot = Vector2(7, 2)
	Input.set_custom_mouse_cursor(puzzle_cursor, Input.CURSOR_ARROW, hotspot)
	Input.set_custom_mouse_cursor(puzzle_cursor, Input.CURSOR_POINTING_HAND, hotspot)
