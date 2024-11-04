extends Node3D

func effect():
	if Input.is_action_just_pressed("weapon 1"):
		#item_anim.play("drink_beer")
		await get_tree().create_timer(1).timeout
		#drunklayer.show()
		await get_tree().create_timer(3).timeout
		#drunklayer.hide()
