extends Area2D

func _on_Spikes_body_entered(body):
	if(body is KinematicBody2D):
		Game.Player.dead()
