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

func shoot():
	if Input.is_action_pressed("shoot") and ammo > 0:
		if !gun_anim.is_playing():
			gun_anim.play("shoot")
			gun_sound.play()
			gun_bullets.restart()
			
			ammo -= 1
			ammo_count.text = str(ammo) + "%"
			
			if gun_ray.is_colliding():
				if gun_ray.get_collider().is_in_group("destructable"):
					gun_ray.get_collider().hit()

func reload():
	if Input.is_action_pressed("reload"):
		if ammo <= 100:
			ammo_count.text = str(ammo) + "%"
			ammo += 1
			await get_tree().create_timer(1).timeout
			
