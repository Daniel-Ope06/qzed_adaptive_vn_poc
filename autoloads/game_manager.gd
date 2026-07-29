extends Node

const CHAR_STYLES = {
	"Quinn": {"bg_color": Color("#F57A00"), "font_color": Color("#FFF5EB")},
	"Zach": {"bg_color": Color("#99CCFF"), "font_color": Color("#003D7A")},
	"Ella": {"bg_color": Color("#fd6969"), "font_color": Color("#7d2d16") },
	"Daniel": {"bg_color": Color("#428e2c"), "font_color": Color("#74c84f")},
	# A fallback for a narrator or an unknown speaker
	"System": {"bg_color": Color("#525252"), "font_color": Color("#F5F5F5")}
}

const CHAR_STYLES_2 = {
	"Quinn": {"bg_color": Color("#FFF5EB"), "font_color": Color("#FF7F00"), "border_color": Color("#FFE0C2")},
	"Zach": {"bg_color": Color("#EAF4FF"), "font_color": Color("#003D7A"), "border_color": Color("#9CC7FF")},
	"Ella": {"bg_color": Color("ffe1dec8"), "font_color": Color("#fd6969"), "border_color": Color("feb1acc8")},
	"Daniel": {"bg_color": Color("#74c84f"), "font_color": Color("#428e2c"), "border_color": Color("#428e2c")},
	# A fallback for a narrator or an unknown speaker
	"System": {"bg_color": Color("#F5F5F5"), "font_color": Color("#525252"), "border_color": Color("b8b8b8c8")}
}

var current_story_id: String = ""

var current_history: Array[Dictionary] = []
var url_regex: RegEx = RegEx.new()

func _init() -> void:
	# Compile the regex pattern once when the game boots.
	# This pattern looks for [url="..."] and [/url]
	url_regex.compile("\\[/?url.*?\\]")

func add_to_history(speaker_name: String, dialogue_text: String) -> void:
	var clean_text = url_regex.sub(dialogue_text, "", true)
	clean_text = clean_text.replace(".png", "_gray.png")
	var entry = {
		"speaker": speaker_name,
		"text": clean_text
	}
	current_history.append(entry)

var flowchart_data: Array[Dictionary] = [
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
		"subtitle": "Dispersion",
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
		"type": "story",
		"story_id": "",
		"title": "Epilogue",
		"image": "res://assets/cgs/cg_ch3_prism_dispersion.png",
		"state": StoryNode.NodeState.LOCKED
	},
]
