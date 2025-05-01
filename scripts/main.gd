extends Node

@export var mob_scene: PackedScene

@onready var player = $Player
@onready var mob_timer = $MobTimer
@onready var power_up_spawner = $PowerUpSpawner
@onready var score_timer = $ScoreTimer
@onready var start_timer = $StartTimer
@onready var hud = $HUD

var screen_size: Vector2
var score
var current_difficulty: String = "easy"

var mob
var mob_direction

var mob_speed_multiplier: float = 1.2
var spawn_interval: float = 1.2

func _ready() -> void:
	screen_size = get_viewport().get_visible_rect().size
	connect_signals()
	if hud:
		hud.add_to_group("hud")

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
			mob_speed_multiplier = 0.6
			spawn_interval = 2.0
		"medium":
			mob_speed_multiplier = 0.8
			spawn_interval = 1.5
		"hard":
			mob_speed_multiplier = 1.0
			spawn_interval = 1.0

	new_game()


func game_over() -> void:
	power_up_spawner.is_game_active = false
	score_timer.stop()
	mob_timer.stop()
	power_up_spawner.spawner_reset()
	hud.reset_powerup_hud()
	hud.show_game_over()
	$BGMusic.stop()
	$DeathSound.play()

func new_game():
	power_up_spawner.is_game_active = true
	score = 0
	player.start($StartPosition.position)
	hud.update_health(player.current_health, player.max_health)
	mob_timer.wait_time = spawn_interval
	start_timer.start()
	hud.update_score(score)
	hud.show_message("Get Ready")
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

	var velocity = Vector2(randf_range(150.0, 250.0), 0.0) * mob_speed_multiplier
	mob.linear_velocity = velocity.rotated(mob_direction)

	match current_difficulty:
		"easy":
			mob.set_mob_scale(Vector2(0.6, 0.6))
		"medium":
			mob.set_mob_scale(Vector2(0.8, 0.8))
		"hard":
			mob.set_mob_scale(Vector2(1.0, 1.0))  

	add_child(mob)

func _on_score_timer_timeout() -> void:
	score += 1
	hud.update_score(score)

func _on_start_timer_timeout() -> void:
	mob_timer.start()
	score_timer.start()
	power_up_spawner.start_spawning()

func _on_powerup_picked_up(type: String) -> void:
	var powerup_duration = 5.0
	hud.show_powerup_timer(type, powerup_duration)
	match type:
		"shield":
			player.activate_shield()
		"slowmo":
			slow_all_mobs()
			await get_tree().create_timer(powerup_duration).timeout
			restore_all_mobs()
		"explode":
			kill_all_mobs()
		"score_boost":
			var original_wait_time = score_timer.wait_time
			score_timer.wait_time = original_wait_time / 2
			score_timer.start()
			await get_tree().create_timer(powerup_duration).timeout  
			score_timer.wait_time = original_wait_time
			score_timer.start()
		_:
			return

func slow_all_mobs():
	for mob in get_tree().get_nodes_in_group("mobs"):
		if mob.has_method("set_speed_scale"):
			mob.set_speed_scale(0.3)

func restore_all_mobs():
	for mob in get_tree().get_nodes_in_group("mobs"):
		if mob.has_method("set_speed_scale"):
			mob.set_speed_scale(1.0)

func kill_all_mobs():
	for mob in get_tree().get_nodes_in_group("mobs"):
		if mob.has_method("kill_mob"):
			mob.kill_mob()
