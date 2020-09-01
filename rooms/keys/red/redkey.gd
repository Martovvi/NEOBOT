extends Area2D

func _on_RedKey_body_entered(body):
	if(body.name == "Player"):
		Game.Player.setRedKey(true)
		Game.Player._keySound.play()
		queue_free()
