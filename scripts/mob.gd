extends RigidBody2D

var original_speed = Vector2.ZERO
var current_scale_factor = 1.0

func _ready() -> void:
	add_to_group("mobs")
	var mob_types = Array($AnimatedSprite2D.sprite_frames.get_animation_names())
	$AnimatedSprite2D.animation = mob_types.pick_random()
	
func _process(delta: float) -> void:
	if original_speed == Vector2.ZERO and linear_velocity != Vector2.ZERO:
		original_speed = linear_velocity / current_scale_factor
	
func set_speed_scale(scale: float):
	current_scale_factor = scale
	
	if original_speed != Vector2.ZERO:
		linear_velocity = original_speed * scale
		print("Mob speed scaled by %.2f, new velocity: %s" % [scale, str(linear_velocity)])
	else:
		linear_velocity = linear_velocity * (scale / current_scale_factor) if current_scale_factor != 0 else linear_velocity * scale
		print("Mob speed scaled (fallback) by %.2f, new velocity: %s" % [scale, str(linear_velocity)])

func set_mob_scale(scale: Vector2):
	$AnimatedSprite2D.scale = scale

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
	
func kill_mob():
	queue_free()
