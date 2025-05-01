extends Node

signal powerup_picked_up

@export var powerup_scene: PackedScene
@export var spawn_interval := 10.0
@export var powerup_types := ["shield", "slowmo", "explode", "score_boost"]

@onready var spawn_timer = $SpawnTimer
@onready var despawn_timer = $DespawnTimer

var powerup: Area2D
var is_game_active := true

func _ready():
	connect_signals()
	randomize()
	
func _process(delta: float) -> void:
	pass
	
func connect_signals():
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	despawn_timer.timeout.connect(_on_despawn_timer_timeout)
	
func start_spawning():
	spawn_timer.start()

func spawn_power_up():
	var chosen_type = powerup_types[randi() % powerup_types.size()]
	powerup = powerup_scene.instantiate()
	
	add_child(powerup)
	
	powerup.set_powerup_type(chosen_type)
	powerup.position = set_powerup_position()
	
	powerup.picked_up.connect(_on_powerup_picked)

func set_powerup_position() -> Vector2:
	var padding = 32
	var screen_size = get_viewport().get_visible_rect().size
	
	return Vector2(
		padding + randf() * (screen_size.x - 2 * padding),
		padding + randf() * (screen_size.y - 2 * padding)
	)

func _on_spawn_timer_timeout():
	spawn_power_up()
	spawn_timer.stop()
	
	despawn_timer.start()

func _on_despawn_timer_timeout():
	powerup.clear_powerup()
	despawn_timer.stop()
	spawn_timer.start()
	
func _on_powerup_picked(type: String) -> void:
	despawn_timer.stop()
	emit_signal("powerup_picked_up", type)
	
	await get_tree().create_timer(7.0).timeout
	
	if not is_inside_tree() or not is_instance_valid(self):
		return 
	
	if is_game_active:
		spawn_timer.start() 
	
func spawner_reset():
	spawn_timer.stop()
	despawn_timer.stop()
	
	if is_instance_valid(powerup):
		powerup.clear_powerup()
