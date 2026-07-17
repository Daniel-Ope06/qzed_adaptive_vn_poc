extends MarginContainer
class_name ChapterNode

enum NodeState { LOCKED, UNLOCKED}

const COLOR_LOCKED: Color = Color("#D6D6D6") # Gray
const COLOR_UNLOCKED: Color = Color("#0070E0") # Blue

@onready var title: Label = $VBoxContainer/Title
@onready var subtitle: Label = $VBoxContainer/Subtitle
@onready var vbox: VBoxContainer = $VBoxContainer

var current_state: NodeState = NodeState.LOCKED

func setup_node(chapter_title: String, chapter_subtitle: String, state: NodeState = NodeState.LOCKED) -> void:
	title.text = chapter_title
	subtitle.text = chapter_subtitle
	set_state(state)

func set_state(new_state: NodeState) -> void:
	current_state = new_state
	
	match current_state:
		NodeState.LOCKED:
			title.add_theme_color_override("font_color", COLOR_LOCKED)
			subtitle.add_theme_color_override("font_color", COLOR_LOCKED)
		
		NodeState.UNLOCKED:
			title.add_theme_color_override("font_color", COLOR_UNLOCKED)
			subtitle.add_theme_color_override("font_color", Color("#9ca3af"))

func is_active_path() -> bool:
	return current_state != NodeState.LOCKED
