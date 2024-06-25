class_name Puf
extends Node2D

signal born_a_puf(new_puf: Puf)
signal born_a_baby_puf(new_baby_puf: Puf)
signal spawn_initial_puf(new_puf: Puf)
signal assign_ascendant(ascendant: Puf)
signal assing_descendant(descendant: Puf)
signal change_hunger(new_hunger: float)
signal change_thirst(new_thirst: float)
signal change_years(new_year: int)
signal change_constitution(new_constitution: Constitution)
signal change_social_class(new_social_class: Social_class)
signal change_mood(mood: Mood)
signal change_health_status(health_status: Health_status)

enum Constitution {
	MUSCULAR,
	SLIM,
	FAT,
	PUNNY
}
enum Social_class {
	POOR,
	RICH
}
enum Mood {
	SAD, 
	HAPPY,
	ANGRY,
	ON_STANDBY
}
enum Health_status {
	HEALTHY, 
	SICK, # Enfermo
	STARVING, # Famelico 
	FAINTING, # Desmayado
	DEAD
}

const MIN_HEIGHT: float = 0.8
const MAX_HEIGHT: float = 3
const MIN_BABY_YEARS: float = 0.5
const MAX_BABY_YEARS: float = 3
const MIN_YEARS: float = 18
const MAX_YEARS: float = 35
const MAX_POOR_YEARS: float = 70
const MAX_RICH_YEARS: float = 120
const MIN_HUNGER: float = -10 
const MAX_HUNGER: float = 120
const MIN_THIRST: float = -3
const MAX_THIRST: float = 110
const ORIGIN_TYPE_STREETS: String = "streets"
const ORIGIN_TYPE_PLACES: String = "places"
const NAMES: String = "names"
const SURNAMES: String = "surnames"
const JOBS: String = "jobs"
const BACKGROUNDS: String = "backgrounds"
const NOBLE_TITLE: String = "noble title"

static var jason_manager: Json_manager = Json_manager.new()
static var id: int = 0:
	get:
		return id

var background: String: 
	get:
		return background
var name_of_puf: String
var surname: String
var noble_title: String: # Titulo nobiliario
	get:
		return noble_title
var profession: String: # Profesion 
	get:
		return profession
var place: String: # Lugar de nacimiento 
	get:
		return place
var hunger: float = 0: # Hambre
	get: 
		return hunger
	set(new_hunger):
		hunger = clampf(new_hunger, MIN_HUNGER, MAX_HUNGER)
		emit_signal('change_hunger', new_hunger)
var thirst: float = 0: # Sed
	get: 
		return thirst
	set(new_thirst):
		thirst = clampf(new_thirst, MIN_THIRST, MAX_THIRST)
		emit_signal('change_thirst', new_thirst)
var height: float: # Altura, en metros
	get: 
		return height
var birth_year: int = 0:
	get:
		return birth_year
var years: int = MIN_YEARS:
	get:
		return years
	set(new_year):
		years = clampi(new_year, MIN_YEARS, MAX_YEARS) if new_year > years else years # Los pufs no pueden rejuvenecer
		emit_signal('change_years', new_year)
var is_interactive: bool:
	get:
		return is_interactive
var constitution: Constitution:
	get: 
		return constitution
	set(new_constitution):
		constitution = clampi(new_constitution, 0, Constitution.size())
		emit_signal('change_constitution', new_constitution)
var social_class: Social_class:
	get:
		return social_class
var mood: Mood:
	get:
		return mood
	set(new_mood):
		mood = clampi(new_mood, 0, Mood.size())
		emit_signal('change_mood', new_mood)
var health_status: Health_status:
	get:
		return health_status
	set(new_health_status):
		health_status = clampi(new_health_status, 0, Health_status.size())
		emit_signal('change_health_status', new_health_status)
var ascendant: Puf: # Antecesor
	get:
		return ascendant
	set (ascendant_):
		ascendant = ascendant_
		emit_signal('assign_ascendant', ascendant_)
var descendant: Array[Puf]: # Descendiente
	get:
		return descendant
	set (descendant_):
		descendant.append(descendant_)
		emit_signal('assing_descendant', descendant_)

func _init(social_class_: Social_class, is_baby: bool):
	_next_id()
	self.birth_year = 0
	if social_class_ == DefinitionsHelper.INDEX_RANDOM_SOCIAL_CLASS:
		self.social_class = RandomHelper.get_random_enum(self.Social_class)
		_make_initial_puf()
		emit_signal('spawn_initial_puf', self) 
	else:
		match(is_baby):
			true:
				_make_baby_puf(social_class_)
				emit_signal('born_a_baby_puf', self)
			false:
				_make_puf(social_class_)
				emit_signal('born_a_puf', self)

func _next_id():
	id += 1

func _make_initial_puf():
	_make_puf(RandomHelper.get_random_enum(self.Social_class))

func _make_puf(social_class_: Social_class):
	_set_common_attributes(social_class_)
	self.years = randf_range(MIN_YEARS, MAX_YEARS)

func _make_baby_puf(social_class_: Social_class):
	_set_common_attributes(social_class_)
	self.years = randf_range(MIN_BABY_YEARS, MAX_BABY_YEARS)

func _set_common_attributes(social_class_: Social_class):
	self.social_class = social_class_
	self.is_interactive = true if social_class == Social_class.POOR else false
	self.name_of_puf = _get_random_string(PathsHelper.JSON_PATH_NAMES, NAMES)
	self.surname = _get_random_string(PathsHelper.JSON_PATH_NAMES, SURNAMES)
	self.background = _get_random_background(_is_a_baby(), PathsHelper.JSON_PATH_BACKGROUNDS)
	self.noble_title = _get_random_noble_title(_is_a_rich(), PathsHelper.JSON_PATH_NOBLE_TITLE)
	self.profession = _get_random_string (PathsHelper.JSON_PATH_JOBS, JOBS)
	self.height = randf_range(MIN_HEIGHT, MAX_HEIGHT)
	self.constitution = Constitution.find_key(RandomHelper.get_random_enum(Constitution)).to_lower().capitalize()
	self.place = _get_random_place_of_birth(PathsHelper.JSON_PATH_ORIGINS)
	self.hunger = _get_hunger_according_to_social_class(self.social_class)
	self.thirst = _get_thirst_according_to_social_class(self.social_class)
	self.mood =  Mood.find_key(RandomHelper.get_random_enum(Mood)).to_lower().capitalize()

# Metodos de clase
func get_full_name() -> String:
	return self.name_of_puf + " " + self.surname

func get_percentage_of_thrist() -> String:
	return str((self.thirst / MAX_THIRST) * 100) + "%"

func get_percentage_of_hunger() -> String:
	return str((self.hunger / MAX_HUNGER) * 100) + "%"

# Metodos privados de clase
func _is_a_baby():
	return true if self.years < MIN_YEARS else false

func _is_a_rich():
	return str(self.social_class) == DefinitionsHelper.RICH_SOCIAL_CLASS

func jsonSerialize() -> String:
	var data = {
		"Id": id,
		"Interactive": self.is_interactive,
		"Background": self.background,
		"Noble_title": self.noble_title,
		"Profession": self.profession,
		"Place": self.place,
		"Hunger": self.hunger,
		"Thirst": self.thirst,
		"Height": self.height,
		"Years": self.years,
		"Birth year": self.birth_year,
		"Constitution": self.Constitution.find_key(self.constitution).to_lower().capitalize(),
		"Social_class": self.Social_class.find_key(self.social_class).to_lower().capitalize(),
		"Mood": self.Mood.find_key(self.mood).to_lower().capitalize()
	}
	return JSON.stringify(data)

#Métodos randomizados
func _get_random_string(path: String, subtype: String) -> String:
	var d_string: Dictionary = jason_manager.load_json_file(path)
	return RandomHelper.get_random_string_in_array(d_string[self.Social_class.find_key(self.social_class).to_lower()][subtype])

func _get_random_background(baby_or_not: bool, path: String) -> String:
	var d_background: Dictionary = jason_manager.load_json_file(path)
	var social_class_string = ""
	if baby_or_not:
		social_class_string = str(self.social_class) + " baby" 
	else:
		social_class_string = str(self.social_class) 
	var background_: String = RandomHelper.get_random_string_in_array(d_background[self.Social_class.find_key(self.social_class).to_lower()][BACKGROUNDS.to_lower()])
	var background_remplaced: String = background_.replace("{name}", self.get_full_name()).replace("{years}", str(self.years))
	return background_remplaced

func _get_random_noble_title(is_a_rich:bool, path: String) -> String:
	var d_noble_title: Dictionary = jason_manager.load_json_file(path)
	var n_title: String = RandomHelper.get_random_string_in_array(d_noble_title[NOBLE_TITLE])
	return n_title if is_a_rich else DefinitionsHelper.MEDIOCRES

func _get_random_place_of_birth(path: String) -> String:
	var d_places: Dictionary = jason_manager.load_json_file(path)
	var street: String = RandomHelper.get_random_string_in_array(d_places[ORIGIN_TYPE_STREETS])
	var article: String = ""
	var place_: String = RandomHelper.get_random_string_in_array(d_places[ORIGIN_TYPE_PLACES])
	article = "de la" if place_.ends_with("a") or place_.ends_with("as") or place_.ends_with("al") else "del"
	return street + " " +  article + " " + place_

func _get_hunger_according_to_social_class(social_class_: Social_class) -> float:
	return randf_range(MIN_HUNGER, MAX_HUNGER) if str(social_class_) == DefinitionsHelper.POOR_SOCIAL_CLASS else MAX_HUNGER

func _get_thirst_according_to_social_class(social_class_: Social_class) -> float:
	return randf_range(MIN_THIRST, MAX_THIRST) if str(social_class_) == DefinitionsHelper.POOR_SOCIAL_CLASS else MAX_THIRST
