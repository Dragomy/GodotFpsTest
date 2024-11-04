extends Node3D

const SPEED = 40.0

@onready var ray = $RayCast3D

var hit_stopped_position: Vector3
var hit_stopped: bool = false

var hole_stopped_position: Vector3
var hole_stopped: bool = false

func _process(delta: float) -> void:
	# Move the bullet
	position += transform.basis * Vector3(0, 0, -SPEED) * delta
	
	# Check for collision
	if ray.is_colliding():
		if not hit_stopped:
			hit_stopped = true
			hole_stopped= true
			
			if ray.get_collider().is_in_group("destructable"):
				ray.get_collider().hit()
				ray.enabled = false
			
			await get_tree().create_timer(0.01).timeout
			queue_free()

func _on_timer_timeout() -> void:
	queue_free()
