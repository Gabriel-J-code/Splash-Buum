extends Area2D
signal  hit
@export var speed = 400
var screen_size

signal bomba

var n_jogador = 1

var move_direita
var move_esquerda
var move_baixo
var move_cima
var b_colocar_bomba
var extra

# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	screen_size = get_viewport_rect().size
	if n_jogador == 1:
		move_direita = "j1_move_direita"
		move_esquerda = "j1_move_esquerda"
		move_baixo = "j1_move_baixo"
		move_cima = "j1_move_cima"
		b_colocar_bomba = "j1_confirma"
		extra = "j1_cancela"
	elif n_jogador == 2:
		move_direita = "j2_move_direita"
		move_esquerda = "j2_move_esquerda"
		move_baixo = "j2_move_baixo"
		move_cima = "j2_move_cima"
		b_colocar_bomba = "j2_confirma"
		extra = "j2_cancela"
		
	#hide()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed(move_direita):
		velocity.x += 1
	if Input.is_action_pressed(move_esquerda):
		velocity.x -= 1
	if Input.is_action_pressed(move_baixo):
		velocity.y += 1
	if Input.is_action_pressed(move_cima):
		velocity.y -= 1
	if Input.is_action_pressed(b_colocar_bomba):
		bomba.emit()

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
		
	#animação
	if velocity.x != 0:
		#$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.flip_v = false
		$AnimatedSprite2D.flip_h = velocity.x < 0
	#elif velocity.y != 0:
		#$AnimatedSprite2D.animation = "up"
		#$AnimatedSprite2D.flip_v = velocity.y > 0
	
func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false


func _on_body_entered(body: Node2D) -> void:
	hide()
	hit.emit()
	$CollisionShape2D.set_deferred("disabled", true)


func colocar_bomba() -> void:
	$Label.text = "bomba"
	$DelayBomba.start()


func _on_timer_timeout() -> void:
	$Label.text = ""


func _on_bomba() -> void:
	colocar_bomba()
