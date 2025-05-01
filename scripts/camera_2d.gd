extends Camera2D

var shake_duration = 0.0
var shake_intensity = 0.0
var shake_start_time = 0.0

var original_position = Vector2.ZERO

func _ready():
	original_position = position

func _process(delta):
	if shake_duration > 0:
		var elapsed_time = Time.get_ticks_msec() - shake_start_time
		var remaining_time = shake_duration - elapsed_time / 1000.0
		
		if remaining_time > 0:
			var current_intensity = shake_intensity * (remaining_time / shake_duration)
			
			position = original_position + Vector2(
				randf_range(-current_intensity, current_intensity),
				randf_range(-current_intensity, current_intensity)
			)
		else:
			shake_duration = 0.0
			position = original_position

func shake(duration: float = 0.2, intensity: float = 10.0):
	shake_duration = duration
	shake_intensity = intensity
	shake_start_time = Time.get_ticks_msec()
