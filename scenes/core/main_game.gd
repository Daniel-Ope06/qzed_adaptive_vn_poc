extends Control

@onready var visual_layer: Control = $VisualLayer
@onready var dialogue_ui: Control = $UILayer/DialogueUI
@onready var word_bank: Control = $UILayer/DialogueUI/OverlayLayer/WordBankPopup

var story_data: Dictionary = {}
var dict_data: Dictionary = {}
var current_block: Dictionary = {}
var waiting_for_next_click: bool = false

func _ready() -> void:
	dialogue_ui.dialogue_finished.connect(_on_dialogue_finished)
	dialogue_ui.choice_selected.connect(_on_choice_selected)
	
	var active_story_id = GameManager.current_story_id
	if active_story_id == "":
		push_error("Main Game: Launched without a valid story ID")
		return
	
	var story_path = "res://data/story/%s.json" % active_story_id
	var dict_path = "res://data/dictionary/%s_dict.json" % active_story_id
	
	if not (FileAccess.file_exists(story_path) or FileAccess.file_exists(dict_path)):
		push_error("Story file(s) not found")
		return
	
	var story_text = FileAccess.get_file_as_string(story_path)
	var dict_text = FileAccess.get_file_as_string(dict_path)
	
	story_data = JSON.parse_string(story_text)
	dict_data = JSON.parse_string(dict_text)
	
	play_block("scene_1")
	word_bank.setup_word_list(dict_data["concepts"])

func play_block(block_id: String) -> void:
	if block_id == "stop":
		GameManager.flowchart_data[2]["nodes"][0]["state"] = StoryNode.NodeState.COMPLETED
		get_tree().change_scene_to_file("res://scenes/menus/timeline.tscn")
	
	current_block = story_data["blocks"][block_id]
	dialogue_ui.toggle_dialogue_box(false) # Hide dialogue box
	dialogue_ui.toggle_button_row(false) # Hide buttons
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
