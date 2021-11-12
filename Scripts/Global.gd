extends Node

var simplex_seed
var player
var camera

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	simplex_seed = randi()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
