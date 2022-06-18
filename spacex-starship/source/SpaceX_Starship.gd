extends Spatial

# onready var parent: lnSpacecraft = get_parent()
onready var parent = get_parent()

func _process(delta):
	$Exhause.direction = parent.global_transform.basis.z
	$Exhause.initial_velocity = -10
	
func _on_SpacecraftController_thrust(enabled):
	$Exhause.emitting = enabled
