extends Area2D
signal hit

@export var speed = 400
@export var max_health = 5
var current_health = 5

var screen_size
var is_invincible = false
var damage_cooldown_timer = null

func _ready() -> void:
	add_to_group("player")
	screen_size = get_viewport_rect().size
	current_health = max_health
	
	damage_cooldown_timer = Timer.new()
	damage_cooldown_timer.one_shot = true
	damage_cooldown_timer.wait_time = 0.5
	add_child(damage_cooldown_timer)
	
	update_health_bar()
	hide()

func _process(delta: float) -> void:
	var velocity = get_input()
	
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		position += velocity * delta
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
	
	var sprite_size = $AnimatedSprite2D.sprite_frames.get_frame_texture("walk", 0).get_size() * $AnimatedSprite2D.scale / 2
	position.x = clamp(position.x, sprite_size.x, screen_size.x - sprite_size.x)
	position.y = clamp(position.y, sprite_size.y, screen_size.y - sprite_size.y)

	set_character_animation(velocity)

	if is_invincible or not damage_cooldown_timer.is_stopped():
		$AnimatedSprite2D.modulate.a = 0.5 if Engine.get_frames_drawn() % 10 < 5 else 1.0
		if is_invincible:
			$AnimatedSprite2D.modulate = Color(0.5, 0.5, 1.0, $AnimatedSprite2D.modulate.a)
	else:
		$AnimatedSprite2D.modulate = Color(1, 1, 1, 1)

func get_input() -> Vector2:
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("move_right"): velocity.x += 1
	if Input.is_action_pressed("move_left"): velocity.x -= 1
	if Input.is_action_pressed("move_up"): velocity.y -= 1
	if Input.is_action_pressed("move_down"): velocity.y += 1
	return velocity

func set_character_animation(velocity):
	if velocity.x != 0:
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.flip_v = false
		$AnimatedSprite2D.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$AnimatedSprite2D.animation = "up"
		$AnimatedSprite2D.flip_v = velocity.y > 0

func _on_body_entered(body: Node2D) -> void:
	if damage_cooldown_timer.is_stopped():
		take_damage(1)
		shake_camera()
		damage_cooldown_timer.start()

func take_damage(amount: int):
	if is_invincible:
		return
		
	$DamageTaken.play()
	current_health -= amount
	update_health_bar()
	
	# Enhanced damage effect with camera
	var camera = get_viewport().get_camera_2d()
	if camera and camera.has_method("damage_effect"):
		camera.damage_effect(0.5)
	
	var hurt_tween = create_tween()
	hurt_tween.tween_property($AnimatedSprite2D, "modulate", Color(1, 0.3, 0.3), 0.1)
	hurt_tween.tween_property($AnimatedSprite2D, "modulate", Color(1, 1, 1), 0.1)

	if current_health <= 0:
		hide()
		hit.emit()
		$CollisionShape2D.set_deferred("disabled", true)

func start(pos):
	position = pos
	current_health = max_health
	update_health_bar()
	show()
	$CollisionShape2D.disabled = false

func activate_shield():
	$ActivateShield.play()
	is_invincible = true
	await get_tree().create_timer(5.0).timeout
	is_invincible = false

func update_health_bar():
	var hud = get_tree().get_nodes_in_group("hud")
	if hud.size() > 0:
		hud[0].update_health(current_health, max_health)
		return

func shake_camera():
	var camera = get_viewport().get_camera_2d()
	if camera and camera.has_method("shake"):
		camera.shake(0.2, 15)
	else:
		# Fallback shake if new camera methods aren't available
		var original_position = get_viewport().get_camera_2d().position
		var shake_tween = create_tween()
		shake_tween.tween_property(get_viewport().get_camera_2d(), "position", original_position + Vector2(10, 0), 0.05)
		shake_tween.tween_property(get_viewport().get_camera_2d(), "position", original_position - Vector2(10, 0), 0.05)
		shake_tween.tween_property(get_viewport().get_camera_2d(), "position", original_position, 0.05)
