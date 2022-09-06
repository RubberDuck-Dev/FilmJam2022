extends StaticBody2D

export var health = 2

signal machine_targeted
signal machine_exited

func _on_Machine_body_entered(body):
	if body.name == "Player":
		emit_signal("machine_targeted")


func _on_Machine_body_exited(body):
	if body.name == "Player":
		emit_signal("machine_exited")
