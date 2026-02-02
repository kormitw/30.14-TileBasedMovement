class_name Player
extends CharacterBody2D
@export var tile_size := 16
@export var move_speed := 50.0
@export var turn_delay := 0.15
@export var animation_tree : AnimationTree
var input_dir = Vector2.ZERO
var last_dir = Vector2.RIGHT
var moving = false
var turn_timer := 0.0
var target_pos = Vector2.ZERO
var playback : AnimationNodeStateMachinePlayback
	
func _ready():
	playback = animation_tree["parameters/playback"]
	target_pos = global_position
	update_animation_parameters()
	
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
	
	# Countdown turn timer
	if turn_timer > 0:
		turn_timer -= delta
	
	input_dir = Input.get_vector("left", "right", "up", "down")
	
	# Reset timer when no input
	if input_dir == Vector2.ZERO:
		turn_timer = 0
		return
	
	# no diagonal movement
	if abs(input_dir.x) > abs(input_dir.y):
		input_dir = Vector2(sign(input_dir.x), 0)
	else:
		input_dir = Vector2(0, sign(input_dir.y))
	
	# Check if direction changed (turning in place)
	if input_dir != last_dir:
		last_dir = input_dir
		update_animation_parameters()
		turn_timer = turn_delay
		select_animation(Vector2.ZERO)
		return
	
	# Don't move if still in turn delay
	if turn_timer > 0:
		return
	
	# Don't move or animate if blocked
	var new_target = global_position + input_dir * tile_size
	if not is_tile_passable(new_target):
		return  
	
	# Same direction = move forward
	target_pos = global_position + input_dir * tile_size
	moving = true
	select_animation(input_dir)
	update_animation_parameters()
	
func is_tile_passable(world_pos: Vector2) -> bool:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = world_pos
	query.exclude = [self]
	
	var result = space_state.intersect_point(query)
	return result.is_empty()
	
func select_animation(dir):
	if dir == Vector2.ZERO:
		playback.travel("Idle")
	else:
		playback.travel("walk")
		
func update_animation_parameters():
	animation_tree["parameters/Idle/blend_position"] = last_dir
	animation_tree["parameters/walk/blend_position"] = last_dir
