@icon("res://entities/character_entity.svg")
@tool
class_name Gobot
extends LCCharacterBody

enum ANIMATIONS {JUMP_UP, JUMP_DOWN, STRAFE, WALK}

@onready var animation_tree = $AnimationTree
@onready var player_model = $PlayerModel
@onready var shoot_from = player_model.get_node("Robot_Skeleton/Skeleton3D/GunBone/ShootFrom")
@onready var crosshair = $Crosshair
@onready var fire_cooldown = $FireCooldown

@onready var sound_effects = $SoundEffects
@onready var sound_effect_jump = sound_effects.get_node("Jump")
@onready var sound_effect_land = sound_effects.get_node("Land")
@onready var sound_effect_shoot = sound_effects.get_node("Shoot")

#-------------------------------------

@export var current_animation := ANIMATIONS.WALK

#-------------------------------------

@export var controller: LCCharacterController

#-------------------------------------

func _ready():
	if not multiplayer.is_server():
		set_process(false)
	
	if controller != null:
		controller.orientation = player_model.global_transform
		controller.orientation.origin = Vector3()

func _process(delta):
	if controller != null:
		player_model.global_transform.basis = controller.orientation.basis
		
		if controller.on_air:
			if (velocity.y > 0):
				current_animation = ANIMATIONS.JUMP_UP
			else:
				current_animation = ANIMATIONS.JUMP_DOWN
		elif controller.aiming:
			
			controller.root_motion = Transform3D(animation_tree.get_root_motion_rotation(), animation_tree.get_root_motion_position())
			
			current_animation = ANIMATIONS.STRAFE
		else:
			controller.root_motion = Transform3D(animation_tree.get_root_motion_rotation(), animation_tree.get_root_motion_position())
			
			current_animation = ANIMATIONS.WALK

	animate(current_animation, delta)

# ------------

func animate(anim: int, delta:=0.0):
	
	current_animation = anim

	if anim == ANIMATIONS.JUMP_UP:
		animation_tree["parameters/state/transition_request"] = "jump_up"

	elif anim == ANIMATIONS.JUMP_DOWN:
		animation_tree["parameters/state/transition_request"] = "jump_down"

	elif anim == ANIMATIONS.STRAFE:
		animation_tree["parameters/state/transition_request"] = "strafe"
		# Change aim according to camera rotation.
		animation_tree["parameters/aim/add_amount"] = controller.aim_rotation
		# The animation's forward/backward axis is reversed.
		animation_tree["parameters/strafe/blend_position"] = Vector2(controller.motion.x, -controller.motion.y)

	elif anim == ANIMATIONS.WALK:
		# Aim to zero (no aiming while walking).
		animation_tree["parameters/aim/add_amount"] = 0
		# Change state to walk.
		animation_tree["parameters/state/transition_request"] = "walk"
		# Blend position for walk speed based checked motion.
		animation_tree["parameters/walk/blend_position"] = Vector2(controller.motion.length(), 0)

@rpc("call_local")
func jump():
	animate(ANIMATIONS.JUMP_UP)
	sound_effect_jump.play()

@rpc("call_local")
func land():
	animate(ANIMATIONS.JUMP_DOWN)
	sound_effect_land.play()

@rpc("call_local")
func shoot():
	var shoot_particle = $PlayerModel/Robot_Skeleton/Skeleton3D/GunBone/ShootFrom/ShootParticle
	shoot_particle.restart()
	shoot_particle.emitting = true
	var muzzle_particle = $PlayerModel/Robot_Skeleton/Skeleton3D/GunBone/ShootFrom/MuzzleFlash
	muzzle_particle.restart()
	muzzle_particle.emitting = true
	fire_cooldown.start()
	sound_effect_shoot.play()
	add_camera_shake_trauma(0.35)


@rpc("call_local")
func hit():
	add_camera_shake_trauma(.75)

@rpc("call_local")
func add_camera_shake_trauma(amount):
	pass
#	player_input.camera_camera.add_trauma(amount)
