extends Node3D  

func _ready():
	shatter()  
	await get_tree().create_timer(4).timeout
	queue_free()

func shatter():
	for child in get_children():
		
		if child is RigidBody3D:  
			
			child.apply_force(Vector3((randf() - 0.5) * 50, (randf() - 0.5) * 50, (randf() - 0.5) * 50))
