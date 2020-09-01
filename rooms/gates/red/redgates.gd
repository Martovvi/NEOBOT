extends StaticBody2D

func _process(_delta) -> void:
	if(Game.Player.getRedKey() == true):
		queue_free()
