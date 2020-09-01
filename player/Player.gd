extends KinematicBody2D
class_name Player

const ACCELERATION = 3000
const MAX_SPEED = 18000
const LIMIT_SPEED_Y = 1200
const JUMP_HEIGHT = 39050
const MIN_JUMP_HEIGHT = 12000
const MAX_COYOTE_TIME = 6
const JUMP_BUFFER_TIME = 10
const WALL_JUMP_AMOUNT = 18000
const WALL_JUMP_TIME = 10
const WALL_SLIDE_FACTOR = 0.8
const WALL_HORIZONTAL_TIME = 30
const GRAVITY = 2100
const DASH_SPEED = 36000


var velocity = Vector2()
var axis = Vector2()

var coyoteTimer = 0
var jumpBufferTimer = 0
var wallJumpTimer = 0
var wallHorizontalTimer = 0
var dashTime = 0

var spriteColor = "blue"
var canJump = false
var friction = false
var wall_sliding = false
var trail = false
var isDashing = false
var hasDashed = false
var isGrabbing = false
var is_dead = false
var hasRedKey = false setget setRedKey, getRedKey
var hasGreenKey = false setget setGreenKey, getGreenKey
var hasBlueKey = false setget setBlueKey, getBlueKey
var hasYellowKey = false setget setYellowKey, getYellowKey
var jumpCancel = false


var dashSounds = []

onready var dashTimer = $Cooldown/DashTimer
onready var Cooldown = $Cooldown
onready var deadTimer = $Cooldown/DeadTimer
onready var _camera_anchor: Position2D = $CameraAnchor
onready var _animation_player: AnimationPlayer = $AnimationPlayer
onready var _dashSound: AudioStreamPlayer = $Sounds/Dash
onready var _deathSound: AudioStreamPlayer = $Sounds/Death 
onready var _keySound: AudioStreamPlayer = $Sounds/KeyPickup

var prev_room = null
var curr_room = null
onready var starting_room = get_node(starting_room_path)

export(NodePath) var starting_room_path = ""

func _get_configuration_warning() -> String:
	if starting_room_path == '':
		return "Please specify the player's starting room."
	return ''

func _ready():
	Game.Player = self
		# Initialize current room
	assert(starting_room_path != '')
	curr_room = get_node(starting_room_path)
	prev_room = curr_room
	get_camera().fit_camera_limits_to_room(curr_room)
	randomize()
	dashSounds.append(preload("res://sounds/dash-01.wav"))
	dashSounds.append(preload("res://sounds/dash-02.wav"))
	_dashSound.stream=dashSounds.front()

func get_animation_player() -> AnimationPlayer:
	return _animation_player

func get_camera() -> Camera2D:
	return _camera_anchor.get_node('Camera2D') as Camera2D

func _input(_event) -> void:
	if Input.is_action_pressed("exit"):
		get_tree().quit()

func _physics_process(delta):
	
	if is_dead == false:
		if velocity.y <= LIMIT_SPEED_Y:
			if !isDashing:
				velocity.y += GRAVITY * delta
	
		friction = false
		
		getInputAxis()
		dash(delta)
		
		wallSlide(delta)
	
		#basic vertical movement mechanics
		if wallJumpTimer > WALL_JUMP_TIME:
			wallJumpTimer = WALL_JUMP_AMOUNT
			if !isDashing && !isGrabbing:
				horizontalMovement(delta)
		else:
			wallJumpTimer += 1
		
		if !canJump:
			if !wall_sliding:
				if velocity.y >= 0:
					$AnimationPlayer.play(str(spriteColor, "Fall"))
				elif velocity.y < 0:
					$AnimationPlayer.play(str(spriteColor, "Jump"))
	
		#jumping mechanics and coyote time
		if is_on_floor():
			canJump = true
			coyoteTimer = 0
		else:
			coyoteTimer += 1
			if coyoteTimer > MAX_COYOTE_TIME:
				canJump = false
				coyoteTimer = 0
			friction = true
		
		jumpBuffer(delta)
	
		if Input.is_action_just_pressed("jump"):
			if canJump:
				jump(delta)
				frictionOnAir()
			else:
				if $Rotatable/RayCast2D.is_colliding():
					wallJump(delta)
				frictionOnAir()
				jumpBufferTimer = JUMP_BUFFER_TIME #amount of frame
		if Input.is_action_just_released("jump"):
			jump_cut()
	
		setJumpHeight(delta)
		jumpBuffer(delta)
	
		velocity = move_and_slide(velocity, Vector2.UP)

func jump_cut() -> void:
	if velocity.y < -200:
		velocity.y = -200

func dead():
	is_dead = true
	velocity = Vector2(0, 0)
	$AnimationPlayer.play(str(spriteColor, "Dead"))
	$CollisionShape2D.set_deferred("disabled", true)
	_deathSound.play()
	deadTimer.start()

func jump(delta):
	velocity.y = -JUMP_HEIGHT * delta

func wallJump(delta):
	wallJumpTimer = 0
	velocity.x = -WALL_JUMP_AMOUNT * $Rotatable.scale.x * delta
	velocity.y = -JUMP_HEIGHT * delta
	$Rotatable.scale.x = -$Rotatable.scale.x

func wallSlide(delta):
	if !canJump:
		if $Rotatable/RayCast2D.is_colliding():
			wall_sliding = true
			if Input.is_action_pressed("grab"):
				isGrabbing = true
				if axis.y != 0:
					velocity.y = axis.y * 12000 * delta
					$AnimationPlayer.play(str(spriteColor, "Climb"))
				else:
					velocity.y = 0
					$AnimationPlayer.play(str(spriteColor, "Wall Slide"))
			else:
				isGrabbing = false
				velocity.y = velocity.y * WALL_SLIDE_FACTOR
				$AnimationPlayer.play(str(spriteColor, "Wall Slide"))
		else:
			wall_sliding = false
			isGrabbing = false
	

func frictionOnAir():
	if friction:
		velocity.x = lerp(velocity.x, 0, 0.01)

func jumpBuffer(delta):
	if jumpBufferTimer > 0:
		if is_on_floor():
			jump(delta)
		jumpBufferTimer -= 1

func setJumpHeight(delta):
	if Input.is_action_just_released("ui_up"):
		if velocity.y < -MIN_JUMP_HEIGHT * delta:
			velocity.y = -MIN_JUMP_HEIGHT * delta

func horizontalMovement(delta):
	if Input.is_action_pressed("ui_right"):
		if $Rotatable/RayCast2D.is_colliding():
			yield(get_tree().create_timer(0.1),"timeout")
			velocity.x = min(velocity.x + ACCELERATION * delta, MAX_SPEED * delta)
			$Rotatable.scale.x = 1
			if canJump:
				$AnimationPlayer.play(str(spriteColor, "Run"))
		else:
			velocity.x = min(velocity.x + ACCELERATION * delta, MAX_SPEED * delta)
			$Rotatable.scale.x = 1
			if canJump:
				$AnimationPlayer.play(str(spriteColor, "Run"))

	elif Input.is_action_pressed("ui_left"):
		if $Rotatable/RayCast2D.is_colliding():
			yield(get_tree().create_timer(0.1),"timeout")
			velocity.x = max(velocity.x - ACCELERATION * delta, -MAX_SPEED * delta)
			$Rotatable.scale.x = -1
			if canJump:
				$AnimationPlayer.play(str(spriteColor, "Run"))
		else:
			velocity.x = max(velocity.x - ACCELERATION * delta, -MAX_SPEED * delta)
			$Rotatable.scale.x = -1
			if canJump:
				$AnimationPlayer.play(str(spriteColor, "Run"))
	else:
		velocity.x = lerp(velocity.x, 0, 0.4)
		if canJump:
			$AnimationPlayer.play(str(spriteColor, "Idle"))


func dash(delta):
	if !hasDashed and dashTimer.is_stopped():
		if Input.is_action_just_pressed("dash") and isPlayerMoving():
			velocity = axis * DASH_SPEED * delta
			spriteColor = "grey"
			Input.start_joy_vibration(0, 1, 1, 0.2)
			isDashing = true
			hasDashed = true
			dash_sounds_random(dashSounds)
			dashTimer.start()
			
	if isDashing:
		trail = true
		dashTime += 1
		if dashTime >= int(0.25 * 1 / delta):
			isDashing = false
			trail = false
			dashTime = 0

	if is_on_floor() && velocity.y >= 0:
		hasDashed = false
		spriteColor = "blue"

func getInputAxis():
	axis = Vector2.ZERO
	axis.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	axis.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	axis = axis.normalized()

func isPlayerMoving():
	if Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right") or Input.is_action_pressed("jump") or Input.is_action_pressed("ui_up"):
		return true
	else:
		return false

func _on_TrailTimer_timeout():
	if trail:
		var trail_sprite = Sprite.new()
		trail_sprite.texture = load("res://sprites/player-spritesheet.png")
		trail_sprite.vframes = 10
		trail_sprite.hframes = 8
		trail_sprite.frame = $Rotatable/Sprite.frame
		trail_sprite.scale.x = 2 * 1.2
		trail_sprite.scale.y = 2 * 1.2
		trail_sprite.scale.x = $Rotatable.scale.x * 2 * 1.2
		trail_sprite.set_script(load("res://scripts/TrailFade.gd"))
		
		get_parent().add_child(trail_sprite)
		trail_sprite.position = position
		trail_sprite.modulate = Color( 1, 0.08, 0.58, 0.5 )
		trail_sprite.z_index = -49

func _on_DashTimer_timeout():
	Cooldown.start()

# Pause/resume processing for player node specifically. Used during room
# transitions.
func pause() -> void:
	set_physics_process(false)
	set_process_unhandled_input(false)
	get_animation_player().stop(false)
	
	dashTimer.paused = true
	Cooldown.paused = true

func unpause() -> void:
	set_physics_process(true)
	set_process_unhandled_input(true)
	get_animation_player().play()
	
	dashTimer.paused = false
	Cooldown.paused = false


func setRedKey(b: bool) -> void:
	hasRedKey = b

func getRedKey() -> bool:
	return hasRedKey

func setGreenKey(b: bool) -> void:
	hasGreenKey = b

func getGreenKey() -> bool:
	return hasGreenKey

func setBlueKey(b: bool) -> void:
	hasBlueKey = b

func getBlueKey() -> bool:
	return hasBlueKey

func setYellowKey(b: bool) -> void:
	hasYellowKey = b

func getYellowKey() -> bool:
	return hasYellowKey

func dash_sounds_random (s:Array) -> void:
	s.shuffle()
	_dashSound.stream=dashSounds.front()
	_dashSound.play()

func _on_AudioStreamPlayer_finished():
	dash_sounds_random(dashSounds)


func _on_DeadTimer_timeout():
	get_tree().reload_current_scene()
