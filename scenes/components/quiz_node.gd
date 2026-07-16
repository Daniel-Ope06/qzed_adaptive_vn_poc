extends MarginContainer
class_name QuizNode

enum NodeState { LOCKED, UNLOCKED}

const COLOR_LOCKED: Color = Color("#D6D6D6") # Gray
const COLOR_UNLOCKED: Color = Color("#FFA347") # Orange

@onready var diamond_canvas: Control = $DiamondCanvas
@onready var quiz_title: Label = $TitleBox/Title

var node_title: String = ""
var current_state: NodeState = NodeState.LOCKED

func _ready() -> void:
	diamond_canvas.draw.connect(_on_canvas_draw)

func setup_node(title: String, state: NodeState = NodeState.UNLOCKED) -> void:
	node_title = title
	quiz_title.text = title
	set_state(state)

func set_state(new_state: NodeState) -> void:
	current_state = new_state
	
	match current_state:
		NodeState.LOCKED:
			quiz_title.add_theme_color_override("font_color", COLOR_LOCKED)
		NodeState.UNLOCKED:
			quiz_title.add_theme_color_override("font_color", Color("#0A0A0A"))
	
	diamond_canvas.queue_redraw()

func is_active_path() -> bool:
	return current_state != NodeState.LOCKED

# Drawing Diamond
func _on_canvas_draw() -> void:
	var w = diamond_canvas.size.x
	var h = diamond_canvas.size.y
	
	# Calculate the 4 points of the diamond based on the available bounding box
	var points = PackedVector2Array([
		Vector2(w / 2.0, 0),   # Top Tip
		Vector2(w, h / 2.0),   # Right Tip
		Vector2(w / 2.0, h),   # Bottom Tip
		Vector2(0, h / 2.0),   # Left Tip
		Vector2(w / 2.0, 0)    # Closing point
	])
	
	# Fill the inside to cover background lines
	diamond_canvas.draw_polygon(points, PackedColorArray([Color("#F9FBFD") if current_state == NodeState.LOCKED else Color.WHITE]))
	
	# Draw the outer border line
	var current_border_color = COLOR_LOCKED if current_state == NodeState.LOCKED else COLOR_UNLOCKED
	diamond_canvas.draw_polyline(points, current_border_color, 4, true)
