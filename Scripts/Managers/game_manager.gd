extends Node2D

@onready var debugs = get_tree().get_nodes_in_group(DefinitionsHelper.GROUP_UI_DEBUG) 
@onready var debug_reset_button: Button =  PathsHelper.get_node_by_name(debugs, "ResetButton")

func _ready():
	debug_reset_button.connect("pressed", Callable(self, "_on_button_debug_reset_button_toggled"))

func _on_button_debug_reset_button_toggled():
		get_tree().reload_current_scene()
