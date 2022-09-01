extends Node2D

var resources = {
	"oxygen": {"on_hand":50,"capacity":200,"held":0, "health":50, "tick_drain":6.0, "tick_drain_amount":6.0, "increase_amount":1},
	"water": {"on_hand":25,"capacity":200,"held":0, "health":50, "tick_drain":6.0, "tick_drain_amount":6.0, "increase_amount":1},
	"food": {"on_hand":50,"capacity":100,"held":0, "health":50, "tick_drain":12.0, "tick_drain_amount":6.0, "increase_amount":1},
	"metal": {"on_hand":100},
} as Dictionary

var resource_instance = preload("res://Resource.tscn")
var target_machine = null
var repairables = {"oxygen":{"automated":false,"node":"InteriorHab/Oxygenator"},
					"water":{"automated":false,"node":"InteriorHab/WaterReclaimer"},
					"food":{"automated":false,"node":"InteriorHab/Farm"}}
var upgrade_price = 2
var automate_price = 10

var has_signaled_rocket = false
var rocket_arrival_days = 10
var rocket_time_elapsed = 0

var upgrade_menu_visible = false

# game time
var day = 1
var time_elapsed = 0
var day_duration = 24 #ticks per day
var tick_duration = 2.0
var tick = tick_duration

func _ready():
	update_labels()
	$UpgradeMenu.visible = upgrade_menu_visible
	$UI.visible = true
	set_process(true)

func _process(delta):
	if Input.is_action_pressed("ui_accept"):
		check_repair()

	update_labels()
	tick -= delta
	if tick <= 0:
		update_progress()
		time_elapsed += 1

		#for Stage 2
		if has_signaled_rocket == true:
			rocket_time_elapsed +=1
		day = int(time_elapsed/day_duration)
		tick = tick_duration  # reset timer

func update_progress():
	for machine in repairables:
		if repairables[machine]["automated"] != true:
			decrease_machine(machine)
		generate_resource(machine,get_node(repairables[machine]["node"]))

func decrease_machine(resource):
	if time_elapsed % int(resources[resource]["tick_drain"]) == 0 and resources[resource]["held"] >0:
		var dec_amount =  min(resources[resource]["tick_drain_amount"],resources[resource]["held"])
		resources[resource]["held"] -= dec_amount

func check_repair():
	if resources["metal"]["on_hand"] >0:
		if target_machine != null and repairables.has(target_machine) and Input.is_action_pressed("ui_accept"):
			if resources[target_machine]["health"] < 100:
				resources[target_machine]["health"] += 10
				resources["metal"]["on_hand"] -= 1

func handle_interaction(action,source,resource):
	if action == "input":
		input_resource(source,resource)
	elif action == "upgrade":
		$UpgradeMenu.visible = !upgrade_menu_visible
		$UpgradeMenu/AnimationPlayer.play("O2Pipe")
		$UpgradeMenu/AnimationPlayer.play("H2OPipe")
	else:
		print("interaction?")
	update_labels()

func input_resource(source,resource):
	
	# 400 on hand water
	# 600 capacity oxygen
	# 0 in machine water
	# 
	# available capacity = 600-400 = 200
	# amount_moved = min(400,200) = 200
	# 
	# 
	# 
	
	var available_capacity = resources[resource]["capacity"] - resources[resource]["held"]
	var amount_moved = min(resources[source]["on_hand"],available_capacity)
	resources[resource]["held"] += amount_moved
	resources[source]["on_hand"] -= amount_moved

	if resources[resource]["health"] < 100:
		$UI/InteractionLabel.text = "E to repair"
		$UI/InteractionLabel.visible = true
	
func generate_resource(resource,node):

	if repairables[resource]["automated"] == true:
		automatic_item_collected(resource)
	elif resources[resource]["held"] > 0:
		var o = resource_instance.instance()
		o.global_position = node.global_position
		o.resource_type = resource
		o.connect("collected",self,"item_collected")
		get_parent().add_child(o)
	

func item_collected(resource):
	resources[resource]["on_hand"] += resources[resource]["increase_amount"]

func automatic_item_collected(resource):
	#picks up resource into hand and immediately into machine
	item_collected(resource)
	match resource:
		"oxygen":
			input_resource("food", "oxygen")
		"water":
			input_resource("oxygen", "water")
		"water":
			input_resource("water", "food")
	
func _on_Oxygenator_body_entered(body):
	if body.name == "Player":
		target_machine = "oxygen"
		handle_interaction("input","food","oxygen")

func _on_WaterReclaimer_body_entered(body):
	if body.name == "Player":
		target_machine = "water"
		handle_interaction("input","oxygen","water")

func _on_Farm_body_entered(body):
	if body.name == "Player":
		target_machine = "food"
		handle_interaction("input","water","food")

func update_labels():
	$UI/BLPanel/VBox/O2Held/AmountLabel.text = str(resources["oxygen"]["on_hand"])
	$UI/BLPanel/VBox/O2Held/DurationLabel.text = duration_remaining("oxygen")

	$UI/BLPanel/VBox/WaterHeld/AmountLabel.text = str(resources["water"]["on_hand"])
	$UI/BLPanel/VBox/WaterHeld/DurationLabel.text = duration_remaining("water")

	$UI/BLPanel/VBox/FoodHeld/AmountLabel.text = str(resources["food"]["on_hand"])
	$UI/BLPanel/VBox/FoodHeld/DurationLabel.text = duration_remaining("food")

	$UI/BLPanel/VBox/MetalHeld/AmountLabel.text = str(resources["metal"]["on_hand"])

	$InteriorHab/Oxygenator/Label.text = str(resources["oxygen"]["held"])
	$InteriorHab/Oxygenator/ProgressBar.max_value = resources["oxygen"]["capacity"]
	$InteriorHab/Oxygenator/ProgressBar.value = resources["oxygen"]["held"]

	$InteriorHab/Oxygenator/TargetProgressBar.max_value = resources["oxygen"]["capacity"]
	$InteriorHab/Oxygenator/TargetProgressBar.value = resources["oxygen"]["held"]

	$InteriorHab/WaterReclaimer/Label.text = str(resources["water"]["held"])
	$InteriorHab/WaterReclaimer/ProgressBar.max_value = resources["water"]["capacity"]
	$InteriorHab/WaterReclaimer/ProgressBar.value = resources["water"]["held"]

	$InteriorHab/Farm/Label.text = str(resources["food"]["held"])
	$InteriorHab/Farm/ProgressBar.max_value = resources["food"]["capacity"]
	$InteriorHab/Farm/ProgressBar.value = resources["food"]["held"]
	
	$UI/TimeProgressBar.max_value = day_duration
	$UI/TimeProgressBar.value = time_elapsed % day_duration
	$UI/DayLabel/Label.text = str(stepify(time_elapsed / day_duration,0.0)+1)
	
	$UpgradeMenu/MetalLabel/AmountLabel.text = str(resources["metal"]["on_hand"])
	
	#$UI/BLPanel/RocketArrivalLabel/AmountLabel.text = str(rocket_arrival_days)
	if has_signaled_rocket:
		$UI/BLPanel/VBox/RocketArrivalLabel/AmountLabel.text = str(convert_to_readable_time(rocket_arrival_days * day_duration - rocket_time_elapsed))
	else:
		$UI/BLPanel/VBox/RocketArrivalLabel/AmountLabel.text = "???"

func _on_Oxygenator_body_exited(body):
	if body.name == "Player":
		target_machine = null
		$UI/InteractionLabel.visible = false


func _on_WaterReclaimer_body_exited(body):
	if body.name == "Player":
		target_machine = null
		$UI/InteractionLabel.visible = false

func _on_Farm_body_exited(body):
	if body.name == "Player":
		target_machine = null
		$UI/InteractionLabel.visible = false

func _on_Area2D_body_entered(body):
	if body.name == "Player":
		$UI/InteractionLabel.text = "E to exit The Hab"
		$UI/InteractionLabel.visible = true

func _on_Area2D_body_exited(body):
	if body.name == "Player":
		$UI/InteractionLabel.visible = false

func duration_remaining(resource):
	# ticks until amount = 0	
	var ticks_remaining =  resources[resource]["held"] / resources[resource]["tick_drain_amount"] * resources[resource]["tick_drain"]
	
	if ticks_remaining == 0:
		return "Empty"
	else:
		return convert_to_readable_time(ticks_remaining)

func convert_to_readable_time(tick_count):
	var days = int(tick_count / day_duration)
	var hours = tick_count - (days * day_duration)
	if days == 1:
		return str(days, " day, ", stepify(hours,0.01), " hours")
	elif days > 1:
		return str(days, " days, ", stepify(hours,0.01), " hours")
	else:
		return str(stepify(tick_count,0.01), " hours")


func _on_UpgradeBooth_body_entered(body):
	if body.name == "Player":
		target_machine = "upgrade"
		handle_interaction("upgrade",null,null)

func _on_UpgradeBooth_body_exited(body):
	if body.name == "Player":
		target_machine = null
		$UpgradeMenu.visible = false

func handle_upgrade(resource):
	resources[resource]["increase_amount"] += 1

func _on_UpgradeButton_pressed():
	if resources["metal"]["on_hand"] >= upgrade_price:
		handle_upgrade("oxygen")
		$UpgradeMenu/TabContainer/Upgrade/O2Label/UpgradeButton.disabled = true
		resources["metal"]["on_hand"] -= upgrade_price

func _on_WaterUpgradeButton_pressed():
	if resources["metal"]["on_hand"] >= upgrade_price:
		handle_upgrade("water")
		$UpgradeMenu/TabContainer/Upgrade/H2OLabel/UpgradeButton.disabled = true
		resources["metal"]["on_hand"] -= upgrade_price

func _on_FoodUpgradeButton_pressed():
	if resources["metal"]["on_hand"] >= upgrade_price:
		handle_upgrade("food")
		$UpgradeMenu/TabContainer/Upgrade/FoodLabel/UpgradeButton.disabled = true
		resources["metal"]["on_hand"] -= upgrade_price

func _on_O2ConnectorUpgrade_pressed():
	if resources["metal"]["on_hand"] >= automate_price:
		$InteriorHab/FoodtoO2.visible = true
		repairables["oxygen"]["automated"] = true
		$UpgradeMenu/TabContainer/Automate/O2PipeLabel/UpgradeButton.disabled = true
		resources["metal"]["on_hand"] -= automate_price

func _on_WaterConnectorUpgrade_pressed():
	if resources["metal"]["on_hand"] >= automate_price:
		$InteriorHab/O2toH2O.visible = true
		repairables["water"]["automated"] = true
		$UpgradeMenu/TabContainer/Automate/H2OPipeLabel/UpgradeButton.disabled = true
		resources["metal"]["on_hand"] -= automate_price

func _on_FoodConnectorUpgrade_pressed():
	if resources["metal"]["on_hand"] >= automate_price:
		$InteriorHab/H2OtoFood.visible = true
		repairables["food"]["automated"] = true
		$UpgradeMenu/TabContainer/Automate/FoodPipeLabel/UpgradeButton.disabled = true
		resources["metal"]["on_hand"] -= automate_price
