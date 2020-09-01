extends StaticBody2D

func _process(_delta) -> void:
	if(Game.Player.getGreenKey() == true):
		queue_free()
