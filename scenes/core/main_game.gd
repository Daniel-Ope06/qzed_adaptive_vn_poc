extends Control

@onready var visual_layer: Control = $VisualLayer
@onready var dialogue_ui = $UILayer/DialogueUI

var story_data: Dictionary = {}
var current_block: Dictionary = {}
var waiting_for_next_click: bool = false

func _ready() -> void:
	dialogue_ui.dialogue_finished.connect(_on_dialogue_finished)
	dialogue_ui.choice_selected.connect(_on_choice_selected)
	
	var active_story_id = GameManager.current_story_id
	if active_story_id == "":
		push_error("Main Game: Launched without a valid story ID")
		return
	
	var file_path = "res://data/story/%s.json" % active_story_id
	if not FileAccess.file_exists(file_path):
		push_error("Main Game: Story file not found at " + file_path)
		return
	
	var file_text = FileAccess.get_file_as_string(file_path)
	story_data = JSON.parse_string(file_text)
	play_block("scene_1")

func play_block(block_id: String) -> void:
	if block_id == "stop":
		return
	
	current_block = story_data["blocks"][block_id]
	dialogue_ui.toggle_dialogue_box(false) # Hide dialogue box
	waiting_for_next_click = false
	
	var cg_type = current_block["type"]
	var bg_id = current_block["background"]
	var asset_path = AssetRegistry.get_cg_path(bg_id)
	
	if cg_type == "static_cg":
		visual_layer.display_scene(visual_layer.VisualType.STATIC_CG, asset_path)
	elif cg_type == "animated_cg":
		visual_layer.display_scene(visual_layer.VisualType.ANIMATED_CG, asset_path)
		await visual_layer.animation_finished
	elif cg_type == "dialogue_cg":
		var sprite_slots = current_block.get("sprites", {})
		visual_layer.display_scene(visual_layer.VisualType.DIALOGUE_CG, asset_path, sprite_slots)
	
	var dialogue: Array = current_block.get("dialogue", [])
	var choices: Array = current_block.get("choices", [])
	
	if dialogue.size() > 0:
		dialogue_ui.start_dialogue(dialogue, choices)
	else:
		waiting_for_next_click = true

func _on_dialogue_finished() -> void:
	play_block(current_block["next_block"])

func _on_choice_selected(target_block: String) -> void:
	play_block(target_block)
