extends Node3D

const SPEED = 40.0

@onready var mesh = $MeshInstance3D
@onready var ray = $RayCast3D
@onready var hit = $Hit
@onready var hole = $BulletHole

var hit_stopped_position: Vector3
var hit_stopped: bool = false

var hole_stopped_position: Vector3
var hole_stopped: bool = false

func _ready() -> void:
	hit.hide()
	hole.hide()

func _process(delta: float) -> void:
	# Move the bullet
	position += transform.basis * Vector3(0, 0, -SPEED) * delta
	
	# Check for collision
	if ray.is_colliding():
		if not hit_stopped:
			hit.show()
			hole.show()
			
			hit_stopped_position = hit.global_transform.origin  # Save the hit position
			hole_stopped_position = hole.global_transform.origin
			
			hit_stopped = true
			hole_stopped= true
			
			mesh.visible = false
			await get_tree().create_timer(0.1).timeout
			hit.hide()
			
			#The bullet will fly through walls need another way for bulletholes
			await get_tree().create_timer(10.1).timeout
			queue_free()
	
	# Stop the hit label from moving with its parent
	if hit_stopped:
		hit.global_transform.origin = hit_stopped_position  # Fix the position
		
	if hole_stopped:
		hole.global_transform.origin = hole_stopped_position

func _on_timer_timeout() -> void:
	queue_free()
