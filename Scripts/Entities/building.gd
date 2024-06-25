class_name Building
extends Node

enum Quality {
	EXCELLENT,
	NORMAL,
	MEDIOCRE,
	DECREPIT
}
const MIN_YEARS: int = 18
const MIN_GAUGING: int = 4
const MAX_GAUGING: int = 20
const MAX_STRUCTURAL_HEALTH: int = 100
const MIN_STRUCTURAL_HEALTH: int = 0

signal add_tenant_in_building(tenant: Puf)
signal remove_tenant_in_building(tenant: Puf)
signal change_structural_health(new_structural_health: float)
signal change_owner(new_owner: Puf)

static var id: int = 0:
	get:
		return id
var gauging: int: # Aforo
	get:
		return gauging 
var name_of_structure : String :
	get:
		return name_of_structure
var quality: Quality :
	get: 
		return quality
var quality_count: float:
	get:
		return quality_count
var structural_health: float:
	get: 
		return structural_health
	set(new_structural_health):
		structural_health = clampf(new_structural_health, MIN_STRUCTURAL_HEALTH, MAX_STRUCTURAL_HEALTH)
		emit_signal('change_structural_health', new_structural_health)
var owner_of_build: Node2D: 
	get:
		return owner_of_build
	set(new_owner):
		owner_of_build = new_owner
		emit_signal('change_owner', new_owner)
var tenants: Array[Node2D]
var jm: Json_manager

func _init(owner_: Node2D):
	jm = Json_manager.new()
	_next_id()
	self.owner_of_build = owner_
	_set_quality_of_building()
	self.gauging = _get_gauging()
	self.name_of_structure = _get_random_string(owner_of_build.social_class, PathsHelper.JSON_PATH_NAMES, DefinitionsHelper.NAMES)
	self.structural_health = MAX_STRUCTURAL_HEALTH

func _next_id():
	id += 1

func _set_quality_of_building():
	if owner_of_build.years >= MIN_YEARS and str(owner_of_build.social_class) == DefinitionsHelper.RICH_SOCIAL_CLASS:
		self.quality = self.Quality.EXCELLENT
	else: 
		self.quality = RandomHelper.get_random_enum(self.Quality)

func _get_gauging() -> int:
	match self.quality:
		self.Quality.EXCELLENT:
			return MAX_GAUGING
		self.Quality.NORMAL:
			return randi_range(MIN_GAUGING, MAX_GAUGING)
		self.Quality.MEDIOCRE:
			return randi_range(MIN_GAUGING, MAX_GAUGING)
		self.Quality.DECREPIT:
			return MIN_GAUGING
		_: # Opcion default
			return 0

func jsonSerialize() -> String:
	var data = {
		"id": id,
		"gauging": self.gauging,
		"name_of_structure": self.name_of_structure,
		"quality": self.quality,
		"owner_of_build": self.owner_of_build.name_of_puf
	}
	return JSON.stringify(data)

# Metodos señalizados
func add_tenants(tenant: Puf):
	if !self.tenants.has(tenant): 
		self.tenants.append(tenant)
		emit_signal('add_tenant_in_building', tenant)

func remove_tenants(tenant: Puf):
	if self.tenants.has(tenant):
		self.tenants.erase(tenant)
		emit_signal('remove_tenant_in_building', tenant)

# Metodos randomizados
func _get_random_string(social_class: Puf.Social_class, path: String, subtype: String) -> String:
	var d_string: Dictionary = jm.load_json_file(path)
	return RandomHelper.get_random_string_in_array(d_string[Puf.Social_class.find_key(social_class).to_lower()][subtype])


