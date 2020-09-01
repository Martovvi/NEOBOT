extends Camera2D

signal transition_completed

onready var _player: Player = get_parent().get_parent()
onready var _tween: Tween = $PositionTween

var _original_local_anchor_pos = 0

func transition(old_room, new_room) -> void:
	_transition_setup()

	# Find closest camera anchors in both previous and current room and use
	# their positions as interpolation points for camera position.
	var old_global_pos = old_room.get_closest_camera_anchor(_player)
	var new_global_pos = new_room.get_closest_camera_anchor(_player)
	_interpolate_camera_pos(old_global_pos, new_global_pos)

	# Remove camera limits so that camera can smoothly transition between rooms.
	# Note that we wait until the tween has started to avoid jitter when the
	# camera moves from the player anchor to the initial tween position.
	yield(_tween, 'tween_started')
	_remove_camera_limits()

	yield(_tween, 'tween_completed')
	_transition_teardown(new_room)

	emit_signal('transition_completed')

func fit_camera_limits_to_room(room: Room) -> void:
	var room_dims := room.get_room_dimensions()

	self.limit_left = room.global_position.x
	self.limit_right = room.global_position.x + room_dims.x
	self.limit_top = room.global_position.y
	self.limit_bottom = room.global_position.y + room_dims.y

func _transition_setup() -> void:
	# Pause player processing (physics and input processing, animations, state
	# timers, etc.)
	_player.pause()

	# Save the original local position of the camera relative to the anchor so
	# that we can return to it after the transition completes.
	_original_local_anchor_pos = self.position

	# Disable smoothing to avoid jitter during transition.
	self.smoothing_enabled = false

func _transition_teardown(room: Room) -> void:
	# Restore local camera position to the original anchor point.
	self.position = _original_local_anchor_pos

	# Adjust camera limits to match room dimensions.
	self.fit_camera_limits_to_room(room)

	# Re-enable smoothing now that the transition has completed.
	self.smoothing_enabled = true

	# Restore player processing.
	_player.unpause()

func _interpolate_camera_pos(old_global_pos, new_global_pos) -> void:
	var prop := 'position'
	var duration := 0.50
	var trans := Tween.TRANS_QUAD
	var easing := Tween.EASE_IN_OUT

	# Convert tween start and end position from global to local coordinates.
	var old := self.to_local(old_global_pos)
	var new := self.to_local(new_global_pos)

	_tween.stop_all()
	_tween.interpolate_property(self, prop, old, new, duration, trans, easing)
	_tween.start()

func _remove_camera_limits() -> void:
	self.limit_left = -10000000
	self.limit_right = 10000000
	self.limit_top = -10000000
	self.limit_bottom = 10000000
