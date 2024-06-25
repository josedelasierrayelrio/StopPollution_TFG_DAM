class_name BehavioursSelectedCircle
extends Sprite3D

var is_fix_size: bool = false
var zoom_camera: float

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_fix_size:
		fix_size(delta)

func fix_size(delta: float):
	self.pixel_size = zoom_camera * delta
