@icon("res://entities/starship_entity.svg")
extends Node3D

func _on_spacecraft_controller_thrusted(enabled):
	$RocketEngine.visible = enabled
			
