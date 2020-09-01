extends Area2D

func _on_BlueKey_body_entered(body):
	if(body.name == "Player"):
		Game.Player.setBlueKey(true)
		Game.Player._keySound.play()
		queue_free()
