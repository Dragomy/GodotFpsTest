# smg.gd
extends Node3D

var bullet = load("res://Weapons/Projectiles/bullet.tscn")
var instance

var ammo = 10

@onready var gun_anim = $AnimationPlayer

@onready var ammo_count = $Sniper/Label3D

func shoot():
	if Input.is_action_pressed("shoot") and ammo > 0:
		if !gun_anim.is_playing():
			gun_anim.play("shoot")
			ammo -= 1
			ammo_count.text = str(ammo)


func aim():
	pass
	
func reload():
	if Input.is_action_pressed("reload"):
		ammo = 10
		ammo_count.text = str(ammo)
