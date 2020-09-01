extends Node2D
class_name Room

# Get global positions of all camera anchors in each room. During a transition,
# the player camera will interpolate its position from the closest anchor in
# the old room to the closest anchor in the new room.
func get_camera_anchors() -> Array:
	var anchors = []
	for anchor in get_node('CameraAnchors').get_children():
		anchors.push_back(anchor.global_position)
	return anchors

func get_closest_camera_anchor(player: Player) -> Vector2:
	var player_pos := player.global_position

	var min_dist := INF
	var min_dist_anchor := Vector2()

	for anchor in self.get_camera_anchors():
		var dist := player_pos.distance_to(anchor)
		if dist < min_dist:
			min_dist = dist
			min_dist_anchor = anchor

	return min_dist_anchor

# TODO: don't rely on inherited node strucutres for getting Area2D.
func get_room_dimensions() -> Vector2:
	var half_extents = get_node('RoomBoundaries').get_node('CollisionShape2D').shape.extents

	return 2 * half_extents
