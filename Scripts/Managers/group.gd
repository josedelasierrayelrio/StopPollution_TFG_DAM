class_name Group
extends Node

var members: Array

func _init():
	pass

func add_in_group(object):
	if not members.has(object):
		members.append(object)

func remove_in_group(object):
	if members.has(object):
		members.erase(object)

func get_group():
	return members
