extends MarginContainer

signal dialogue_finished
signal choice_selected(next_block: String)

# --- SCENE TREE REFERENCES ---
@onready var main_stack: VBoxContainer = $MainStack
@onready var choice_alignment: VBoxContainer = $MainStack/TopMarginBox/ChoiceAlignment
@onready var dialogue_alignment: VBoxContainer = $MainStack/BottomAlignment/DialogueAlignment
@onready var button_alignment: HBoxContainer = $MainStack/BottomAlignment/ButtonAlignment
@onready var confirmation_popup: Panel = $OverlayLayer/ConfirmationPopup
@onready var word_bank_popup: Panel = $OverlayLayer/WordBankPopup
@onready var history_popup: Panel = $OverlayLayer/HistoryPopup

# Speaker Nodes
@onready var name_panel: PanelContainer = $MainStack/BottomAlignment/DialogueAlignment/NameAlignment/NamePanel
@onready var speaker_name: RichTextLabel = $MainStack/BottomAlignment/DialogueAlignment/NameAlignment/NamePanel/SpeakerName
@onready var tab_piece: Control = $MainStack/BottomAlignment/DialogueAlignment/NameAlignment/TabAlignment/TabCircle

# Dialogue Nodes
@onready var dialogue_text: RichTextLabel = $MainStack/BottomAlignment/DialogueAlignment/TextPanel/Padding/Row/DialogueText
@onready var hide_ui_button: Button = $MainStack/BottomAlignment/ButtonAlignment/Row2/HideUIButton
@onready var next_button: Button = $MainStack/BottomAlignment/ButtonAlignment/Row1/NextButton
@onready var timeline_button: Button = $MainStack/BottomAlignment/ButtonAlignment/Row1/TimelineButton
@onready var dictionary_button: Button = $MainStack/BottomAlignment/DialogueAlignment/TextPanel/Padding/Row/DictionaryButton
@onready var history_button: Button = $MainStack/BottomAlignment/ButtonAlignment/Row2/HistoryButton

# Choice Node
@onready var choice_template = $MainStack/TopMarginBox/ChoiceAlignment/ChoiceTemplate

# State
var is_ui_hidden: bool = false
var current_index: int = 0

var current_dialogues: Array = []
var current_choices: Array = []
var text_tween: Tween
var fade_dialogue_tween: Tween
var fade_button_tween: Tween

func _ready() -> void:
	# Enable BBCode to use bold text and URL keywords
	dialogue_text.bbcode_enabled = true
	
	# Hide Popup
	confirmation_popup.close_popup()
	word_bank_popup.close_popup()
	
	# Connect Signals
	next_button.pressed.connect(_on_next_button_pressed)
	hide_ui_button.pressed.connect(_on_hide_ui_button_pressed)
	history_button.pressed.connect(_on_history_button_pressed)
	timeline_button.pressed.connect(_on_timeline_button_pressed)
	dictionary_button.pressed.connect(_on_dictionary_button_pressed)
	dialogue_text.meta_clicked.connect(_on_keyword_clicked)


# --- DIALOGUE LOGIC ---

func start_dialogue(dialogue_array: Array, choices_array: Array = []) -> void:
	# Reset UI for new scene
	choice_alignment.hide()
	_clear_old_choices()
	toggle_dialogue_box(true)
	toggle_button_row(true)
	
	current_dialogues = dialogue_array
	current_choices = choices_array
	current_index = 0
	
	_display_current_line()

func _display_current_line() -> void:
	var line_data = current_dialogues[current_index]
	var speaker = line_data["speaker"]
	var style = GameManager.CHAR_STYLES.get(speaker, GameManager.CHAR_STYLES["System"])
	GameManager.add_to_history(line_data["speaker"], line_data["text"])
	_update_speaker(speaker, style["font_color"], style["bg_color"])
	_update_dialogue(line_data["text"])


# --- HIDE / SHOW UI LOGIC ---
func toggle_dialogue_box(show_ui: bool) -> void:
	if fade_dialogue_tween and fade_dialogue_tween.is_valid():
		fade_dialogue_tween.kill()
	fade_dialogue_tween = create_tween()
	var fade_time = 0.2
	
	if show_ui:
		dialogue_alignment.mouse_filter = Control.MOUSE_FILTER_PASS # Accept clicks
		fade_dialogue_tween.tween_property(dialogue_alignment, "modulate:a", 1.0, fade_time)
	else:
		dialogue_alignment.mouse_filter = Control.MOUSE_FILTER_IGNORE # Ignore clicks
		fade_dialogue_tween.tween_property(dialogue_alignment, "modulate:a", 0.0, fade_time)

func toggle_button_row(show_ui: bool) -> void:
	if fade_button_tween and fade_button_tween.is_valid():
		fade_button_tween.kill()
	fade_button_tween = create_tween()
	var fade_time = 0.2
	
	if show_ui:
		# Accept clicks
		timeline_button.mouse_filter = Control.MOUSE_FILTER_PASS
		next_button.mouse_filter = Control.MOUSE_FILTER_PASS
		hide_ui_button.mouse_filter = Control.MOUSE_FILTER_PASS
		fade_button_tween.tween_property(button_alignment, "modulate:a", 1.0, fade_time)
	else:
		# Ignore clicks
		timeline_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
		next_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
		hide_ui_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
		fade_button_tween.tween_property(button_alignment, "modulate:a", 0.0, fade_time)

func _on_hide_ui_button_pressed() -> void:
	_toggle_ui(false)

# Tapping anywhere on the screen brings the hidden UI back
func _input(event: InputEvent) -> void:
	if is_ui_hidden:
		# Detects a left-click on PC or a screen tap on Mobile
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_toggle_ui(true)
		# Detects standard accept actions (Spacebar, Enter, controller face button)
		elif event.is_action_pressed("ui_accept"):
			_toggle_ui(true)

func _toggle_ui(show_ui: bool) -> void:
	# Hide the text dialogue box and button row
	choice_alignment.visible = show_ui
	dialogue_alignment.visible = show_ui
	button_alignment.visible = show_ui
	is_ui_hidden = !show_ui


# --- UPDATE SPEAKER NAME ---
func _update_speaker(speaker: String, text_color: Color, bg_color: Color) -> void:
	speaker_name.text = speaker
	speaker_name.add_theme_color_override("default_color", text_color)
	
	# Duplicate and inject the color into the NamePanel
	var panel_style = name_panel.get_theme_stylebox("panel").duplicate()
	panel_style.bg_color = bg_color
	name_panel.add_theme_stylebox_override("panel", panel_style)
	
	# Duplicate and inject the color into your puzzle piece tab
	if tab_piece and tab_piece.has_theme_stylebox("panel"):
		var tab_style = tab_piece.get_theme_stylebox("panel").duplicate()
		tab_style.bg_color = bg_color
		tab_piece.add_theme_stylebox_override("panel", tab_style)


# --- UPDATE DIALOGUE & KEYWORDS ---
func _update_dialogue(text: String) -> void:
	dialogue_text.text = text
	dialogue_text.visible_ratio = 0.0
	
	# If a previous line is still typing, kill the old tween
	if text_tween and text_tween.is_valid():
		text_tween.kill()
	
	text_tween = create_tween()
	var duration = dialogue_text.get_total_character_count() * 0.03 # 0.03 seconds per character
	text_tween.tween_property(dialogue_text, "visible_ratio", 1.0, duration)

func _on_keyword_clicked(word: String) -> void:
	word_bank_popup.open_word_clicked(word)

func _on_next_button_pressed() -> void:
	# If text is typing, skip to the end of the sentence
	if text_tween and text_tween.is_running():
		text_tween.kill()
		dialogue_text.visible_ratio = 1.0
		return
	
	# Otherwise, load the next line
	_advance_line()

func _advance_line() -> void:
	current_index += 1
	if current_index < current_dialogues.size():
		_display_current_line()
	elif current_choices.size() > 0:
		_show_choices()
	else:
		dialogue_finished.emit()


# --- UPDATE CHOICES ---
func _clear_old_choices() -> void:
	# Delete all old choices EXCEPT hidden template
	for child in choice_alignment.get_children():
		if child != choice_template:
			child.queue_free()

func _show_choices() -> void:
	toggle_button_row(false)
	choice_alignment.show()
	
	for choice in current_choices:
		var new_choice = choice_template.duplicate()
		var label = new_choice.get_node("Padding/Label")
		label.text = choice["text"]
		new_choice.show()
		new_choice.gui_input.connect(_on_choice_gui_input.bind(choice["next_block"], choice["text"]))
		choice_alignment.add_child(new_choice)

func _on_choice_gui_input(event: InputEvent, target_block: String, choice_text: String) -> void:
	var is_tap = event is InputEventScreenTouch and event.pressed
	var is_click = event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed
	
	if is_tap or is_click:
		choice_alignment.hide()
		GameManager.add_to_history("Player", choice_text)
		choice_selected.emit(target_block)


# --- POPUPS ---
func _on_timeline_button_pressed() -> void:
	confirmation_popup.open_popup()

func _on_dictionary_button_pressed() -> void:
	word_bank_popup.open_popup()

func _on_history_button_pressed() -> void:
	history_popup.open_popup()
