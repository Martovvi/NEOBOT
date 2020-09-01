extends Sprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var color = Color( 0.33, 0.20, 0.92, 0.5 )


func _process(_delta):
	modulate = color
	
	color.a *= 0.90
	
	if (color.a < 0.001): queue_free()
