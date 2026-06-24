extends Control

@onready var visual_layer: Control = $VisualLayer

func _ready() -> void:
	# For testing purposes, use dispersion event cg.
	var test_asset_path: String = "res://assets/cgs/cg_ch3_prism_dispersion.jpeg"
	visual_layer.display_scene(visual_layer.VisualType.EVENT_CG, test_asset_path)
