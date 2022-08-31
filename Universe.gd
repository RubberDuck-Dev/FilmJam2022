extends Node2D

var resources = {
	"oxygen": {"on_hand":10,"capacity":100,"held":0},
	"water": {"on_hand":5,"capacity":100,"held":0},
	"food": {"on_hand":10,"capacity":100,"held":0},
} as Dictionary

func _ready():
	update_labels()

func _process(_delta):
	pass

func handle_interaction(action,resource):
	if action == "input":
		input_resource(resource)
	elif action == "output":
		output_resource(resource)
	else:
		print("interaction?")
	update_labels()

func input_resource(resource_type):
	var capacity = resources[resource_type]["capacity"] - resources[resource_type]["on_hand"]
	var amount_moved = min(resources[resource_type]["on_hand"],capacity)
	resources[resource_type]["held"] += amount_moved
	resources[resource_type]["on_hand"] -= amount_moved
	
func output_resource(resource_type):
	resources[resource_type] -= 1
	
func _on_Oxygenator_body_entered(body):
	if body.name == "Player":
		handle_interaction("input","oxygen")


func _on_WaterReclaimer_body_entered(body):
	if body.name == "Player":
		handle_interaction("input","water")

func _on_Farm_body_entered(body):
	if body.name == "Player":
		handle_interaction("input","food")

func update_labels():
	$UI/O2Held/Label.text = str(resources["oxygen"]["on_hand"])
	$UI/WaterHeld/Label.text = str(resources["water"]["on_hand"])
	$UI/FoodHeld/Label.text = str(resources["food"]["on_hand"])

	$InteriorHab/Oxygenator/Label.text = str(resources["oxygen"]["held"])
	$InteriorHab/Oxygenator/ProgressBar.max_value = resources["oxygen"]["capacity"]
	$InteriorHab/Oxygenator/ProgressBar.value = resources["oxygen"]["held"]

	$InteriorHab/WaterReclaimer/Label.text = str(resources["water"]["on_hand"])
	$InteriorHab/WaterReclaimer/ProgressBar.max_value = resources["water"]["capacity"]
	$InteriorHab/WaterReclaimer/ProgressBar.value = resources["water"]["held"]

	$InteriorHab/Farm/Label.text = str(resources["food"]["on_hand"])
	$InteriorHab/Farm/ProgressBar.max_value = resources["food"]["capacity"]
	$InteriorHab/Farm/ProgressBar.value = resources["food"]["held"]
