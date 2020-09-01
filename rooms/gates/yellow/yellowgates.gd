extends StaticBody2D

func _process(_delta) -> void:
	if(Game.Player.getYellowKey() == true):
		queue_free()
