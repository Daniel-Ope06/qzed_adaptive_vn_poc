extends Panel

@onready var close_panel: PanelContainer = $Panel/ClosePanel
@onready var scroll_container: ScrollContainer = $Panel/MarginContainer/ScrollContainer

@onready var dialogue_list: VBoxContainer = $Panel/MarginContainer/ScrollContainer/DialogueList
@onready var dialogue_template: VBoxContainer = $Panel/MarginContainer/ScrollContainer/DialogueList/DialogueTemplate
@onready var line_template: PanelContainer = $Panel/MarginContainer/ScrollContainer/DialogueList/LineTemplate


func _ready() -> void:
	close_panel.gui_input.connect(_on_close_panel_gui_input)


func _setup_dialogue_list(dialogues: Array[Dictionary]) -> void:
	dialogue_template.hide()
	line_template.hide()
	var index: int = 0
	
	for dialogue in dialogues:
		var new_dialogue = dialogue_template.duplicate()
		var new_speaker = new_dialogue.get_node("NamePanel/SpeakerName")
		var new_text = new_dialogue.get_node("DialogueText")
		var new_panel = new_dialogue.get_node("NamePanel")
		
		new_speaker.text = dialogue["speaker"]
		new_text.text = dialogue["text"]
		
		var speaker_style = GameManager.CHAR_STYLES_2.get(dialogue["speaker"], GameManager.CHAR_STYLES_2["System"])
		new_speaker.add_theme_color_override("font_color", speaker_style["font_color"])
		
		var panel_style = new_panel.get_theme_stylebox("panel").duplicate()
		panel_style.bg_color = speaker_style["bg_color"]
		panel_style.border_color = speaker_style["border_color"]
		new_panel.add_theme_stylebox_override("panel", panel_style)
		
		index += 1
		new_dialogue.show()
		dialogue_list.add_child(new_dialogue)
		
		if index < dialogues.size():
			var new_line = line_template.duplicate()
			new_line.show()
			dialogue_list.add_child(new_line)

func _clear_dialogue_list() -> void:
	for child in dialogue_list.get_children():
		if child != dialogue_template and child != line_template:
			dialogue_list.remove_child(child) 
			child.queue_free()

func open_popup() -> void:
	_setup_dialogue_list(GameManager.current_history)
	show()
	_scroll_to_bottom()

func close_popup() -> void:
	_clear_dialogue_list()
	hide()

func _scroll_to_bottom() -> void:
	await get_tree().process_frame
	var v_scrollbar = scroll_container.get_v_scroll_bar()
	v_scrollbar.value = v_scrollbar.max_value

func _on_close_panel_gui_input(event: InputEvent) -> void:
	var is_tap = event is InputEventScreenTouch and event.pressed
	var is_click = event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed
	
	if is_tap or is_click:
		close_popup()
