extends RigidBody2D

var base_speed = Vector2.ZERO

func _ready() -> void:
	var mob_types = Array($AnimatedSprite2D.sprite_frames.get_animation_names())
	$AnimatedSprite2D.animation = mob_types.pick_random()
	base_speed = linear_velocity

func _process(delta: float) -> void:
	pass
	
func set_speed_scale(scale: float):
	linear_velocity = base_speed * scale
	
func set_mob_scale(scale: Vector2):
	$AnimatedSprite2D.scale = scale

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
	
func kill_mob():
	queue_free()
