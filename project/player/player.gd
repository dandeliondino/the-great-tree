extends KinematicBody2D

var speed = 100.0
var velocity = Vector2.ZERO

var interactables = []

func _ready():
	Game.player = self


func _physics_process(delta):
	if velocity != Vector2.ZERO:
		set_current_interactable()
	
	var input_vector : Vector2 = get_input_vector()
	if input_vector != Vector2.ZERO:
		velocity = input_vector * speed
	else:
		velocity = Vector2.ZERO
	velocity = move_and_slide(velocity)
	


func get_input_vector():
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	return input_vector


func set_current_interactable():
	var closest_interactable : Node2D = null
	var shortest_distance : float = 1000.0
	
	for node in interactables:
		var d = global_position.distance_to(node.global_position)
		if d < shortest_distance:
			shortest_distance = d
			closest_interactable = node
	
	if closest_interactable == Game.current_interactable:
		return
	
	Events.emit_signal("current_interactable_change_requested", closest_interactable)

func get_interactable_from_collision(area : Area2D):
	var interactable_object = area.get_parent()
	if interactable_object.is_in_group("interactable_object"):
		return interactable_object
	return null

func add_interactable(node : Node2D):
	if interactables.has(node):
		return
		
	interactables.append(node)
	set_current_interactable()

func remove_interactable(node : Node2D):
	if !interactables.has(node):
		return
	
	interactables.erase(node)
	set_current_interactable()
	
func _on_InteractArea_area_entered(area : Area2D):
	var interactable_object = get_interactable_from_collision(area)
	if interactable_object == null:
		return
	
	add_interactable(interactable_object)


func _on_InteractArea_area_exited(area : Area2D):
	var interactable_object = get_interactable_from_collision(area)
	if interactable_object == null:
		return
	
	remove_interactable(interactable_object)
