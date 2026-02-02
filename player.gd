class_name Player
extends CharacterBody2D

@export var tile_size := 16
@export var move_speed := 50.0
@export var animation_tree : AnimationTree
# @export var speed : float = 50

var input_dir = Vector2.ZERO
var moving = false
var target_pos = Vector2.ZERO

var playback : AnimationNodeStateMachinePlayback
	
func _ready():
	playback = animation_tree["parameters/playback"]
	target_pos = global_position

	
func _physics_process(delta):

	# for tile-based movement
	if moving:

		var distance = global_position.distance_to(target_pos)

		# stop exactly at tile
		if distance < 1:
			global_position = target_pos
			moving = false
			select_animation(Vector2.ZERO)
			return

		# move slowly toward tile
		var direction = (target_pos - global_position).normalized()
		var motion = direction * move_speed * delta

		var collision = move_and_collide(motion)

		# collision
		if collision:
			moving = false
			select_animation(Vector2.ZERO)
			return

		return

	input_dir = Input.get_vector("left", "right", "up", "down")

	if input_dir == Vector2.ZERO:
		return

	# no diagonal movement
	if abs(input_dir.x) > abs(input_dir.y):
		input_dir = Vector2(sign(input_dir.x), 0)
	else:
		input_dir = Vector2(0, sign(input_dir.y))


	# set target tile
	target_pos = global_position + input_dir * tile_size
	moving = true

	select_animation(input_dir)
	update_animation_parameters()

func select_animation(dir):
	if dir == Vector2.ZERO:
		playback.travel("Idle")
	else:
		playback.travel("walk")

func update_animation_parameters():
	if input_dir == Vector2.ZERO:
		return

	animation_tree["parameters/Idle/blend_position"] = input_dir
	animation_tree["parameters/walk/blend_position"] = input_dir
