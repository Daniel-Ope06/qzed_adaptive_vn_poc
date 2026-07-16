extends MarginContainer
class_name ChapterNode

enum NodeState { LOCKED, UNLOCKED}

const COLOR_LOCKED: Color = Color("#D6D6D6") # Gray
const COLOR_UNLOCKED: Color = Color("#0070E0") # Blue

@onready var number: Label = $VBoxContainer/Number
@onready var title: Label = $VBoxContainer/Title
@onready var vbox: VBoxContainer = $VBoxContainer

var current_state: NodeState = NodeState.LOCKED

func setup_node(chapter_number: int, chapter_title: String, state: NodeState = NodeState.LOCKED) -> void:
	number.text = "CHAPTER " + str(chapter_number)
	title.text = chapter_title
	set_state(state)

func set_state(new_state: NodeState) -> void:
	current_state = new_state
	
	match current_state:
		NodeState.LOCKED:
			number.add_theme_color_override("font_color", COLOR_LOCKED)
			title.add_theme_color_override("font_color", COLOR_LOCKED)
		
		NodeState.UNLOCKED:
			number.add_theme_color_override("font_color", COLOR_UNLOCKED)
			title.add_theme_color_override("font_color", Color("#9ca3af"))

func is_active_path() -> bool:
	return current_state != NodeState.LOCKED
