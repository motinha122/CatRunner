extends CharacterBody2D

const GRAVITY : int = 4200
const JUMP_SPEED : int = -1800

func _physics_process(delta: float) -> void:
	velocity.y += GRAVITY * delta
	if is_on_floor():
		if not get_parent().game_started:
			$AnimatedSprite2D.play("Idle")
			pass
		else:
			$RunCol.disabled = false
			if Input.is_action_pressed("ui_accept"):
				velocity.y = JUMP_SPEED
				#$JumpSound.play()
			elif Input.is_action_pressed("ui_down"):
				$AnimatedSprite2D.play("Duck")
				$RunCol.disabled = true
			else:
				$AnimatedSprite2D.play("Run")
	else:
		$AnimatedSprite2D.play("Jump")
		
	move_and_slide()
