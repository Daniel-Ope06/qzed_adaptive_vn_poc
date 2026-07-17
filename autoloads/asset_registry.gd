extends Node

const CG_REGISTRY: Dictionary = {
	"quinn_trapped": "res://assets/cg_static/quinn_trapped.webp",
	"ella_in_cockpit": "res://assets/cg_static/ella_in_cockpit.webp",
	"split_ella_in_cockpit_to_quinn_trapped": "res://assets/cg_animated/split_ella_in_cockpit_to_quinn_trapped.tres"
}

func get_cg_path(asset_id: String) -> String:
	if CG_REGISTRY.has(asset_id):
		return CG_REGISTRY[asset_id]
	else:
		push_error("Asset Registry: Could not find asset ID -> " + asset_id)
		return ""
