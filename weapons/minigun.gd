# smg.gd
extends Node3D

var bullet = load("res://weapons/projectiles/bullet.tscn")
var instance

var ammo = 100

@onready var gun_anim = $AnimationPlayer
@onready var gun_ray = $BulletSpawn

@onready var ammo_count = $MeshInstance3D/Minigun/Label3D

func shoot():
	if Input.is_action_pressed("shoot") and ammo > 0:
		if !gun_anim.is_playing():
			gun_anim.play("shoot")
			
			ammo -= 1
			ammo_count.text = str(ammo)
			instance = bullet.instantiate()
			
			instance.position = gun_ray.global_position
			instance.transform.basis = gun_ray.global_transform.basis
			
			var world_scene = get_tree().root.get_child(0)
			world_scene.add_child(instance)


func aim():
	pass


func reload():
	if Input.is_action_pressed("reload"):
		ammo = 100
		ammo_count.text = str(ammo)
