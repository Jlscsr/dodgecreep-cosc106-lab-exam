extends Camera2D

var shake_duration = 0.0
var shake_intensity = 0.0
var shake_start_time = 0.0

var original_position = Vector2.ZERO
var original_zoom = Vector2.ONE

# Explosion effect variables
var explosion_duration = 0.0
var explosion_start_time = 0.0
var explosion_zoom_factor = 1.3

# Slowmo effect variables
var slowmo_duration = 0.0
var slowmo_start_time = 0.0
var slowmo_zoom_factor = 1.1

# Shield effect variables
var shield_duration = 0.0
var shield_start_time = 0.0

# Score boost effect variables
var score_boost_duration = 0.0
var score_boost_start_time = 0.0

# Damage effect variables
var damage_duration = 0.0
var damage_start_time = 0.0

func _ready():
	original_position = position
	original_zoom = zoom

func _process(delta):
	# Handle shake effect
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
	
	# Handle explosion zoom effect
	if explosion_duration > 0:
		var elapsed_time = Time.get_ticks_msec() - explosion_start_time
		var remaining_time = explosion_duration - elapsed_time / 1000.0
		
		if remaining_time > 0:
			var progress = 1.0 - (remaining_time / explosion_duration)
			if progress < 0.3:
				# Quick zoom in
				var zoom_progress = progress / 0.3
				zoom = original_zoom.lerp(original_zoom * explosion_zoom_factor, zoom_progress)
			else:
				# Slower zoom out
				var zoom_progress = (progress - 0.3) / 0.7
				zoom = (original_zoom * explosion_zoom_factor).lerp(original_zoom, zoom_progress)
		else:
			explosion_duration = 0.0
			zoom = original_zoom
	
	# Handle slowmo zoom effect
	if slowmo_duration > 0:
		var elapsed_time = Time.get_ticks_msec() - slowmo_start_time
		var remaining_time = slowmo_duration - elapsed_time / 1000.0
		
		if remaining_time > 0:
			var progress = 1.0 - (remaining_time / slowmo_duration)
			if progress < 0.2:
				# Zoom in gradually
				var zoom_progress = progress / 0.2
				zoom = original_zoom.lerp(original_zoom * slowmo_zoom_factor, zoom_progress)
			elif progress > 0.8:
				# Zoom out at the end
				var zoom_progress = (progress - 0.8) / 0.2
				zoom = (original_zoom * slowmo_zoom_factor).lerp(original_zoom, zoom_progress)
			else:
				# Maintain zoom
				zoom = original_zoom * slowmo_zoom_factor
		else:
			slowmo_duration = 0.0
			zoom = original_zoom
	
	# Handle shield pulse effect
	if shield_duration > 0:
		var elapsed_time = Time.get_ticks_msec() - shield_start_time
		var remaining_time = shield_duration - elapsed_time / 1000.0
		
		if remaining_time > 0:
			# Subtle pulsing zoom
			var pulse = sin(elapsed_time / 100.0) * 0.02 + 1.0
			zoom = original_zoom * pulse
		else:
			shield_duration = 0.0
			zoom = original_zoom
	
	# Handle score boost effect
	if score_boost_duration > 0:
		var elapsed_time = Time.get_ticks_msec() - score_boost_start_time
		var remaining_time = score_boost_duration - elapsed_time / 1000.0
		
		if remaining_time > 0:
			# Quick zoom pulses
			var pulse_speed = 8.0
			var pulse = sin(elapsed_time / 1000.0 * pulse_speed) * 0.03 + 1.0
			zoom = original_zoom * pulse
		else:
			score_boost_duration = 0.0
			zoom = original_zoom
	
	# Handle damage zoom effect
	if damage_duration > 0:
		var elapsed_time = Time.get_ticks_msec() - damage_start_time
		var remaining_time = damage_duration - elapsed_time / 1000.0
		
		if remaining_time > 0:
			var progress = 1.0 - (remaining_time / damage_duration)
			if progress < 0.1:
				# Quick zoom out
				var zoom_progress = progress / 0.1
				zoom = original_zoom.lerp(original_zoom * 0.9, zoom_progress)
			else:
				# Zoom back in
				var zoom_progress = (progress - 0.1) / 0.9
				zoom = (original_zoom * 0.9).lerp(original_zoom, zoom_progress)
		else:
			damage_duration = 0.0
			zoom = original_zoom

func shake(duration: float = 0.2, intensity: float = 10.0):
	shake_duration = duration
	shake_intensity = intensity
	shake_start_time = Time.get_ticks_msec()

func explosion_effect(duration: float = 1.0):
	explosion_duration = duration
	explosion_start_time = Time.get_ticks_msec()

func slowmo_effect(duration: float = 5.0):
	slowmo_duration = duration
	slowmo_start_time = Time.get_ticks_msec()

func shield_effect(duration: float = 5.0):
	shield_duration = duration
	shield_start_time = Time.get_ticks_msec()

func score_boost_effect(duration: float = 5.0):
	score_boost_duration = duration
	score_boost_start_time = Time.get_ticks_msec()

func damage_effect(duration: float = 0.5):
	damage_duration = duration
	damage_start_time = Time.get_ticks_msec()

func game_over_effect():
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Dramatic zoom out
	tween.tween_property(self, "zoom", original_zoom * 0.7, 1.0)
	
	# Slight shake during zoom
	tween.tween_callback(func(): 
		for i in range(10):
			shake(0.1, 5.0)
			await get_tree().create_timer(0.1).timeout
	)

func reset_camera():
	shake_duration = 0.0
	explosion_duration = 0.0
	slowmo_duration = 0.0
	shield_duration = 0.0
	score_boost_duration = 0.0
	damage_duration = 0.0
	
	position = original_position
	zoom = original_zoom
