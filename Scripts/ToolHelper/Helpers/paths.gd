class_name PathsHelper

''' JSON PATHS '''
const JSON_PATH_BUILDING: String = "res://SaveData/GenerateDates/ESP/buildings.json"
const JSON_PATH_ORIGINS: String = "res://SaveData/GenerateDates/ESP/origins.json"
const JSON_PATH_NAMES: String = "res://SaveData/GenerateDates/ESP/name_pufs.json"
const JSON_PATH_BACKGROUNDS: String = "res://SaveData/GenerateDates/ESP/backgrounds.json"
const JSON_PATH_NOBLE_TITLE: String = "res://SaveData/GenerateDates/ESP/noble_title.json"
const JSON_PATH_JOBS: String = "res://SaveData/GenerateDates/ESP/jobs.json"

''' SCENE PATHS '''
const PATH_SCENE_BLOOD_STAIN: String = "res://Scenes/entities/blood_stain.tscn"
const PATH_SCENE_BUILDING: String = "res://Scenes/entities/building.tscn"
const PATH_SCENE_PUF: String = "res://Scenes/entities/puf.tscn"

''' TEXTURE PUFS PATHS'''
const SPRITE_RICH_001: String = "res://Resources/Tileset/pufs/rich.png"
const SPRITE_RICH_002: String = "res://Resources/Tileset/pufs/richv2.png"
const SPRITE_POOR_001: String = "res://Resources/Tileset/pufs/poor.png"
const SPRITE_POOR_002: String = "res://Resources/Tileset/pufs/poorv2.png"
const SPRITE_POOR_003: String = "res://Resources/Tileset/pufs/poorv3.png"
const SPRITE_BABY_POOR: String = "res://Resources/Tileset/pufs/babypuf.png"
const SPRITE_BABY_RICH: String = "res://Resources/Tileset/pufs/babypuf.png"

''' TEXTURE CURSORS PATHS '''
const CURSOR_POINT_OUT: String = "res://Resources/UI/Hands/cursor_normal.png"
const CURSOR_CLICK : String =  "res://Resources/UI/Hands/cursor_normal_click.png"
const CURSOR_GRAB: String =  "res://Resources/UI/Hands/cursor_normal_close.png"
const CURSOR_SMASH: String =  "res://Resources/UI/Hands/cursor_normal_open.png"
const CURSOR_DEATH: String =  "res://Resources/UI/Hands/cursor_normal_death.png"
const CURSOR_STOP: String =  "res://Resources/UI/Hands/cursor_normal_stop.png"

''' PATHS OF ELEMENTS OF UI IN RELATION TO THE MAIN SCENE '''
const UI_PANEL_TO_SELECTED_AREA: String = ("../UI/PanelDraw")
const UI_TOOGLE_BUTTON_MOUSE_CAMERA: String = ("../UI/PanelContainer/DebugContainer/MouseContainer/Button")
const UI_LABEL_YEAR_RESULT: String = ("../UI/SuperiorContainer/YearContainer/YResult")
const UI_LABEL_POLLUTION_RESULT: String = ("../UI/SuperiorContainer/PollutionContainer/PResut")
const UI_LABEL_POBLATION_RESULT: String = ("../UI/SuperiorContainer/PoblationContainer/PoResult")

static func get_node_by_name(nodes: Array, name: String) -> Node:
	for node in nodes:
		if node.name == name:
			return node
	return null
