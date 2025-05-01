extends CanvasLayer

signal start_game(difficulty: String)

@onready var message = $Message
@onready var message_timer = $MessageTimer
@onready var start_button = $StartButton
@onready var score_label = $ScoreLabel
@onready var made_by = $MadeBy
@onready var section = $Section
@onready var difficulty_buttons = $DifficultyButtons
@onready var easy_button = $DifficultyButtons/EasyButton
@onready var medium_button = $DifficultyButtons/MediumButton
@onready var hard_button = $DifficultyButtons/HardButton
@onready var heart_container = $HeartContainer

var heart_full_texture: Texture
var heart_empty_texture: Texture

func _ready() -> void:
	for container in $PowerUpHUD.get_children():
		container.visible = false
	show_credits(true)
	difficulty_buttons.visible = false
	connect_difficulty_signals()
	
	heart_full_texture = preload("res://art/heart_full.png")
	heart_empty_texture = preload("res://art/heart_empty.png")
	
	if !heart_container:
		heart_container = HBoxContainer.new()
		heart_container.name = "HeartContainer"
		add_child(heart_container)
	
	heart_container.position = Vector2(get_viewport().size.x - 160, 120)
	heart_container.add_theme_constant_override("separation", 8)

func connect_difficulty_signals():
	easy_button.pressed.connect(func(): _on_difficulty_selected("easy"))
	medium_button.pressed.connect(func(): _on_difficulty_selected("medium"))
	hard_button.pressed.connect(func(): _on_difficulty_selected("hard"))

func _on_start_button_pressed() -> void:
	start_button.hide()
	message.text = ""
	show_credits(false)
	difficulty_buttons.visible = true

func _on_difficulty_selected(difficulty: String):
	difficulty_buttons.visible = false
	start_game.emit(difficulty)

func show_message(text: String) -> void:
	message.text = text
	message.show()
	message_timer.start()
	await message_timer.timeout
	message.text = ""

func show_game_over() -> void:
	await show_message("Game Over")
	message.text = "Dodge the Creeps!"
	message.show()
	show_credits(true)
	await get_tree().create_timer(1.0).timeout
	start_button.show()

func update_score(score: int) -> void:
	score_label.text = str(score)

func show_powerup_timer(name: String, duration: float) -> void:
	var container = null
	match name:
		"shield":
			container = $PowerUpHUD/ShieldContainer
		"slowmo":
			container = $PowerUpHUD/SlowmoContainer
		"score_boost":
			container = $PowerUpHUD/ScoreBoostContainer
		_:
			return
	
	if container == null or not is_instance_valid(container):
		return

	container.visible = true
	var timer_label = container.get_node("TimerLabel")

	for i in duration as int:
		timer_label.text = str(duration - i) + "s"
		await get_tree().create_timer(1.0).timeout

	container.visible = false

func reset_powerup_hud():
	for container in $PowerUpHUD.get_children():
		container.visible = false

func update_health(current: int, max: int):
	for child in heart_container.get_children():
		child.queue_free()
		
	if !heart_container.visible:
		heart_container.visible = true
	
	for i in range(max):
		var heart = TextureRect.new()
		heart.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		heart.custom_minimum_size = Vector2(24, 24)
		heart.expand_mode = TextureRect.EXPAND_KEEP_SIZE
		heart.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		
		if i < current:
			heart.texture = heart_full_texture
		else:
			heart.texture = heart_empty_texture
		
		heart_container.add_child(heart)
	
	if current < max:
		show_damage_indicator()

func show_damage_indicator():
	var damage_flash = ColorRect.new()
	damage_flash.color = Color(1, 0, 0, 0.3)
	damage_flash.size = get_viewport().get_visible_rect().size
	damage_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(damage_flash)
	
	var tween = create_tween()
	tween.tween_property(damage_flash, "color:a", 0.0, 0.5)
	tween.tween_callback(damage_flash.queue_free)

func show_credits(is_visible: bool):
	made_by.visible = is_visible
	section.visible = is_visible

func _on_message_timer_timeout() -> void:
	start_button.hide()
