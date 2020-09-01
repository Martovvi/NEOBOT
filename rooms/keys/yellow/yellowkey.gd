extends Area2D

func _on_YellowKey_body_entered(body):
	if(body.name == "Player"):
		Game.Player.setYellowKey(true)
		Game.Player._keySound.play()
		queue_free()
