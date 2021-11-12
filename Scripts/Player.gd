extends KinematicBody2D

onready var player_sprite = $Sprite
#onready var hand = $Hand
onready var gun = $Gun
onready var gun_sprite = $Gun/Gun
onready var gun_muzzle = $Gun/Gun/Muzzle
onready var rate_of_fire = $Gun/RateOfFire
onready var hit_timer = $HitTimer
onready var animation = $AnimationPlayer
onready var dash = $Dash
onready var bullet_scene = preload("res://Scenes/Bullet.tscn")

var max_health = 100
var health = max_health setget set_health
var move_speed: int = 150
var dash_speed: int = 1000
var dash_duration: float = 0.2
var velocity: Vector2 = Vector2(0, 0)
var alive: bool = true
var can_shoot: bool = true
var is_reloading: bool = false


enum {
	MOVE,
	DEAD,
	IDLE,
}

var state = IDLE

func _ready():
	gun_sprite.flip_h = false
	rate_of_fire.connect("timeout", self, "_on_RateOfFire_timeout")
	pass

func _process(delta):
	if alive:
		get_input(delta)
	else:
		move_speed = 0
		state = DEAD
			
	match state:
		MOVE:
			alive_state()
		DEAD:
			dead_state()
		IDLE:
			idle_state()


func get_input(delta):
	var x_input = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	var y_input = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
	if Input.is_action_just_pressed("dash") && !dash.is_dashing() && dash.can_dash:
		dash.start_dash(player_sprite, dash_duration)
		animation.play("Dash")
		
	var speed = dash_speed if dash.is_dashing() else move_speed
	velocity = Vector2(x_input, y_input).normalized()
	move_and_slide(velocity * speed)
#	flip()
	if velocity != Vector2.ZERO:
		state = MOVE
#		if Input.is_action_pressed("down"):
#			player_sprite.play("default")
#		elif Input.is_action_pressed("up"):
#			player_sprite.play("up")
#		elif Input.is_action_pressed("left"):
#			player_sprite.play("left")
#		elif Input.is_action_pressed("right"):
#			player_sprite.play("right")
	else:
		state = IDLE
#		player_sprite.play("default")
	gun.look_at(get_global_mouse_position())

	if Input.is_action_pressed("shoot") and can_shoot and not is_reloading:
		is_reloading = true
		rate_of_fire.start()
		shoot()

	if get_global_mouse_position() <= self.global_position:
		gun_sprite.flip_h = true
		gun_sprite.flip_v = true
#		print("left")
	else:
#		print("right")
		gun_sprite.flip_h = true
		gun_sprite.flip_v = false


func idle_state():
#	player_sprite.play("Idle")
	pass

func alive_state():
#	player_sprite.play("Run")
	pass

func dead_state():
	visible = false
	$CollisionShape2D.disabled = true
	$Hitbox/CollisionShape2D.disabled = true
	alive = false
	can_shoot = false

func flip():
	if get_global_mouse_position() <= player_sprite.global_position:
		player_sprite.flip_h = true
	else:
		player_sprite.flip_h = false

func set_health(value):
#	health = value
	var prev_health = health
	health = clamp(value, 0, max_health)
	print("health update")
	if health != prev_health:
		if health == 0:
			print("health is 0")

func shoot():
	gun.shoot()
	var bullet = bullet_scene.instance()#Global.instance_node_at_location(bullet, PersistentNodes, muzzle.global_position)
	bullet.gun_rotation = gun.global_rotation
	bullet.global_position = gun_muzzle.global_position
	get_tree().root.add_child(bullet)

func _on_RateOfFire_timeout():
	is_reloading = false


func _on_HitTimer_timeout():
	modulate = Color(1, 1, 1, 1)


func respawn():
	state = MOVE
	can_shoot = true
	alive = true
	visible = true
	health = max_health
	 

func _on_RespawnTimer_timeout():
	respawn()


func _on_Hitbox_body_entered(body):
	pass # Replace with function body.
