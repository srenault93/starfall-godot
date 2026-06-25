extends Node2D
## Starfall - a small arcade dodge game.
##
## Move a ship left and right to dodge an accelerating stream of falling
## blocks. Score climbs with survival time and the spawn rate and fall
## speed ramp up the longer you last. Everything is drawn immediately in
## _draw(); there are no external assets.

const WIDTH := 720.0
const HEIGHT := 900.0
const PLAYER_SIZE := Vector2(46, 46)
const PLAYER_SPEED := 540.0

var state := "menu"  # menu | playing | gameover
var player_pos: Vector2
var enemies: Array = []  # each: { pos: Vector2, vel: float, size: Vector2 }
var score := 0.0
var best := 0.0
var elapsed := 0.0
var spawn_timer := 0.0
var spawn_interval := 0.9
var fall_speed := 240.0

var _rng := RandomNumberGenerator.new()
var _font: Font

func _ready() -> void:
	_rng.randomize()
	_font = ThemeDB.fallback_font
	reset_game()

func reset_game() -> void:
	player_pos = Vector2(WIDTH / 2.0 - PLAYER_SIZE.x / 2.0, HEIGHT - 120.0)
	enemies.clear()
	score = 0.0
	elapsed = 0.0
	spawn_timer = 0.0
	spawn_interval = 0.9
	fall_speed = 240.0

func _process(delta: float) -> void:
	match state:
		"menu":
			if Input.is_action_just_pressed("ui_accept"):
				reset_game()
				state = "playing"
		"playing":
			_update_playing(delta)
		"gameover":
			if Input.is_action_just_pressed("ui_accept"):
				reset_game()
				state = "playing"
	queue_redraw()

func _update_playing(delta: float) -> void:
	elapsed += delta
	score = elapsed * 10.0

	# Difficulty ramps with time survived.
	fall_speed = 240.0 + elapsed * 14.0
	spawn_interval = max(0.28, 0.9 - elapsed * 0.02)

	var dir := 0.0
	if Input.is_action_pressed("ui_left"):
		dir -= 1.0
	if Input.is_action_pressed("ui_right"):
		dir += 1.0
	player_pos.x = clampf(player_pos.x + dir * PLAYER_SPEED * delta, 0.0, WIDTH - PLAYER_SIZE.x)

	spawn_timer -= delta
	if spawn_timer <= 0.0:
		spawn_timer = spawn_interval
		_spawn_enemy()

	for e in enemies:
		e.pos.y += e.vel * delta

	# Drop anything that has fallen off the bottom.
	var kept: Array = []
	for e in enemies:
		if e.pos.y <= HEIGHT:
			kept.append(e)
	enemies = kept

	var player_rect := Rect2(player_pos, PLAYER_SIZE)
	for e in enemies:
		if player_rect.intersects(Rect2(e.pos, e.size)):
			best = maxf(best, score)
			state = "gameover"
			break

func _spawn_enemy() -> void:
	var w := _rng.randf_range(38.0, 84.0)
	var x := _rng.randf_range(0.0, WIDTH - w)
	enemies.append({
		"pos": Vector2(x, -w),
		"vel": fall_speed * _rng.randf_range(0.85, 1.2),
		"size": Vector2(w, w),
	})

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(WIDTH, HEIGHT)), Color(0.04, 0.04, 0.08))

	for e in enemies:
		draw_rect(Rect2(e.pos, e.size), Color(1.0, 0.35, 0.42))

	if state != "menu":
		draw_rect(Rect2(player_pos, PLAYER_SIZE), Color(0.45, 0.85, 1.0))

	var white := Color(0.92, 0.92, 0.95)
	var dim := Color(0.55, 0.55, 0.62)
	match state:
		"playing":
			draw_string(_font, Vector2(20, 44), "SCORE %d" % int(score),
				HORIZONTAL_ALIGNMENT_LEFT, -1, 26, white)
		"menu":
			_draw_centered("STARFALL", 70, white, -40.0)
			_draw_centered("Arrow keys to move   -   Enter to start", 24, dim, 36.0)
		"gameover":
			_draw_centered("GAME OVER", 70, white, -40.0)
			_draw_centered("Score %d    Best %d    -    Enter to retry" % [int(score), int(best)],
				24, dim, 36.0)

func _draw_centered(text: String, size: int, color: Color, y_offset: float) -> void:
	var w := _font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	draw_string(_font, Vector2(WIDTH / 2.0 - w / 2.0, HEIGHT / 2.0 + y_offset),
		text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)
