extends Control

signal animation_finished

enum VisualType {
	STATIC_CG,
	ANIMATED_CG,
	DIALOGUE_CG
}

@onready var background: TextureRect = $Background
@onready var sprite_layer: Control = $SpriteLayer

var _current_visual_path: String = ""

func display_scene(type: VisualType, asset_path: String, sprite_data: Dictionary = {}) -> void:
	_current_visual_path = asset_path
	_clear_sprites()
	
	match type:
		VisualType.STATIC_CG:
			_show_static_cg(asset_path)
		VisualType.ANIMATED_CG:
			_show_animated_cg(asset_path)
		VisualType.DIALOGUE_CG:
			_show_dialogue_cg(asset_path, sprite_data)

func _clear_sprites() -> void:
	for child in sprite_layer.get_children():
		child.queue_free()

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
	
	animation_finished.emit()

func _show_dialogue_cg(bg_path: String, sprite_data: Dictionary) -> void:
	_show_static_cg(bg_path)

	var screen_size = get_viewport_rect().size
	
	for slot in sprite_data:
		var sprite_id = sprite_data[slot]
		var sprite_path = AssetRegistry.get_sprite_path(sprite_id)
		
		var frames = load(sprite_path) as SpriteFrames
		if not frames:
			push_error("Visual Layer: Could not load SpriteFrames at " + sprite_path)
			continue
			
		# Create a new sprite node
		var sprite_node = AnimatedSprite2D.new()
		sprite_node.sprite_frames = frames
		sprite_layer.add_child(sprite_node)
		
		# Calculate the horizontal position
		var x_pos = screen_size.x / 2.0 # Default to center
		if slot == "left":
			x_pos = screen_size.x * 0.25
		elif slot == "right":
			x_pos = screen_size.x * 0.75
			
		# Position the sprite at the bottom of the screen
		sprite_node.position = Vector2(x_pos, screen_size.y)
		
		# By default, Godot centers sprites perfectly on their position. 
		# If we put it at the bottom of the screen, half its legs will clip through the floor.
		# We grab the image height and push the offset UP by half the height so they stand perfectly on the bottom.
		var tex_size = frames.get_frame_texture("default", 0).get_size()
		sprite_node.offset = Vector2(0, -tex_size.y / 2.0)
		
		# Play the loop
		sprite_node.play("default")
