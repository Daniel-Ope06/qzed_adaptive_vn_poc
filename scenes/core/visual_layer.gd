extends Control

enum VisualType {
	STATIC_CG,
	ANIMATED_CG,
	DIALOGUE_CG
}

@onready var background: TextureRect = $Background

func display_scene(type: VisualType, asset_path: String) -> void:
	match type:
		VisualType.STATIC_CG:
			_show_static_cg(asset_path)
		VisualType.ANIMATED_CG:
			pass 
		VisualType.DIALOGUE_CG:
			pass # Add sprite handling

func _show_static_cg(cg_path: String) -> void:
	# Load the full-color illustration
	var texture = load(cg_path)
	if texture:
		background.texture = texture
	else:
		push_error("Visual Layer: Could not load Event CG at " + cg_path)
	# Ensure the image is static and centered
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
