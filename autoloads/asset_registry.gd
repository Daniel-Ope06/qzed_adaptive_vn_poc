extends Node

const CG_REGISTRY: Dictionary = {
	# Chapter 1
	"quinn_trapped": "res://assets/cg_static/quinn_trapped.webp",
	"ella_in_cockpit": "res://assets/cg_static/ella_in_cockpit.webp",
	"split_ella_in_cockpit_to_quinn_trapped": "res://assets/cg_animated/split_ella_in_cockpit_to_quinn_trapped.tres",
	"spaceship_hallway": "res://assets/cg_static/spaceship_hallway.webp",
	"spaceship_hallway_light": "res://assets/cg_static/spaceship_hallway_light.webp",
	"reflection_explained_gray": "res://assets/cg_static/reflection_explained_gray.webp",
	"reflection_explained_color": "res://assets/cg_static/reflection_explained_color.webp",
}

const SPRITE_REGISTRY: Dictionary = {
	# Chapter 1
	"ella_space_explaining": "res://assets/sprite_animated/ella_space_explaining.tres"
}

func get_cg_path(asset_id: String) -> String:
	if CG_REGISTRY.has(asset_id):
		return CG_REGISTRY[asset_id]
	else:
		push_error("Asset Registry: Could not find asset ID -> " + asset_id)
		return ""

func get_sprite_path(asset_id: String) -> String:
	if SPRITE_REGISTRY.has(asset_id):
		return SPRITE_REGISTRY[asset_id]
	else:
		push_error("Asset Registry: Could not find asset ID -> " + asset_id)
		return ""
