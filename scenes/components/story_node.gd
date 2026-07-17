extends PanelContainer
class_name StoryNode

signal node_selected(id: String)

enum NodeState { LOCKED, UNLOCKED, COMPLETED }

const ICON_LOCK = preload("res://assets/ui_icons/icon_tl_lock.png")
const ICON_CHECK = preload("res://assets/ui_icons/icon_tl_check.png")
const COLOR_LOCKED: Color = Color("#D6D6D6") # Gray
const COLOR_UNLOCKED: Color = Color("#0070E0") # Blue

@onready var node_image: TextureRect = $ImageMask/Background
@onready var node_icon: TextureRect = $StateIcon
@onready var node_title: Label = $TitleBox/Title

var current_state: NodeState = NodeState.LOCKED
var panel_style: StyleBoxFlat
var node_id: String

func _ready() -> void:
	panel_style = get_theme_stylebox("panel").duplicate()
	add_theme_stylebox_override("panel", panel_style)

func setup_node(story_id: String, title: String, image: Texture2D, state: NodeState = NodeState.LOCKED) -> void:
	node_id = story_id
	node_title.text = title
	node_image.texture = image
	set_state(state)

func set_state(new_state: NodeState) -> void:
	current_state = new_state
	
	match current_state:
		NodeState.LOCKED:
			node_icon.texture = ICON_LOCK
			node_icon.show()
			node_image.modulate.a = 0.4
			panel_style.border_color = COLOR_LOCKED
			
		NodeState.UNLOCKED:
			node_icon.hide()
			node_image.modulate.a = 1
			panel_style.border_color = COLOR_UNLOCKED
			
		NodeState.COMPLETED:
			node_icon.texture = ICON_CHECK
			node_icon.show()
			node_image.modulate.a = 0.8
			panel_style.border_color = COLOR_UNLOCKED

func is_active_path() -> bool:
	return current_state != NodeState.LOCKED

func _gui_input(event: InputEvent) -> void:
	if current_state == NodeState.LOCKED:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		node_selected.emit(node_id)
