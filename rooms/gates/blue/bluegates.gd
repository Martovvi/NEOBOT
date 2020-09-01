extends StaticBody2D

func _process(_delta) -> void:
	if(Game.Player.getBlueKey() == true):
		queue_free()
