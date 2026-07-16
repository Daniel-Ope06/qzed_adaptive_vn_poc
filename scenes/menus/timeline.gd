extends ScrollContainer

const STORY_NODE = preload("res://scenes/components/story_node.tscn")

@onready var flow_layout: HBoxContainer = $MarginContainer/FlowLayout
@onready var line_canvas: Control = $MarginContainer/LineCanvas

const COLOR_LINE_ACTIVE = Color("#0070E0") # Blue
const COLOR_LINE_INACTIVE = Color("#D6D6D6") # Grey

var flowchart_data = [
	{
		"type": "single",
		"title": "Prologue",
		"image": "res://assets/cgs/cg_ch3_prism_dispersion.png",
		"state": StoryNode.NodeState.COMPLETED
	},
	{
		"type": "single",
		"title": "Prologue",
		"image": "res://assets/cgs/cg_ch3_prism_dispersion.png",
		"state": StoryNode.NodeState.COMPLETED
	},
	{
		"type": "split",
		"nodes": [
			{
				"title": "Story 1", 
				"image": "res://assets/cgs/cg_ch3_prism_dispersion.png",
				"state": StoryNode.NodeState.UNLOCKED
			},
			{
				"title": "Story 2", 
				"image": "res://assets/cgs/cg_ch3_prism_dispersion.png",
				"state": StoryNode.NodeState.LOCKED
			},
			{
				"title": "Story 3", 
				"image": "res://assets/cgs/cg_ch3_prism_dispersion.png",
				"state": StoryNode.NodeState.COMPLETED
			}
		]
	},
	{
		"type": "single",
		"title": "Prologue",
		"image": "res://assets/cgs/cg_ch3_prism_dispersion.png",
		"state": StoryNode.NodeState.LOCKED
	},
]

var tracked_steps: Array = []

func _ready() -> void:
	build_timeline()
	await get_tree().process_frame # wait for build_timeline() to complete
	draw_connections()

func build_timeline() -> void:
	for step in flowchart_data:
		var step_nodes: Array = []
		
		if step["type"] == "single":
			var image = load(step["image"]) as Texture2D
			var node = create_story_node(flow_layout, step["title"], image, step["state"])
			node.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			step_nodes.append(node)
		
		elif step["type"] == "split":
			var column = VBoxContainer.new()
			column.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			column.add_theme_constant_override("separation", 64)
			flow_layout.add_child(column)
			
			for sub_step in step["nodes"]:
				var image = load(sub_step["image"]) as Texture2D
				var node = create_story_node(column, sub_step["title"], image, sub_step["state"])
				step_nodes.append(node)
		
		tracked_steps.append(step_nodes)

func create_story_node(parent_container: Control,node_title: String, node_image: Texture2D, node_state: StoryNode.NodeState) -> StoryNode:
	var new_node = STORY_NODE.instantiate()
	parent_container.add_child(new_node)
	new_node.setup_node(node_title, node_image, node_state) 
	return new_node

func draw_connections() -> void:
	var paths_to_draw: Array = []
	
	for i in range(tracked_steps.size() - 1):
		var current_nodes: Array = tracked_steps[i]
		var next_nodes: Array = tracked_steps[i+1]
		
		# RELATIONSHIP 1: 1-to-1 (Single to Single)
		if current_nodes.size() == 1 and next_nodes.size() == 1:
			var start = get_node_right_center(current_nodes[0])
			var end = get_node_left_center(next_nodes[0])
			var is_active = (next_nodes[0].current_state != StoryNode.NodeState.LOCKED)
			
			paths_to_draw.append({
				"start": start, "end": end, 
				"is_active": is_active, "type": "straight"
			})
		
		# RELATIONSHIP 2: 1-to-3 (Single to Split)
		elif current_nodes.size() == 1 and next_nodes.size() > 1:
			var start = get_node_right_center(current_nodes[0])
			for target_node in next_nodes:
				var end = get_node_left_center(target_node)
				var is_active = (target_node.current_state != StoryNode.NodeState.LOCKED)
				paths_to_draw.append({
					"start": start, "end": end, 
					"is_active": is_active, "type": "fork"
				})
		
		# RELATIONSHIP 3: 3-to-1 (Split to Single)
		elif current_nodes.size() > 1 and next_nodes.size() == 1:
			var end = get_node_left_center(next_nodes[0])
			var is_active = (next_nodes[0].current_state != StoryNode.NodeState.LOCKED)
			for origin_node in current_nodes:
				var start = get_node_right_center(origin_node)
				
				paths_to_draw.append({
					"start": start, "end": end, 
					"is_active": is_active, "type": "fork"
				})
	
	# Draw every INACTIVE (Grey) line at the bottom layer
	for path in paths_to_draw:
		if not path["is_active"]:
			draw_specific_path(path)
	
	# Draw every ACTIVE (Blue) line on top
	for path in paths_to_draw:
		if path["is_active"]:
			draw_specific_path(path)


# -- HELPER FUNCTIONS --

func get_node_right_center(node: Control) -> Vector2:
	var pos = node.global_position - line_canvas.global_position
	return pos + Vector2(node.size.x, node.size.y / 2.0)

func get_node_left_center(node: Control) -> Vector2:
	var pos = node.global_position - line_canvas.global_position
	return pos + Vector2(0, node.size.y / 2.0)

func draw_specific_path(path: Dictionary) -> void:
	var start: Vector2 = path["start"]
	var end: Vector2 = path["end"]
	var is_active: bool = path["is_active"]
	
	var line = Line2D.new()
	line_canvas.add_child(line)
	
	line.width = 2
	line.default_color = COLOR_LINE_ACTIVE if is_active else COLOR_LINE_INACTIVE
	line.joint_mode = Line2D.LINE_JOINT_ROUND
	line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	line.end_cap_mode = Line2D.LINE_CAP_ROUND
	
	if path["type"] == "straight":
		# A straight line with an arrowhead
		line.add_point(start)
		line.add_point(end)
		add_arrow_head(end, start, line.default_color)
		
	elif path["type"] == "fork":
		# An orthogonal 4-point routing with no arrowhead
		var mid_x = (start.x + end.x) / 2.0
		line.add_point(start)
		line.add_point(Vector2(mid_x, start.y))
		line.add_point(Vector2(mid_x, end.y))
		line.add_point(end)

func add_arrow_head(at_position: Vector2, look_back_at: Vector2, head_color: Color) -> void:
	var arrow = Polygon2D.new()
	line_canvas.add_child(arrow)
	
	arrow.color = head_color
	
	# Calculate directional vectors to rotate the arrowhead perfectly
	var direction = (at_position - look_back_at).normalized()
	var perpendicular = Vector2(-direction.y, direction.x)
	
	# Dimensions of the arrow head
	var arrow_length = 16
	var arrow_width = 16
	
	# Create three points of a triangle pointing precisely right
	var tip = at_position
	var base_left = at_position - (direction * arrow_length) + (perpendicular * (arrow_width / 2.0))
	var base_right = at_position - (direction * arrow_length) - (perpendicular * (arrow_width / 2.0))
	
	arrow.polygon = PackedVector2Array([tip, base_left, base_right])
