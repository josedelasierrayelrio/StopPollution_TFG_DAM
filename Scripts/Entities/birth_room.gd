extends Sprite2D

@export var wait_birth_puf: float = 20 ## Tiempo que tarda en clonarse el puf

var total_collect_pufs: Dictionary
var collect_puf: Node2D
var pufs

@onready var collect_shape: CollisionShape2D = $Area2D/CollectShape
@onready var birth_timer: Timer = $BirthTimer
@onready var interact_label: Label = $InteractLabel

func _ready():
	birth_timer.wait_time = wait_birth_puf

func _process(delta):
	pass
	#_connect_to_signals_pufs()

func _connect_to_signals_pufs():
	pufs = get_tree().get_nodes_in_group("pufs")
	for puf in pufs:
		if not puf.is_connected("puf_smashed", Callable(self, "_on_smashed_puf")):
			puf.connect("puf_smashed", Callable(self, "_on_smashed_puf"))

func _active_text_label(text: String, label: Label, time_to_disappears: float = 0):
	label.visible = true if text.length() > 0 else false
	label.text = text
	if time_to_disappears == -1:
		return
	if text.is_empty() or not text.length() > 0:
		time_to_disappears = 0 
	await get_tree().create_timer(time_to_disappears).timeout
	label.visible = false

func _on_area_2d_body_entered(body):
	if body is BehaviourPuf:
		if not body.is_myself_rich():
			body.inside_the_birthroom_area = true
			collect_puf = body
			_active_text_label("[Q] to beget offspring", interact_label, -1)

func _on_area_2d_body_exited(body):
	if body is BehaviourPuf:
		if collect_puf == body:
			body.inside_the_birthroom_area = false
			collect_puf = null
			_active_text_label("", interact_label)

func _on_birth_timer_timeout():
	pass # Replace with function body.
