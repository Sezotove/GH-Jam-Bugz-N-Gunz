extends Node2D

const dash_delay = 0.4

onready var dash_timer = $DashTimer

var can_dash = true
var sprite

func start_dash(sprite, duration):
	dash_timer.wait_time = duration
	dash_timer.start()

func is_dashing():
	return !dash_timer.is_stopped()


func end_dash():
	can_dash = false
	yield(get_tree().create_timer(dash_delay), 'timeout')
	can_dash = true


func _on_DashTimer_timeout():
	end_dash()

