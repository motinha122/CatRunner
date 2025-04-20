extends Node

var stump_scene = preload("res://Cenas/stump.tscn")
var rock_scene = preload("res://Cenas/rock.tscn")
var barrel_scene = preload("res://Cenas/barrel.tscn")
var bird_scene = preload("res://Cenas/bird.tscn")
var obstacle_types := [stump_scene, rock_scene, barrel_scene]
var obstacles : Array
var bird_heights := [200,390]
var difficulty : int

var hud_highscore_pos : int 
var hud_highscorepoints_pos : int 
var hud_score_pos : int

const MAX_DIFFICULTY : int = 2
const CAT_START_POS := Vector2i(150, 485)
const CAM_START_POS := Vector2i(576, 324)
const SCORE_MODIFIER : int = 10 
const START_SPEED : float = 10.0
const MAX_SPEED : int = 10
const SPEED_MODIFIER : int = 5000

var game_started : bool = false
var high_score : int 
var score : int
var speed : float
var screen_size: Vector2i
var ground_height : int 
var last_obs

func _ready() -> void:
	screen_size = get_window().size
	hud_highscore_pos = $HUD.get_node("HighScoreLabel").position.x
	hud_score_pos = $HUD.get_node("ScoreLabel").position.x
	hud_highscorepoints_pos = $HUD.get_node("HighScorePoints").position.x
	ground_height = $Ground.get_node("Sprite2D").texture.get_height()
	$GameOver.get_node("Button").pressed.connect(new_game)
	new_game()

func new_game():
	score = 0
	difficulty = 0
	game_started = false
	get_tree().paused = false
	
	for obs in obstacles:
		obs.queue_free()
	obstacles.clear()
	
	$Miar.position = CAT_START_POS
	$Miar.velocity = Vector2i(0, 0)
	$Camera2D.position = CAM_START_POS
	$Ground.position = Vector2i(0, 0)
	$HUD.get_node("ScoreLabel").position.x = hud_score_pos
	$HUD.get_node("HighScoreLabel").position.x = hud_highscore_pos
	$HUD.get_node("HighScorePoints").position.x = hud_highscorepoints_pos
	print("screen_size_x: ", screen_size.x)
	print("screen_size_y: ", screen_size.y)
	print(" ")
	$GameOver.hide()

func _process(delta: float) -> void:
	if game_started:
		check_high_score()
		adjust_difficulty()
		speed = START_SPEED + score / SPEED_MODIFIER
		if speed > MAX_SPEED:
			speed = MAX_SPEED
		
		generate_obs()
		
		$Miar.position.x += speed
		$Camera2D.position.x += speed
		$HUD.get_node("ScoreLabel").position.x += speed
		$HUD.get_node("HighScoreLabel").position.x += speed
		$HUD.get_node("HighScorePoints").position.x += speed
		
		score += speed
		show_score()
		
		print("Score: ",score)
		print("Camera2d: ",$Camera2D.position.x)
		print("Ground: ",$Ground.position.x)
		print(" ")

		if $Camera2D.position.x - $Ground.position.x > screen_size.x * 1.5:
			$Ground.position.x += screen_size.x
	elif Input.is_action_pressed("ui_accept"):
		game_started = true

func generate_obs():
	if obstacles.is_empty() or last_obs.position.x < score + randi_range(300, 500):
		var obs_type = obstacle_types[randi() % obstacle_types.size()]
		var obs 
		var max_obs = difficulty + 1
		for i in range(randi() % max_obs + 1):
			obs = obs_type.instantiate()
			var obs_height = obs.get_node("Sprite2D").texture.get_height()
			var obs_scale = obs.get_node("Sprite2D").scale
			var obs_x : int = screen_size.x + score + 100 + (i * 100)
			var obs_y : int = screen_size.y - ground_height - ((obs_height * obs_scale.y) / 2) + 5
			last_obs = obs
			add_obs(obs, obs_x, obs_y)
		if difficulty == MAX_DIFFICULTY:
			if(randi() % 2) == 0:
				obs = bird_scene.instantiate()
				var obs_x : int = screen_size.x + score + 100
				var obs_y : int = bird_heights[randi() % bird_heights.size()]
				add_obs(obs, obs_x, obs_y)

func add_obs(obs, x, y):
	obs.position = Vector2i(x, y)
	obs.body_entered.connect(hit_obs)
	add_child(obs)
	obstacles.append(obs)

func hit_obs(body):
	if body.name == "Miar":
		game_over()
		print("Collision")

func show_score():
	$HUD.get_node("ScoreLabel").text = "SCORE: " + str(score / SCORE_MODIFIER) 
	

func check_high_score():
	if score > high_score:
		high_score = score
		$HUD.get_node("HighScorePoints").text = str(high_score / SCORE_MODIFIER)

func adjust_difficulty():
	difficulty = score / SPEED_MODIFIER
	if difficulty > MAX_DIFFICULTY:
		difficulty = MAX_DIFFICULTY

func game_over():
	get_tree().paused = true
	game_started = false
	$GameOver.show()
