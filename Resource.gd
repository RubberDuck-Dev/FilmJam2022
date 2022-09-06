extends RigidBody2D

var resource_type = null

var oxygen = preload("res://sprites/oxygen.png")
var water = preload("res://sprites/waterdrop.png")
var food = preload("res://sprites/food.png")
var metal = preload("res://sprites/metal.png")

var speed = 40
var rot = rand_range(-90,90)

var decay_time = 3.0

signal collected

func _ready():
	match resource_type:
		"oxygen":
			$Sprite.texture = oxygen
			$Sprite.modulate = Color(1,1,1,1)
		"water":
			$Sprite.texture = water
			$Sprite.modulate = Color(1,1,1,1)
		"food":
			$Sprite.texture = food
			$Sprite.modulate = Color(1,1,1,1)
		"metal":
			$Sprite.texture = metal
			$Sprite.modulate = Color(1,1,1,1)
	var timer = Timer.new()
	timer.wait_time = decay_time
	timer.connect("timeout",self,"_on_timer_timeout")
	add_child(timer)
	timer.start()

func _physics_process(delta):
	rotation_degrees = rot
	position += transform.x * speed * delta

func _on_Area2D_body_entered(body):
	if body.name == "Player":
		emit_signal("collected",resource_type)
		queue_free()

func _on_timer_timeout():
	queue_free()
