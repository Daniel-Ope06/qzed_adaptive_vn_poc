extends Control

enum VisualType {
	STATIC_CG,
	ANIMATED_CG,
	DIALOGUE_CG
}

@onready var background: TextureRect = $Background

var _current_visual_path: String = ""

func display_scene(type: VisualType, asset_path: String) -> void:
	_current_visual_path = asset_path
	
	match type:
		VisualType.STATIC_CG:
			_show_static_cg(asset_path)
		VisualType.ANIMATED_CG:
			_show_animated_cg(asset_path)
		VisualType.DIALOGUE_CG:
			pass # Add sprite handling

func _show_static_cg(cg_path: String) -> void:
	var texture = load(cg_path)
	
	if not texture:
		push_error("Visual Layer: Could not load Event CG at " + cg_path)
		return
	
	background.texture = texture
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED

func _show_animated_cg(cg_path: String) -> void:
	var frames = load(cg_path) as SpriteFrames
	
	if not frames:
		push_error("Visual Layer: Asset is not a SpriteFrames resource at " + cg_path)
		return
	
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	
	var anim_name = "default" 
	var frame_count = frames.get_frame_count(anim_name)
	var fps = frames.get_animation_speed(anim_name)
	var frame_delay = 1.0 / fps
	
	# Play animation
	for i in range(frame_count):
		# Safety break: Stop if the player clicked 'Next'
		if _current_visual_path != cg_path:
			break 
		
		background.texture = frames.get_frame_texture(anim_name, i)
		
		# Wait for the next frame (unless it is the final frame)
		if i < frame_count - 1:
			await get_tree().create_timer(frame_delay).timeout
