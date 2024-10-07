extends CharacterBody3D

#- @onready ----------
@onready var camera = $Camera
@onready var ray_left = $Raycast/Left
@onready var ray_right = $Raycast/Right
@onready var ray_down = $Raycast/Down


var bullet = load("res://Weapons/Projectiles/bullet.tscn")
var instance

@onready var gun_anim = $Camera/Gun/AnimationPlayer
@onready var gun_ray = $Camera/Gun/BulletSpawn
@onready var gun_bullets = $Camera/Gun/BulletSpawn/CPUParticles3D

@onready var gun_sound = $Camera/Gun/AudioStreamPlayer3D
#- const ----------
const gravity = 9.81 * 2
const BASE_SPEED = 8.0
const ACCELERATION = 4
const JUMP_VELOCITY = 10.0
const max_jumps = 3

#- var: boolean ----------

var tilt_on: bool = true
var wobble_on: bool = true

var is_wall_sliding: bool = false

#- var: float -------
var current_speed = BASE_SPEED

var mouse_sensitivity = 0.006

var wobble_amplitude := 0.03  # Maximum height of the wobble
var wobble_base_speed := 5.0  # Base speed of the wobble
var base_camera_height := 0.0  # To store the camera's initial Y position
var wobble_time := 0.0  # To keep track of time

var jump_count
var tilt_angle = 1.9

func _ready():
	#Capture Mouse Movement
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# Store the initial camera height
	base_camera_height = camera.position.y  

func _unhandled_input(event):
	#Handle Mouse Movement
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		# Locks the Camera Movement between specified angles
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(87))


func _physics_process(delta):
	# Close game on ui_escape 
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
		
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	shoot()
	#- Respawn ----------
	respawn()
	#- Movement ----------
	walk(delta)
	run()
	jump()
	wallrun()
	#- Camera ----------
	tiltCamera()
	wobbleCamera(delta,current_speed)
	
	move_and_slide()

func shoot():
	if Input.is_action_pressed("shoot"):
		if !gun_anim.is_playing():
			gun_anim.play("shoot")
			gun_sound.play()
			gun_bullets.restart()
			instance = bullet.instantiate()
			instance.position = gun_ray.global_position
			instance.transform.basis = gun_ray.global_transform.basis
			get_parent().add_child(instance)

#- Respwan ----------
func respawn():
	if Input.is_action_just_pressed("respawn"):
		global_transform.origin = Vector3(0, 0, 0)
		velocity = Vector3.ZERO 

#- Movement ----------
func walk(delta):
	# Get the input direction and handle the movement/deceleration
	var input_dir = Input.get_vector("left", "right", "forwards", "backwards")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		# Apply movement
		pass
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
	var y_velocity = velocity.y
	velocity.y = 0.0
	velocity = velocity.lerp(direction * current_speed, ACCELERATION * delta)
	velocity.y = y_velocity


var runspeed = BASE_SPEED * 2
func run():
	if Input.is_action_pressed("run"):
		current_speed = runspeed
	elif Input.is_action_just_released("run"):
		current_speed = BASE_SPEED

func jump():
	if Input.is_action_just_pressed("jump") && jump_count < max_jumps:
		jump_count += 1
		velocity.y = JUMP_VELOCITY
	elif is_on_floor():
		jump_count = 0

		
func wallrun():
	if ( ray_left.is_colliding() || ray_right.is_colliding() ) && !ray_down.is_colliding():
		velocity.y = -0.8
		is_wall_sliding = true
	else: 
		is_wall_sliding = false

#- Camera ----------
func tiltCamera():
	if tilt_on == true:
		if Input.is_action_pressed("left"):
			camera.rotation_degrees.z = tilt_angle
		elif Input.is_action_pressed("right"):
			camera.rotation_degrees.z = -tilt_angle
		elif ray_left.is_colliding() && is_wall_sliding:
			camera.rotation_degrees.z = tilt_angle * 4
		elif ray_right.is_colliding() && is_wall_sliding:
			camera.rotation_degrees.z = -tilt_angle * 4
		else:
			camera.rotation_degrees.z = 0

func wobbleCamera(delta: float, player_speed: float):
	if is_on_floor() && wobble_on == true:
		if Input.is_action_pressed("forwards") || Input.is_action_pressed("backwards") || Input.is_action_pressed("left") || Input.is_action_pressed("right"):
			wobble_time += delta * wobble_base_speed * player_speed
			# Calculate the wobble effect using a sine wave
			var wobble_effect := wobble_amplitude * sin(wobble_time)
			camera.position.y = base_camera_height + wobble_effect
		else:
			# Reset to the original height
			camera.position.y = base_camera_height
			# Reset wobble time
			wobble_time = 0.0  
