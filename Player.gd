extends KinematicBody2D

var speed = 250
var velocity = Vector2.ZERO

func _process(delta):
	
	velocity.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	velocity.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	look_at(get_global_mouse_position())
	
	var _collision = move_and_collide(velocity * speed * delta)
