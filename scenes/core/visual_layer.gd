extends Control

enum VisualType {
	EVENT_CG,
	STANDARD_DIALOGUE,
	PANORAMIC_CG
}

@onready var background: TextureRect = $Background

func display_scene(type: VisualType, asset_path: String) -> void:
	match type:
		VisualType.EVENT_CG:
			_show_event_cg(asset_path)
		VisualType.STANDARD_DIALOGUE:
			pass # Add sprite handling here next
		VisualType.PANORAMIC_CG:
			pass # Add the Camera2D pan logic here later

func _show_event_cg(cg_path: String) -> void:
	# Load the full-color illustration
	var texture = load(cg_path)
	if texture:
		background.texture = texture
	else:
		push_error("Visual Layer: Could not load Event CG at " + cg_path)
	
	# Ensure the image is static and centered
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	
	# Reset any Panoramic camera movement (to be implemented)
	# $Camera2D.position = Vector2.ZERO
	
	# Hide character sprites, as Event CGs are unified shots (to be implemented)
	# $SpriteContainer.hide()
