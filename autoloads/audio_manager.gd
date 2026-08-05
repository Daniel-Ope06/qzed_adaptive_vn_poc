extends Node

var click_player: AudioStreamPlayer

func _ready() -> void:
	click_player = AudioStreamPlayer.new()
	click_player.stream = preload("res://assets/sounds/clik_sfx.ogg")
	add_child(click_player)
	
	get_tree().node_added.connect(_connect_sound)
	_connect_nodes(get_tree().root)

func _connect_sound(node: Node) -> void:
	if (node is BaseButton) and not (node.pressed.is_connected(click_player.play)):
		node.pressed.connect(click_player.play)
	
	elif node.is_in_group("Clickable") and not (node.gui_input.is_connected(_gui_click_player)):
		node.gui_input.connect(_gui_click_player)

func _connect_nodes(current_node: Node) -> void:
	_connect_sound(current_node)
	for child in current_node.get_children():
		_connect_nodes(child)

func _gui_click_player(event: InputEvent) -> void:
	var is_tap = event is InputEventScreenTouch and event.pressed
	var is_click = event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed
	
	if is_tap or is_click:
		click_player.play()
