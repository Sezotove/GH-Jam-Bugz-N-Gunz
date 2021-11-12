extends Camera2D

var player: Node2D = null

func _ready():
	var children = get_tree().root.get_children()
	for child in get_tree().get_nodes_in_group("Player"):
		player = child

func _process(delta: float) -> void:
	if player != null:
		global_position = lerp(global_position, player.global_position, delta * 10)
