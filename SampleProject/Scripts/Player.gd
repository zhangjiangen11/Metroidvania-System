extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -450.0

var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
var animation: String

var reset_position: Vector2
var event: bool

var abilities: Array[StringName]
var double_jump: bool
var prev_on_floor: bool

func _ready() -> void:
	on_enter()

func _physics_process(delta: float) -> void:
	if event:
		return
	
	if not is_on_floor():
		velocity.y += gravity * delta
	elif not prev_on_floor and &"double_jump" in abilities:
		double_jump = true
	
	if Input.is_action_just_pressed("ui_accept") and (is_on_floor() or double_jump):
		if not is_on_floor():
			double_jump = false
		
		if Input.is_action_pressed("ui_down"):
			position.y += 8
		else:
			velocity.y = JUMP_VELOCITY
	
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	prev_on_floor = is_on_floor()
	move_and_slide()
	
	var new_animation = &"Idle"
	if velocity.y < 0:
		new_animation = &"Jump"
	elif velocity.y >= 0 and not is_on_floor():
		new_animation = &"Fall"
	elif absf(velocity.x) > 1:
		new_animation = &"Run"
	
	if new_animation != animation:
		animation = new_animation
		$AnimationPlayer.play(new_animation)
	
	if velocity.x > 1:
		$Sprite2D.flip_h = false
	elif velocity.x < -1:
		$Sprite2D.flip_h = true

func kill():
	position = reset_position

func on_enter():
	reset_position = position