tool
extends Node2D

onready var tilemap = $TileMap
onready var simplex_seed = Global.simplex_seed
onready var player = $Player
onready var camera = $Camera

export (bool) var clear_world = false setget clear_world
export (bool) var generate_world = false setget generate_world



const WIDTH = 150
const HEIGHT = 150

const spawn_height = 30
const spawn_width = 30



const TILES = {
	'dirt': 0,
	'dirt-plain': 1,
	'water': 2
}


var open_simplex_noise


func _ready():
	Global.player = player
	Global.camera = camera
	generate_world(simplex_seed)

func clear_world(value):
	$TileMap.clear()

func generate_world(value):
	open_simplex_noise = OpenSimplexNoise.new()
	open_simplex_noise.seed = simplex_seed
	
	open_simplex_noise.octaves = 4
	open_simplex_noise.period = 15
	open_simplex_noise.lacunarity = 1.5
	open_simplex_noise.persistence = 0.75
	for x in WIDTH:
		for y in HEIGHT:
			$TileMap.set_cellv(Vector2(x - WIDTH / 2, y - HEIGHT / 2), get_tile_index(open_simplex_noise.get_noise_2d(float(x), float(y))))
	var used_tiles = $TileMap.get_used_cells()
	for i in used_tiles:
		if $TileMap.get_cellv(i + Vector2(-1, 0)) == -1: #Left
			$TileMap.set_cellv(i + Vector2(-1, 0), TILES.water)
		if $TileMap.get_cellv(i + Vector2(1, 0)) == -1: #Right
			$TileMap.set_cellv(i + Vector2(1, 0), TILES.water)#water
		if $TileMap.get_cellv(i + Vector2(0, 1)) == -1: #Down
			$TileMap.set_cellv(i + Vector2(0, 1), TILES.water)
		if $TileMap.get_cellv(i + Vector2(0, -1)) == -1: #Up
			$TileMap.set_cellv(i + Vector2(0, -1), TILES.water)#water
		if $TileMap.get_cellv(i + Vector2(-1, -1)) == -1: #Left
			$TileMap.set_cellv(i + Vector2(-1, -1), TILES.water)
		if $TileMap.get_cellv(i + Vector2(-1, 1)) == -1: #Right
			$TileMap.set_cellv(i + Vector2(-1, 1), TILES.water)#water
		if $TileMap.get_cellv(i + Vector2(1, -1)) == -1: #Down
			$TileMap.set_cellv(i + Vector2(1, -1), TILES.water)
		if $TileMap.get_cellv(i + Vector2(1, 1)) == -1: #Up
			$TileMap.set_cellv(i + Vector2(1, 1), TILES.water)#Wal
	$TileMap.update_bitmask_region()


func get_tile_index(noise_sample):
	if noise_sample < -0.3:
		return TILES.water
#	if noise_sample < -0.1 and noise_sample > 0.4:
#		return TILES.grass
	if noise_sample < 0.4:
		return TILES.dirt
	return TILES.dirt


func _on_ColonyEntrance_body_entered(body):
	if body.is_in_group("Player"):
		remove_child(player)
		remove_child(camera)
	get_tree().change_scene("res://Scenes/Colony.tscn")
