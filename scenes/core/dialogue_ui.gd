extends MarginContainer

signal dialogue_finished

const CHAR_STYLES = {
	"Quinn": {"bg_color": Color("#F57A00"), "font_color": Color("#FFF5EB")},
	"Zach": {"bg_color": Color("#99CCFF"), "font_color": Color("#003D7A")},
	"Ella": {"bg_color": Color("#fd6969"), "font_color": Color("#7d2d16") },
	"Daniel": {"bg_color": Color("#428e2c"), "font_color": Color("#74c84f")},
	# A fallback for a narrator or an unknown speaker
	"System": {"bg_color": Color("#525252"), "font_color": Color("#F5F5F5")}
}

# --- SCENE TREE REFERENCES ---
@onready var main_stack: VBoxContainer = $MainStack
@onready var dialogue_alignment: VBoxContainer = $MainStack/BottomAlignment/DialogueAlignment
@onready var button_alignment: HBoxContainer = $MainStack/BottomAlignment/ButtonAlignment

# Speaker Nodes
@onready var name_panel: PanelContainer = $MainStack/BottomAlignment/DialogueAlignment/NameAlignment/NamePanel
@onready var speaker_name: RichTextLabel = $MainStack/BottomAlignment/DialogueAlignment/NameAlignment/NamePanel/SpeakerName
@onready var tab_piece: Control = $MainStack/BottomAlignment/DialogueAlignment/NameAlignment/TabAlignment/TabCircle

# Dialogue Nodes
@onready var dialogue_text: RichTextLabel = $MainStack/BottomAlignment/DialogueAlignment/TextPanel/Padding/Row/DialogueText
@onready var hide_ui_button: Button = $MainStack/BottomAlignment/ButtonAlignment/Row2/HideUIButton
@onready var next_button: Button = $MainStack/BottomAlignment/ButtonAlignment/Row1/NextButton

# State
var is_ui_hidden: bool = false
var current_index: int = 0

var current_dialogues: Array = []
var text_tween: Tween
var fade_tween: Tween

func _ready() -> void:
	# Enable BBCode to use bold text and URL keywords
	dialogue_text.bbcode_enabled = true
	
	# Connect Signals
	next_button.pressed.connect(_on_next_button_pressed)
	hide_ui_button.pressed.connect(_on_hide_ui_button_pressed)
	dialogue_text.meta_clicked.connect(_on_keyword_clicked)


# --- DIALOGUE LOGIC ---

func start_dialogue(dialogue_array: Array) -> void:
	toggle_dialogue_box(true)
	current_dialogues = dialogue_array
	current_index = 0
	_display_current_line()

func _display_current_line() -> void:
	var line_data = current_dialogues[current_index]
	var speaker = line_data["speaker"]
	var style = CHAR_STYLES.get(speaker, CHAR_STYLES["System"])
	_update_speaker(speaker, style["font_color"], style["bg_color"])
	_update_dialogue(line_data["text"])


# --- HIDE / SHOW UI LOGIC ---
func toggle_dialogue_box(show_ui: bool) -> void:
	if fade_tween and fade_tween.is_valid():
		fade_tween.kill()
	fade_tween = create_tween()
	var fade_time = 0.2
	
	if show_ui:
		dialogue_alignment.mouse_filter = Control.MOUSE_FILTER_PASS # Accept clicks
		fade_tween.tween_property(dialogue_alignment, "modulate:a", 1.0, fade_time)
	else:
		dialogue_alignment.mouse_filter = Control.MOUSE_FILTER_IGNORE # Ignore clicks
		fade_tween.tween_property(dialogue_alignment, "modulate:a", 0.0, fade_time)

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
	var duration = text.length() * 0.03 # 0.03 seconds per character
	text_tween.tween_property(dialogue_text, "visible_ratio", 1.0, duration)

func _on_keyword_clicked(meta_data) -> void:
	print("Keyword clicked! Loading dictionary entry for: ", meta_data)
	# TODO: Dictionary UI here based on the meta_data

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
	else:
		dialogue_finished.emit()
