extends RigidBody3D

func hit():
	var fractured_box_scene = preload("res://Objects/box_fractured.tscn")
	var parent = get_parent()
	var fractured_box_instance = fractured_box_scene.instantiate()
	
	if parent:
		fractured_box_instance.transform = transform
		parent.add_child(fractured_box_instance)
		
	queue_free()
