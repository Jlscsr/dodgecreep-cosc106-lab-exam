extends Area2D

signal picked_up

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

var powerup_type := "none"

func _ready():
	pass

func set_powerup_type(type: String):
	powerup_type = type
	_update_sprite_by_type(type)

func _update_sprite_by_type(type: String):
	match type:
		"shield":
			sprite.texture = preload("res://art/powerups/shield_powerup.png")
		"slowmo":
			sprite.texture = preload("res://art/powerups/slowmo_powerup.png")
		"explode":
			sprite.texture = preload("res://art/powerups/bomb_powerup.png")
		"score_boost":
			sprite.texture = preload("res://art/powerups/scoreboost_powerup.png")
		_:
			sprite.texture = null
			
func _on_area_entered(area: Area2D) -> void:
	emit_signal("picked_up", powerup_type)
	clear_powerup()

func clear_powerup():
	queue_free()
