extends Area2D

func _on_GreenKey_body_entered(body):
	if(body.name == "Player"):
		Game.Player.setGreenKey(true)
		Game.Player._keySound.play()
		queue_free()
