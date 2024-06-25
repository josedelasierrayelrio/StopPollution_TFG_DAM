class_name DefinitionsHelper

''' General Definitions '''
const SCRIPT: String = "script"
const INDEX_NOT_EXIST: int = -1
const TOTAL_TYPE_BUILDING: int = 5

''' Class Names'''
const CLASS_PUF: String = "PUF"
const CLASS_BUILDING: String = "BUILDING"

''' Script Names'''
const SCRIPT_PUF: String = "Puf"
const SCRIPT_BUILDING: String = "Building"

''' Pufs '''
const RICH_SOCIAL_CLASS: String = "RICH"
const POOR_SOCIAL_CLASS: String = "POOR"
const NAMES: String = "names"
const MEDIOCRES: String = "Mediocres"
const INDEX_RANDOM_SOCIAL_CLASS: int = -1
const INDEX_RICH_SOCIAL_CLASS: int = 1
const INDEX_POOR_SOCIAL_CLASS: int = 0

'''  Type of celebration puf'''
const TYPE_CELEBRATION_SMASH_PUF: String = "smash"

''' Ways of dying of the Pufs'''
const WAY_DYING_SMASH: String = "smash"
const WAY_DYING_BY_FALL_PUF: String = "by_fall"
const WAY_DYING_NEEDS: String = "needs"

''' Texture puf '''
const texture_rich_pufs = [
	PathsHelper.SPRITE_RICH_002, 
]
const texture_poor_pufs = [
	PathsHelper.SPRITE_POOR_001, 
	PathsHelper.SPRITE_POOR_002, 
	PathsHelper.SPRITE_POOR_003, 
]

''' Texture Building '''
const TEXTURE_BUILDING_RICH_001: int = 0
const TEXTURE_BUILDING_RICH_002: int = 1
const TEXTURE_BUILDING_RICH_003: int = 2
const TEXTURE_BUILDING_RICH_004: int = 3
const TEXTURE_BUILDING_RICH_005: int = 4
const TEXTURE_BUILDING_RICH_006: int = 5
const TEXTURE_BUILDING_RICH_007: int = 6
const TEXTURE_BUILDING_RICH_008: int = 7
const TEXTURE_BUILDING_POOR_WINDMILL: int = 10
const TEXTURE_BUILDING_POOR_WAREHOUSES_001: int = 13
const TEXTURE_BUILDING_POOR_WAREHOUSES_002: int = 14
const TEXTURE_BUILDING_POOR_WAREHOUSES_003: int = 15
const TEXTURE_BUILDING_POOR_CROP: int = 16
const TEXTURE_BUILDING_POOR_BIG_WELL: int = 20
const TEXTURE_BUILDING_POOR_TINY_WELL: int = 22
const TEXTURE_BUILDING_POOR_SHACK_001: int = 12
const TEXTURE_BUILDING_POOR_SHACK_002: int = 12
const TEXTURE_BUILDING_POOR_SHACK_003: int = 12
const TEXTURE_BUILDING_POOR_LITTLE_HOUSE_001: int = 24
const TEXTURE_BUILDING_POOR_LITTLE_HOUSE_002: int = 25
const TEXTURE_BUILDING_POOR_LITTLE_HOUSE_003: int = 26
const TEXTURE_BUILDING_POOR_LITTLE_HOUSE_004: int = 27
const TEXTURE_BUILDING_POOR_LITTLE_HOUSE_005: int = 28
const TEXTURE_BUILDING_POOR_LITTLE_HOUSE_006: int = 29
const TEXTURE_BUILDING_POOR_LITTLE_HOUSE_007: int = 30
const TEXTURE_BUILDING_POOR_LITTLE_HOUSE_008: int = 31
const TEXTURE_BUILDING_POOR_LITTLE_HOUSE_009: int = 32
const TEXTURE_BUILDING_POOR_LITTLE_HOUSE_010: int = 33
const TEXTURE_BUILDING_POOR_LITTLE_HOUSE_011: int = 34
const TEXTURE_BUILDING_POOR_LITTLE_HOUSE_012: int = 35


''' Selected methods '''
const METHOD_SELECT: String = "select"
const METHOD_DESELECT: String = "deselect"

''' Animations '''
const ANIMATION_SELECTED_PUF: String = "selected"
const ANIMATION_WALK_PUF: String = "Pufs/walk"
const ANIMATION_RUN_PUF: String = "Pufs/run"
const ANIMATION_RESET_PUF: String = "RESET"
const ANIMATION_DIE_PUF: String = "Pufs/die"
const ANIMATION_IDLE_PUF: String = "Pufs/idle"
const ANIMATION_SICK_PUF: String = "Pufs/sick"
const ANIMATION_DRAG_PUF: String = "Pufs/drag"
const ANIMATION_DROP_PUF: String = "Pufs/drop"
const ANIMATION_TERROR_PUF: String = "Pufs/terror"
const ANIMATION_CELEBRATION_PUF: String = "Pufs/celebration"
const ANIMATION_PICK_ME: String = "Pufs/pick_me"
const ANIMATION_JUMP_PUF: String = "Pufs/jump"
const ANIMATION_KNOCKBACK_JUMP_PUF: String = "Pufs/knockback_jump"
const ANIMATION_DEATH_BY_FALL_PUF: String = "Pufs/DBFall"
const ANIMATION_TO_DIE_PUF: String = "Pufs/ToDie"
const ANIMATION_DEATH_BY_SMASH_PUF: String = "Pufs/DBSmash"

const ANIMATION_DEATH_BY_SMASH_CURSOR: String = "Cursor/DBSmash"

const ANIMATION_PLUS_UI: String = "MinumPlus/plus"
const ANIMATION_MINUM_UI: String = "MinumPlus/minum"
const ANIMATION_UP_UI: String = "Pollution/up"
const ANIMATION_DOWN_UI: String = "Pollution/down"

const ANIMATION_BUILDING_BIG_WATERWELL: String = "big_waterwell"
const ANIMATION_BUILDING_MEDIUM_WATERWELL: String = "medium_waterwell"
const ANIMATION_BUILDING_SMALL_WATERWELL: String = "small_waterwell"
const ANIMATION_BUILDING_WINDMILL: String = "windmill"
const ANIMATION_BUILDING_CROP: String = "crop"

''' All layers 2D '''
const LAYER_GROUND_2D: int = 0
const LAYER_ENTITIES_2D: int = 1
const LAYER_ITEMS_2D: int = 2
const LAYER_ENVIROMENT_2D: int = 3
const LAYER_GUI_2D: int = 4

''' Layers in tilemap '''
const TILEMAP_LAYER_TYPE_WALL = "wall"
const TILEMAP_LAYER_TYPE_SPAWN = "spawn"
const TILEMAP_LAYER_TYPE_OUTLINE = "outline"
const TILEMAP_LAYER_TYPE_DEATH = "death"

''' Paths fo tilemap layers '''
const TM_LAYER_GROUND: int = 0
const TM_LAYER_PATHS: int = 1

''' Names of groups'''
const GROUP_PUFS: String = "pufs"
const GROUP_BUILDING: String = "building"
const GROUP_MANAGER_PUFS: String = "manager_pufs"
const GROUP_UI_LABELS_RESULT: String = "ui_labels_result"
const GROUP_UI_STATISTICS_ANIMATIONS: String = "ui_statistics_animations"
const GROUP_UI_DEBUG: String = "debug"
const GROUP_TILEMAP: String = "tilemap"
const GROUP_CAMERA: String = "camera"
const GROUP_BIRTHROOM: String = "birthroom"

''' Definition statistics '''
const UI_LABEL_STATISTICS_TIME_TO_RICH: String = "next rich in..."
const UI_LABEL_STATISTICS_INITIAL_TIME: String = "next Puf in..."
