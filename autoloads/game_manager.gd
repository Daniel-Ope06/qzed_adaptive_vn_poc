extends Node

const CHAR_STYLES = {
	"Quinn": {"bg_color": Color("#F57A00"), "font_color": Color("#FFF5EB")},
	"Zach": {"bg_color": Color("#99CCFF"), "font_color": Color("#003D7A")},
	"Ella": {"bg_color": Color("#fd6969"), "font_color": Color("#7d2d16") },
	"Daniel": {"bg_color": Color("#428e2c"), "font_color": Color("#74c84f")},
	# A fallback for a narrator or an unknown speaker
	"System": {"bg_color": Color("#525252"), "font_color": Color("#F5F5F5")}
}

var current_story_id: String = ""

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
