extends Control

const CHAR_STYLES = {
	"Quinn": {
		"bg_color": Color("#F57A00"), 
		"font_color": Color("#FFF5EB")
	},
	"Zach": {
		"bg_color": Color("#99CCFF"), 
		"font_color": Color("#003D7A")
	},
	"Ella": {
		"bg_color": Color("#fd6969"), 
		"font_color": Color("#7d2d16")
	},
	"Daniel": {
		"bg_color": Color("#428e2c"), 
		"font_color": Color("#74c84f")
	},
	# A fallback for a narrator or an unknown speaker
	"System": {
		"bg_color": Color("#525252"),
		"font_color": Color("#F5F5F5")
	}
}

@onready var visual_layer: Control = $VisualLayer
@onready var dialogue_ui = $UILayer/DialogueUI


func _ready() -> void:
	pass
