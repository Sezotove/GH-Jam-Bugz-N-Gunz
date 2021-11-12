extends Area2D


var speed: int = 1500
var damage: int = rand_range(1, 5)
var velocity: Vector2 = Vector2(1, 0)
var colliding: bool = false
var gun_rotation



func _ready():
	velocity = velocity.rotated(gun_rotation)
	global_rotation = gun_rotation


func _physics_process(delta):
	global_position += velocity * speed * delta


func destroy():
	queue_free()

func _on_Hitbox_area_entered(area):
	destroy()


func _on_Destroy_timeout():
	destroy()


func _on_Bullet_body_entered(body):
	destroy()
