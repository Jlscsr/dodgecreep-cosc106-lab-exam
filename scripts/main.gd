extends Node

@export var mob_scene: PackedScene

@onready var player = $Player
@onready var mob_timer = $MobTimer
@onready var power_up_spawner = $PowerUpSpawner
@onready var score_timer = $ScoreTimer
@onready var start_timer = $StartTimer
@onready var hud = $HUD
@onready var camera = $Camera2D
@onready var difficulty_timer = $DifficultyTimer 

var screen_size: Vector2
var score
var current_difficulty: String = "easy"

var mob
var mob_direction

# Base values for different difficulties
var base_mob_speed_multiplier: float = 1.0
var base_spawn_interval: float = 1.5
var base_mob_scale: Vector2 = Vector2(1.0, 1.0)

# Maximum values for each difficulty
var max_mob_speed_multiplier: float = 2.0
var max_mob_scale: Vector2 = Vector2(1.5, 1.5)
var min_spawn_interval: float = 0.5

var current_mob_speed_multiplier: float = 1.0
var current_spawn_interval: float = 1.5
var current_mob_scale: Vector2 = Vector2(1.0, 1.0)

# Slowmo effect tracking
var is_slowmo_active: bool = false
var slowmo_scale: float = 0.3

# Difficulty progression
var difficulty_progression_time: float = 15.0

func _ready() -> void:
	screen_size = get_viewport().get_visible_rect().size
	connect_signals()
	if hud:
		hud.add_to_group("hud")
	
	if not difficulty_timer:
		difficulty_timer = Timer.new()
		difficulty_timer.name = "DifficultyTimer"
		difficulty_timer.wait_time = difficulty_progression_time
		difficulty_timer.autostart = false
		add_child(difficulty_timer)
	
	if not difficulty_timer.timeout.is_connected(_on_difficulty_timer_timeout):
		difficulty_timer.timeout.connect(_on_difficulty_timer_timeout)
	
	print("Difficulty timer setup complete. Wait time: %.1f seconds" % difficulty_timer.wait_time)

func connect_signals() -> void:
	player.hit.connect(game_over)
	mob_timer.timeout.connect(_on_mob_timer_timeout)
	score_timer.timeout.connect(_on_score_timer_timeout)
	power_up_spawner.powerup_picked_up.connect(_on_powerup_picked_up)
	start_timer.timeout.connect(_on_start_timer_timeout)
	hud.start_game.connect(start_game_with_difficulty)

func start_game_with_difficulty(difficulty: String) -> void:
	current_difficulty = difficulty

	match difficulty:
		"easy":
			base_mob_speed_multiplier = 0.6
			base_spawn_interval = 2.5
			base_mob_scale = Vector2(0.6, 0.6)
			# Easy difficulty caps
			max_mob_speed_multiplier = 1.2  # 2x increase from base (0.6 -> 1.2)
			max_mob_scale = Vector2(0.9, 0.9)  # 1.5x increase from base (0.6 -> 0.9)
			min_spawn_interval = 1.0  # Slowest minimum spawn rate
		"medium":
			base_mob_speed_multiplier = 0.8
			base_spawn_interval = 2.0
			base_mob_scale = Vector2(0.8, 0.8)
			# Medium difficulty caps
			max_mob_speed_multiplier = 1.8  # 2.25x increase from base (0.8 -> 1.8)
			max_mob_scale = Vector2(1.2, 1.2)  # 1.5x increase from base (0.8 -> 1.2)
			min_spawn_interval = 0.7  # Moderate minimum spawn rate
		"hard":
			base_mob_speed_multiplier = 1.0
			base_spawn_interval = 1.5
			base_mob_scale = Vector2(1.0, 1.0)
			# Hard difficulty caps
			max_mob_speed_multiplier = 2.5  # 2.5x increase from base (1.0 -> 2.5)
			max_mob_scale = Vector2(1.5, 1.5)  # 1.5x increase from base (1.0 -> 1.5)
			min_spawn_interval = 0.3  # Fastest minimum spawn rate

	current_mob_speed_multiplier = base_mob_speed_multiplier
	current_spawn_interval = base_spawn_interval
	current_mob_scale = base_mob_scale

	new_game()

func _on_difficulty_timer_timeout():
	# Store old values for comparison
	var old_speed = current_mob_speed_multiplier
	var old_interval = current_spawn_interval
	var old_scale = current_mob_scale
	
	# Check if we've reached the caps for this difficulty
	var speed_at_cap = current_mob_speed_multiplier >= max_mob_speed_multiplier
	var interval_at_cap = current_spawn_interval <= min_spawn_interval
	var scale_at_cap = current_mob_scale.x >= max_mob_scale.x
	
	if speed_at_cap and interval_at_cap and scale_at_cap:
		difficulty_timer.start()
		return
	
	# Apply increases with caps
	if not speed_at_cap:
		current_mob_speed_multiplier = min(current_mob_speed_multiplier * 1.12, max_mob_speed_multiplier)  # 12% increase
	
	if not interval_at_cap:
		current_spawn_interval = max(current_spawn_interval * 0.92, min_spawn_interval)  # 8% faster spawning
	
	if not scale_at_cap:
		current_mob_scale = Vector2(
			min(current_mob_scale.x * 1.06, max_mob_scale.x),  # 6% bigger
			min(current_mob_scale.y * 1.06, max_mob_scale.y)
		)
	
	# Update mob timer with new spawn interval
	mob_timer.wait_time = current_spawn_interval
	
	difficulty_timer.start()

func game_over() -> void:
	print("Game over - stopping all timers")
	power_up_spawner.is_game_active = false
	score_timer.stop()
	mob_timer.stop()
	
	# Stop difficulty timer
	if difficulty_timer:
		difficulty_timer.stop()
		print("Difficulty timer stopped")
	
	power_up_spawner.spawner_reset()
	hud.reset_powerup_hud()
	
	# Reset slowmo state
	is_slowmo_active = false
	
	# Dramatic game over camera effect
	if camera and camera.has_method("game_over_effect"):
		camera.game_over_effect()
	
	hud.show_game_over()
	$BGMusic.stop()
	$DeathSound.play()

func new_game():
	power_up_spawner.is_game_active = true
	score = 0
	is_slowmo_active = false
	
	player.start($StartPosition.position)
	hud.update_health(player.current_health, player.max_health)
	
	mob_timer.wait_time = current_spawn_interval
	start_timer.start()
	hud.update_score(score)
	hud.show_message("Get Ready")
	
	# Reset camera effects
	if camera and camera.has_method("reset_camera"):
		camera.reset_camera()
	
	$BGMusic.play()
	get_tree().call_group("mobs", "queue_free")

func _on_mob_timer_timeout() -> void:
	mob = mob_scene.instantiate()

	var mob_spawn_location = $MobPath/MobSpawnLocation
	mob_spawn_location.progress_ratio = randf()
	mob.position = mob_spawn_location.position

	mob_direction = mob_spawn_location.rotation + PI / 2
	mob_direction += randf_range(-PI / 4, PI / 4)
	mob.rotation = mob_direction

	# Calculate base velocity first
	var base_velocity = Vector2(randf_range(150.0, 250.0), 0.0) * current_mob_speed_multiplier
	var final_velocity = base_velocity.rotated(mob_direction)
	
	# Set the mob's original speed BEFORE applying any effects
	mob.original_speed = final_velocity
	
	# Apply slowmo if active
	if is_slowmo_active:
		final_velocity *= slowmo_scale
	
	mob.linear_velocity = final_velocity

	# Set mob scale based on current difficulty
	mob.set_mob_scale(current_mob_scale)

	add_child(mob)

func _on_score_timer_timeout() -> void:
	score += 1
	hud.update_score(score)
	
	# Add subtle camera effect for score milestones
	if score % 10 == 0 and camera and camera.has_method("shake"):
		camera.shake(0.1, 3.0)  # Gentle celebration shake

func _on_start_timer_timeout() -> void:
	print("Game started! Starting all timers...")
	mob_timer.start()
	score_timer.start()
	
	# Make sure difficulty timer starts
	if difficulty_timer:
		difficulty_timer.start()
		print("Difficulty timer started. Next increase in %.1f seconds" % difficulty_timer.wait_time)
	else:
		print("ERROR: Difficulty timer not found!")
	
	power_up_spawner.start_spawning()

func _on_powerup_picked_up(type: String) -> void:
	var powerup_duration = 5.0
	hud.show_powerup_timer(type, powerup_duration)
	
	match type:
		"shield":
			player.activate_shield()
			# Shield camera effect
			if camera and camera.has_method("shield_effect"):
				camera.shield_effect(powerup_duration)
			
		"slowmo":
			# Slowmo camera effect
			if camera and camera.has_method("slowmo_effect"):
				camera.slowmo_effect(powerup_duration)
			
			activate_slowmo(powerup_duration)
			
		"explode":
			$Player/ExplosionSound.play()
			
			# DRAMATIC EXPLOSION CAMERA EFFECT
			if camera and camera.has_method("explosion_effect"):
				camera.explosion_effect(1.0)
			if camera and camera.has_method("shake"):
				camera.shake(0.8, 25.0)  # Intense shake
			
			create_explosion_flash()
			
			kill_all_mobs()
			
		"score_boost":
			# Score boost camera effect
			if camera and camera.has_method("score_boost_effect"):
				camera.score_boost_effect(powerup_duration)
			
			var original_wait_time = score_timer.wait_time
			score_timer.wait_time = original_wait_time / 2
			score_timer.start()
			await get_tree().create_timer(powerup_duration).timeout  
			score_timer.wait_time = original_wait_time
			score_timer.start()
		_:
			return

func activate_slowmo(duration: float):
	print("Activating slowmo for %.1f seconds" % duration)
	is_slowmo_active = true
	slow_all_mobs()
	
	await get_tree().create_timer(duration).timeout
	
	print("Deactivating slowmo")
	is_slowmo_active = false
	restore_all_mobs()

func create_explosion_flash():
	var flash = ColorRect.new()
	flash.color = Color(1, 1, 1, 0.8)
	flash.size = get_viewport().get_visible_rect().size
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	get_tree().current_scene.add_child(flash)
	
	var tween = create_tween()
	tween.tween_property(flash, "color:a", 0.0, 0.3)
	tween.tween_callback(flash.queue_free)

func slow_all_mobs():
	print("Slowing all existing mobs")
	for mob in get_tree().get_nodes_in_group("mobs"):
		if mob.has_method("set_speed_scale"):
			mob.set_speed_scale(slowmo_scale)

func restore_all_mobs():
	print("Restoring speed to all mobs")
	for mob in get_tree().get_nodes_in_group("mobs"):
		if mob.has_method("set_speed_scale"):
			mob.set_speed_scale(1.0)

func kill_all_mobs():
	for mob in get_tree().get_nodes_in_group("mobs"):
		if mob.has_method("kill_mob"):
			mob.kill_mob()
