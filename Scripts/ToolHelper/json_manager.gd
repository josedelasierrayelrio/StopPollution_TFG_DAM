extends Node
class_name Json_manager
'''
Singleton para cargar/guardar datos en archivos json
'''
static var instance: Json_manager = null
var item_data: Dictionary = {}

static func get_instance() -> Json_manager:
	if instance == null:
		instance = Json_manager.new()
	return instance

func load_json_file(file_path: String) -> Dictionary:
	if FileAccess.file_exists(file_path):
		var data_file = FileAccess.open(file_path, FileAccess.READ)
		var parsed_result = JSON.parse_string(data_file.get_as_text())
		if parsed_result is Dictionary:
			return parsed_result
		else:
			return {"Error": "Error al leer el archivo"}
	else: 
		return {"Error": "El archivo no existe"}

