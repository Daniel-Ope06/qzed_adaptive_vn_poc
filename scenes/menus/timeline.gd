extends ScrollContainer

const STORY_NODE = preload("res://scenes/components/story_node.tscn")
const QUIZ_NODE = preload("res://scenes/components/quiz_node.tscn")
const CHAPTER_NODE = preload("res://scenes/components/chapter_node.tscn")

@onready var flow_layout: HBoxContainer = $MarginContainer/FlowLayout
@onready var line_canvas: Control = $MarginContainer/LineCanvas

const COLOR_LINE_ACTIVE = Color("#0070E0") # Blue
const COLOR_LINE_INACTIVE = Color("#D6D6D6") # Grey

var flowchart_data = [
	{
		"size": "one",
		"type": "story",
		"story_id": "",
		"title": "Prologue",
		"image": "res://assets/cgs/cg_ch3_prism_dispersion.png",
		"state": StoryNode.NodeState.LOCKED
	},
	{
		"size": "one",
		"type": "chapter",
		"title": "THE RESCUE",
		"subtitle": "Reflection & Refraction",
		"state": ChapterNode.NodeState.UNLOCKED
	},
	{
		"size": "many",
		"nodes": [
			{
				"type": "story",
				"story_id": "chapter_1a",
				"title": "Chapter 1A", 
				"image": "res://assets/cg_static/quinn_trapped.webp",
				"state": StoryNode.NodeState.UNLOCKED
			},
			{
				"type": "story",
				"story_id": "",
				"title": "Chapter 1B", 
				"image": "res://assets/cgs/cg_ch3_prism_dispersion.png",
				"state": StoryNode.NodeState.LOCKED
			}
		]
	},
	{
		"size": "one",
		"type": "quiz",
		"title": "Q1",
		"state": QuizNode.NodeState.LOCKED
	},
	{
		"size": "one",
		"type": "chapter",
		"title": "CHAPTER 2",
		"subtitle": "Total Internal Reflection",
		"state": ChapterNode.NodeState.LOCKED
	},
	{
		"size": "many",
		"nodes": [
			{
				"type": "story",
				"story_id": "",
				"title": "Chapter 2A", 
				"image": "res://assets/cgs/cg_ch3_prism_dispersion.png",
				"state": StoryNode.NodeState.LOCKED
			},
			{
				"type": "story",
				"story_id": "",
				"title": "Chapter 2B", 
				"image": "res://assets/cgs/cg_ch3_prism_dispersion.png",
				"state": StoryNode.NodeState.LOCKED
			}
		]
	},
	{
		"size": "one",
		"type": "quiz",
		"title": "Q2",
		"state": QuizNode.NodeState.LOCKED
	},
	{
		"size": "one",
		"type": "chapter",
		"title": "CHAPTER 3",
		"subtitle": "Dispersion",
		"state": ChapterNode.NodeState.LOCKED
	},
	{
		"size": "many",
		"nodes": [
			{
				"type": "story",
				"story_id": "",
				"title": "Chapter 3A", 
				"image": "res://assets/cgs/cg_ch3_prism_dispersion.png",
				"state": StoryNode.NodeState.LOCKED
			},
			{
				"type": "story",
				"story_id": "",
				"title": "Chapter 3B", 
				"image": "res://assets/cgs/cg_ch3_prism_dispersion.png",
				"state": StoryNode.NodeState.LOCKED
			}
		]
	},
	{
		"size": "one",
		"type": "quiz",
		"title": "Q3",
		"state": QuizNode.NodeState.LOCKED
	},
	{
		"size": "one",
		"type": "story",
		"story_id": "",
		"title": "Epilogue",
		"image": "res://assets/cgs/cg_ch3_prism_dispersion.png",
		"state": StoryNode.NodeState.LOCKED
	},
]

var tracked_nodes: Array = []

func _ready() -> void:
	build_timeline()
	await get_tree().process_frame # wait for build_timeline() to complete
	draw_connections()

func build_timeline() -> void:
	for entity in flowchart_data:
		var entity_nodes: Array = []
		
		if entity["size"] == "one":
			var node = instantiate_by_type(flow_layout, entity)
			node.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			entity_nodes.append(node)
		
		elif entity["size"] == "many":
			var column = VBoxContainer.new()
			column.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			column.add_theme_constant_override("separation", 64)
			flow_layout.add_child(column)
			
			for sub_entity in entity["nodes"]:
				var node = instantiate_by_type(column, sub_entity)
				entity_nodes.append(node)
		
		tracked_nodes.append(entity_nodes)

func instantiate_by_type(parent: Control, data: Dictionary) -> Control:
	var node_type = data.get("type")
	
	if node_type == "story":
		var new_story = STORY_NODE.instantiate()
		parent.add_child(new_story)
		var image = load(data["image"]) as Texture2D
		new_story.setup_node(data["story_id"], data["title"], image, data["state"])
		return new_story
	
	elif node_type == "quiz":
		var new_quiz = QUIZ_NODE.instantiate()
		parent.add_child(new_quiz)
		new_quiz.setup_node(data["title"], data["state"])
		return new_quiz
	
	else: # if "chapter"
		var new_chapter = CHAPTER_NODE.instantiate()
		parent.add_child(new_chapter)
		new_chapter.setup_node(data["title"], data["subtitle"], data["state"])
		return new_chapter

func draw_connections() -> void:
	var paths_to_draw: Array = []
	
	for i in range(tracked_nodes.size() - 1):
		var current_nodes: Array = tracked_nodes[i]
		var next_nodes: Array = tracked_nodes[i+1]
		
		# RELATIONSHIP 1: one to one
		if current_nodes.size() == 1 and next_nodes.size() == 1:
			var start = get_node_right_center(current_nodes[0])
			var end = get_node_left_center(next_nodes[0])
			var is_active = next_nodes[0].is_active_path()
			
			paths_to_draw.append({
				"start": start, "end": end, 
				"is_active": is_active, "connection": "straight"
			})
		
		# RELATIONSHIP 2: one to many
		elif current_nodes.size() == 1 and next_nodes.size() > 1:
			var start = get_node_right_center(current_nodes[0])
			for target_node in next_nodes:
				var end = get_node_left_center(target_node)
				var is_active = target_node.is_active_path()
				paths_to_draw.append({
					"start": start, "end": end, 
					"is_active": is_active, "connection": "fork"
				})
		
		# RELATIONSHIP 3: many to one
		elif current_nodes.size() > 1 and next_nodes.size() == 1:
			var end = get_node_left_center(next_nodes[0])
			for origin_node in current_nodes:
				var start = get_node_right_center(origin_node)
				var is_active = origin_node.is_active_path() and next_nodes[0].is_active_path()
				
				paths_to_draw.append({
					"start": start, "end": end, 
					"is_active": is_active, "connection": "fork"
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
	
	if path["connection"] == "straight":
		# A straight line with an arrowhead
		line.add_point(start)
		line.add_point(end)
		add_arrow_head(end, start, line.default_color)
		
	elif path["connection"] == "fork":
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
