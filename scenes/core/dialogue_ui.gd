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


# --- HIDE / SHOW UI LOGIC ---
func _on_hide_ui_button_pressed() -> void:
	_toggle_ui(false)

# In visual novels, tapping anywhere on the screen brings the hidden UI back
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
