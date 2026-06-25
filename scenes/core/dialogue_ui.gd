extends MarginContainer

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

# State
var is_ui_hidden: bool = false


func _ready() -> void:
	# Enable BBCode to use bold text and URL keywords
	dialogue_text.bbcode_enabled = true
	
	# Connect Signals
	hide_ui_button.pressed.connect(_on_hide_ui_button_pressed)
	dialogue_text.meta_clicked.connect(_on_keyword_clicked)


# --- HIDE / SHOW UI LOGIC ---
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

func _toggle_ui(is_visible: bool) -> void:
	# Hide the text dialogue box and button row
	dialogue_alignment.visible = is_visible
	button_alignment.visible = is_visible
	is_ui_hidden = !is_visible


# --- UPDATE SPEAKER NAME ---
func update_speaker(speaker: String, text_color: Color, bg_color: Color) -> void:
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
func update_dialogue(text: String) -> void:
	dialogue_text.text = text

func _on_keyword_clicked(meta_data) -> void:
	print("Keyword clicked! Loading dictionary entry for: ", meta_data)
	# TODO: Dictionary UI here based on the meta_data
