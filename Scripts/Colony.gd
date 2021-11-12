tool
extends Node2D


export (bool) var clear_colony = false setget clear_colony
export (bool) var generate_colony = false setget generate_colony
export (int) var walker_count

onready var tilemap = $TileMap
onready var top_wall = $TopWall

export var sizes = ['small', 'medium', 'large']

export (String) var colony_size

var WIDTH
var HEIGHT
var player


const TILES = {
	'floor': 0,
	'wall': 1,
}

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	sizes.shuffle()
	colony_size = sizes[0]
	if colony_size == 'small':
		WIDTH = 30
		HEIGHT = 30
	elif colony_size == 'medium':
		WIDTH = 75
		HEIGHT = 75
	elif colony_size == 'large':
		WIDTH = 150
		HEIGHT = 150
	generate_colony(true)
	player = Global.player

func clear_colony(value):
	$TileMap.clear()
	$Wall.clear()
	$TopWall.clear()

func generate_colony(value):
	$TileMap.clear()
	$Wall.clear()
	$TopWall.clear()
	randomize()
	if colony_size == 'small':
		WIDTH = 75
		HEIGHT = 75
	elif colony_size == 'medium':
		WIDTH = 125
		HEIGHT = 125
	elif colony_size == 'large':
		WIDTH = 250
		HEIGHT = 250
	var ground : TileMap = $TileMap
	var wall_top : TileMap = $TopWall
	var wall_base : TileMap = $Wall
	for x in WIDTH:
		for y in HEIGHT:
			wall_top.set_cellv(Vector2(x - WIDTH / 2, y - HEIGHT / 2), 0)
#			wall_base.set_cellv(Vector2(x - WIDTH / 2, y - HEIGHT / 2), 0)
	var colony_rect : Rect2 = wall_top.get_used_rect()
	colony_rect = colony_rect.grow_individual(15, 15, 15, 15)
#	var borders = $TileMap.get_used_rect()
#	for x in range(colony_rect.position.x - 1, colony_rect.end.x + 1):
#		for y in range(colony_rect.position.y - 1, colony_rect.end.y + 1):
#			wall_base.set_cell(x, y, 0)
	var steps = wall_top.get_used_cells().size()
	var startingx = round(rand_range(colony_rect.position.x, colony_rect.end.x))
	var startingy = round(rand_range(colony_rect.position.y, colony_rect.end.y))
#	var walker = DungeonWalker.new(starting_pos[0], borders)
	
	for w in walker_count:
		var walker = Walker.new(Vector2(startingx, startingy), colony_rect)
		var colony = walker.walk(round(steps))
		walker.queue_free()
		for location in colony:
			ground.set_cellv(location, TILES.floor)
#			wall_base.set_cellv(location, -1)
	var ground_cells = ground.get_used_cells()
	for tile in ground_cells:
		if ground.get_cellv(Vector2(tile.x, tile.y -1)) == -1:
			wall_base.set_cellv(Vector2(tile.x, tile.y -1), 0)
	for tile in wall_base.get_used_cells():
		if ground.get_cellv(Vector2(tile.x, tile.y -1)) == 0:
			ground.set_cellv(Vector2(tile.x, tile.y -1), -1)
	wall_top.clear()
	colony_rect = ground.get_used_rect()
	colony_rect = colony_rect.grow_individual(3, 3, 3, 3)
	ground_cells = ground.get_used_cells()
	for x in range(colony_rect.position.x, colony_rect.end.x):
		for y in range(colony_rect.position.y - 1, colony_rect.end.y - 1):
			wall_top.set_cell(x, y, 0)
	for tile in ground_cells:
		if ground.get_cellv(tile) == 0:
			wall_top.set_cellv(tile, -1)
	wall_top.update_bitmask_region()
	ground.update_bitmask_region()
	wall_base.update_bitmask_region()
	ground_cells.shuffle()
	var spawn_loc = ground.map_to_world(ground_cells[0])
	yield(get_tree(), "idle_frame")
	add_child(player)
	add_child(Global.camera)
	player.global_position = spawn_loc
#	player.in_dungeon = true
#	spawn_cells.clear()
