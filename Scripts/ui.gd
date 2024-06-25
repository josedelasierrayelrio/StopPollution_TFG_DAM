class_name ManagerUI
extends CanvasLayer

var window_size = DisplayServer.window_get_size()
var screen_size = DisplayServer.screen_get_size()

@onready var debug_container: PanelContainer = $VBoxContainer/PanelContainer
@onready var debug_fps_label: Label = $VBoxContainer/PanelContainer/DebugContainer/FPSContainer/F_result
@onready var debug_resolution_label: Label = $VBoxContainer/PanelContainer/DebugContainer/ResolutionContainer/R_result

func _process(delta):
	debug_fps_label.text = str(Engine.get_frames_per_second())
	debug_resolution_label.text = str(screen_size)
	
	if Input.is_action_just_pressed(InputsHelper.DEBUG_MODE):
		debug_container.visible = not debug_container.visible
