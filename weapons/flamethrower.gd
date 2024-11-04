# smg.gd
extends Node3D

var bullet = load("res://Weapons/Projectiles/bullet.tscn")
var instance

var ammo = 100

@onready var gun_anim = $AnimationPlayer
@onready var gun_ray = $BulletSpawn
@onready var gun_bullets = $GPUParticles3D
@onready var gun_sound = $AudioStreamPlayer3D

@onready var ammo_count = $MeshInstance3D/Flamethrower/Label3D

var red = Color(255,0,0)
var orange = Color(255,0,255)
var white = Color(255,255,255)

func shoot():
	if Input.is_action_pressed("shoot") and ammo >= 4:
		if !gun_anim.is_playing():
			gun_anim.play("shoot")
			gun_sound.play()
			gun_bullets.restart()
			
			ammo -= 4
			ammo_count.text = str(ammo) + "%"
			if ammo <= 25:
				ammo_count.modulate = red
			elif ammo <= 50:
				ammo_count.modulate = orange
			elif ammo >= 50:
				ammo_count.modulate = white
			
			if gun_ray.is_colliding():
				if gun_ray.get_collider().is_in_group("destructable"):
					gun_ray.get_collider().hit()

func aim():
	pass


func reload():
	if Input.is_action_pressed("reload"):
		while ammo <= 100:
			ammo_count.text = str(ammo) + "%"
			if ammo <= 25:
				ammo_count.modulate = red
			elif ammo <= 50:
				ammo_count.modulate = orange
			elif ammo >= 50:
				ammo_count.modulate = white
			ammo += 1
			await get_tree().create_timer(0.1).timeout
			
