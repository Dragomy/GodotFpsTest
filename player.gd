extends CharacterBody3D


#- Camera ----------
@onready var camera = $Camera
var tilt_on: bool = true
var wobble_on: bool = true
var wobble_amplitude := 0.03  # Maximum height of the wobble
var wobble_base_speed := 5.0  # Base speed of the wobble
var base_camera_height := 0.0  # To store the camera's initial Y position
var wobble_time := 0.0  # To keep track of time
var tilt_angle = 1.9


#- Envoirenment ----------
const gravity = 9.81 * 2


#- Movement ----------
@onready var ray_left = $Raycast/Left
@onready var ray_right = $Raycast/Right
@onready var ray_down = $Raycast/Down
const BASE_SPEED = 8.0
const ACCELERATION = 10.0
const JUMP_VELOCITY = 10.0
const max_jumps = 3
var is_wall_sliding: bool = false
var is_running: bool = false
var is_groundslaming: bool = false
var current_speed = BASE_SPEED
var jump_count
var save_crouch_input_speed
var is_crouching = false
var runspeed = BASE_SPEED * 2


#- Weapons ----------
@onready var smg = $Camera/gun/smg
@onready var flamethrower = $Camera/gun/flamethrower
@onready var sniper = $Camera/gun/sniper
@onready var active_gun =[smg,flamethrower,sniper] 
var array_index = 0


#- Input ----------
var mouse_sensitivity = 0.006


#- StandartFunctions ----------
func _ready():
	#Capture Mouse Movement
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# Store the initial camera height
	base_camera_height = camera.position.y  

func _unhandled_input(event):
	# Handle Mouse Movement
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		# Locks the Camera Movement between specified angles
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(87))
		
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			if array_index+1 < active_gun.size():
				active_gun[array_index].hide()
				array_index += 0.1
				active_gun[array_index].show()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if array_index-1 >= 0:
				active_gun[array_index].hide()
				array_index -= 0.1
				active_gun[array_index].show()

func _physics_process(delta):
	#Close game on ui_escape 
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()

	if not is_on_floor():
		velocity.y -= gravity * delta
		
	#- Respawn ----------
	respawn()
	
	#- Movement ----------
	walk(delta)
	run()
	jump()
	crouch()
	groundslam()
	wallrun()
	handle_weapon()
	
	#- Camera ----------
	tiltCamera()
	wobbleCamera(delta,current_speed)
	
	print(array_index)
	
	#- MoveAndSlide ----------
	move_and_slide()


#- WeaponHandling ----------
func handle_weapon():
	active_gun[array_index].shoot()
	active_gun[array_index].reload()
	
	if Input.is_action_just_pressed("weapon 1"):
		active_gun[array_index].hide()
		array_index = 0
		active_gun[array_index].show()
	elif Input.is_action_just_pressed("weapon 2"):
		active_gun[array_index].hide()
		array_index = 1
		active_gun[array_index].show()


#- Respawn ----------
func respawn():
	if Input.is_action_just_pressed("respawn"):
		global_transform.origin = Vector3(0, 0, 0)
		velocity = Vector3.ZERO 


#- Movement ----------
func walk(delta):
	var input_dir = Input.get_vector("left", "right", "forwards", "backwards")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		pass
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
	var y_velocity = velocity.y
	velocity.y = 0.0
	velocity = velocity.lerp(direction * current_speed, ACCELERATION * delta)
	velocity.y = y_velocity

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

func crouch():
	if Input.is_action_just_pressed("crouch") && !is_running && !is_crouching:
		is_crouching = true
		scale.y = 0.5
		save_crouch_input_speed = current_speed
		current_speed = current_speed / 2
	elif Input.is_action_just_pressed("crouch") && Input.is_action_just_pressed("run"):
		scale.y = 1
		current_speed = save_crouch_input_speed
		is_crouching = false
	elif Input.is_action_just_released("crouch") && is_crouching:
		scale.y = 1
		current_speed = save_crouch_input_speed
		is_crouching = false

func groundslam():
	if !is_on_floor():
		if Input.is_action_just_pressed("slam"):
			is_groundslaming = true
			velocity.y = -100
	elif is_on_floor() && is_groundslaming:
		is_groundslaming = false
		#slam_animation.play()

func wallrun():
	if (ray_left.is_colliding() || ray_right.is_colliding()) && !ray_down.is_colliding():
		velocity.y = -0.8
		is_wall_sliding = true
	else: 
		is_wall_sliding = false


#- Camera ----------
func tiltCamera():
	if tilt_on:
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
	if is_on_floor() && wobble_on:
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
