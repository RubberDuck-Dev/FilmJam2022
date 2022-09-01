extends Node2D

var resources = {
	"oxygen": {"on_hand":8,"capacity":100,"held":0, "health":100},
	"water": {"on_hand":5,"capacity":100,"held":0, "health":100},
	"food": {"on_hand":7,"capacity":100,"held":0, "health":100},
	"metal": {"on_hand":10},
} as Dictionary

var resource_instance = preload("res://Resource.tscn")

var repair_target

# game time
var day = 1
var time_elapsed = 0
var day_duration = 24 #ticks per day

var tick_duration = 2
var tick = tick_duration

func _ready():
	update_labels()
	set_process(true)

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		check_repair()

	tick -= delta
	if tick <= 0:
		print ("Tick")
		update_progress()
		time_elapsed += 1
		day = int(time_elapsed/day_duration)
		tick = tick_duration  # reset timer

func update_progress():
	resources["oxygen"]["health"] -= 5
	resources["water"]["health"] -= 5
	resources["food"]["health"] -= 5
	check_repair()
	output_resource("oxygen",$InteriorHab/Oxygenator)
	output_resource("water",$InteriorHab/WaterReclaimer)
	update_labels()

func check_repair():
	if resources["metal"]["on_hand"] >0:
		if repair_target != null and Input.is_action_pressed("ui_accept"):
			if resources[repair_target]["health"] <= 100:
				resources[repair_target]["health"] += 10
				resources["metal"]["on_hand"] -= 1

func handle_interaction(action,resource):
	if action == "input":
		input_resource(resource)
	elif action == "output":
		#output_resource()
		pass
	else:
		print("interaction?")
	update_labels()

func input_resource(resource_type):
	var capacity = resources[resource_type]["capacity"] - resources[resource_type]["on_hand"]
	var amount_moved = min(resources[resource_type]["on_hand"],capacity)
	resources[resource_type]["held"] += amount_moved
	resources[resource_type]["on_hand"] -= amount_moved

	if resources[resource_type]["health"] < 100:
		$UI/InteractionLabel.text = "E to repair"
		$UI/InteractionLabel.visible = true
	
func output_resource(resource,node):
	if resources[resource]["health"] >0:
		var o = resource_instance.instance()
		o.position = node.position
		o.resource_type = resource
		o.connect("collected",self,"item_collected")
		get_parent().add_child(o)

func item_collected(resource_type):
	resources[resource_type]["on_hand"] += 1
	
func _on_Oxygenator_body_entered(body):
	if body.name == "Player":
		repair_target = "oxygen"
		handle_interaction("input","oxygen")

func _on_WaterReclaimer_body_entered(body):
	if body.name == "Player":
		repair_target = "water"
		handle_interaction("input","water")

func _on_Farm_body_entered(body):
	if body.name == "Player":
		repair_target = "food"
		handle_interaction("input","food")

func update_labels():
	$UI/O2Held/Label.text = str(resources["oxygen"]["on_hand"])
	$UI/WaterHeld/Label.text = str(resources["water"]["on_hand"])
	$UI/FoodHeld/Label.text = str(resources["food"]["on_hand"])
	$UI/MetalHeld/Label.text = str(resources["metal"]["on_hand"])

	$InteriorHab/Oxygenator/Label.text = str(resources["oxygen"]["held"])
	$InteriorHab/Oxygenator/ProgressBar.max_value = 100
	$InteriorHab/Oxygenator/ProgressBar.value = resources["oxygen"]["health"]

	$InteriorHab/Oxygenator/TargetProgressBar.max_value = 100
	$InteriorHab/Oxygenator/TargetProgressBar.value = resources["oxygen"]["health"] + 10

	$InteriorHab/WaterReclaimer/Label.text = str(resources["water"]["held"])
	$InteriorHab/WaterReclaimer/ProgressBar.max_value = 100
	$InteriorHab/WaterReclaimer/ProgressBar.value = resources["water"]["health"]

	$InteriorHab/Farm/Label.text = str(resources["food"]["held"])
	$InteriorHab/Farm/ProgressBar.max_value = 100
	$InteriorHab/Farm/ProgressBar.value = resources["food"]["health"]
	
	$UI/TimeProgressBar.max_value = day_duration
	$UI/TimeProgressBar.value = time_elapsed % day_duration

func _on_Oxygenator_body_exited(body):
	if body.name == "Player":
		repair_target = null
		$UI/InteractionLabel.visible = false


func _on_WaterReclaimer_body_exited(body):
	if body.name == "Player":
		repair_target = null
		$UI/InteractionLabel.visible = false

func _on_Farm_body_exited(body):
	if body.name == "Player":
		repair_target = null
		$UI/InteractionLabel.visible = false


func _on_Area2D_body_entered(body):
	if body.name == "Player":
		$UI/InteractionLabel.text = "E to exit The Hab"
		$UI/InteractionLabel.visible = true

func _on_Area2D_body_exited(body):
	if body.name == "Player":
		$UI/InteractionLabel.visible = false
