class_name ArraysHelper
extends Node


static func intersect_arrays(arr1, arr2) -> Array: ## Es mucho más rápido el uso de diccionarios que de arrays para la interseccion de elementos
	var arr2_dict = {}
	for v in arr2:
		arr2_dict[v] = true ## Se itera cada elemento y se agrega con el valor true

	var in_both_arrays = []
	for v in arr1:
		if arr2_dict.get(v, false): ## Si existe, se agrega al array interseccionado
			in_both_arrays.append(v)
	return in_both_arrays
	
	
