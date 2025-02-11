@icon("res://entities/starship.svg")
extends Node3D

func _on_spacecraft_controller_thrusted(enabled):
	$RocketEngine.visible = enabled
			
