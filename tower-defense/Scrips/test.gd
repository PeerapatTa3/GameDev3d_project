extends Node3D
class_name Spawn_Point

@onready var PathFollow = preload("res://Mob/ufo.tscn")
@onready var FastEnemy : PackedScene = preload("res://Mob/speed_enemy.tscn")
@onready var TankEnemy : PackedScene = preload("res://Mob/tank_enemy.tscn")
@onready var Enemy : PackedScene = preload("res://Mob/enemy.tscn")

# ==============================
# 🌊 Wave Settings
# ==============================
@export var base_enemy_count : int = 5
@export var enemy_increase_per_wave : int = 2
@export var base_enemy_hp : int = 10
@export var hp_increase_per_wave : float = 1.2
@export var wave_delay : float = 5.0
@export var spawn_delay : float = 0.5
@export var spawn_timer : Timer

var can_spawn : bool = true
var enemy_spawned_this_wave : int = 0
var wave_in_progress : bool = false
var current_wave_pattern : Array = []

# ==============================
# 🧱 References
# ==============================
@export var placement_ui : Node
@export var placement_manager : Node3D

# ==============================
# 🚀 Ready
# ==============================
func _ready() -> void:
	if placement_ui and placement_ui.has_signal("tower_selected"):
		placement_ui.tower_selected.connect(placement_manager.select_tower)
	if spawn_timer:
		spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	
	GameStatus.wave = 1
	GameStatus.kills = 0
	
	start_wave()

# ==============================
# 🎮 Game Loop
# ==============================
func _process(_delta):
	game_manager()
	if GameStatus.hp <= 0:
		get_tree().change_scene_to_file("res://scenes/game_over.tscn")

func game_manager() -> void:
	# ✅ check if wave ended
	if wave_in_progress and GameStatus.enemies_remaining <= 0 and enemy_spawned_this_wave >= current_wave_pattern.size():
		wave_in_progress = false
		print("🌊 Wave", GameStatus.wave, "cleared! Next wave in", wave_delay, "seconds.")
		get_tree().create_timer(wave_delay).timeout.connect(start_next_wave)

# ==============================
# 🌊 Wave System
# ==============================
func start_wave():
	print("🌊 Starting Wave", GameStatus.wave)
	
	current_wave_pattern = generate_wave_pattern()
	enemy_spawned_this_wave = 0
	GameStatus.enemies_remaining = current_wave_pattern.size()
	
	wave_in_progress = true
	can_spawn = true
	spawn_timer.start()

func start_next_wave():
	GameStatus.wave += 1
	start_wave()

func get_enemy_hp_for_wave() -> float:
	return base_enemy_hp * pow(hp_increase_per_wave, GameStatus.wave - 1)

# ==============================
# ⚙️ Pattern Generator
# ==============================
func generate_wave_pattern() -> Array:
	var total_count = base_enemy_count + enemy_increase_per_wave * (GameStatus.wave - 1)
	var pattern : Array = []

	while pattern.size() < total_count - 1:
		var group_type = ["fast", "tank"].pick_random()
		var group_size = randi_range(2, 5)
		
		for i in range(group_size):
			if pattern.size() >= total_count - 1:
				break
			pattern.append(group_type)
	
	# ✅ last enemy = boss (scaled up)
	pattern.append("boss")
	return pattern

# ==============================
# 👾 Enemy Spawning
# ==============================
func _on_spawn_timer_timeout() -> void:
	if enemy_spawned_this_wave < current_wave_pattern.size():
		spawn_enemy(current_wave_pattern[enemy_spawned_this_wave])
	else:
		spawn_timer.stop()

func spawn_enemy(enemy_type : String):
	if not can_spawn:
		return

	var path_follow = PathFollow.instantiate()
	var enemy : Enemy

	match enemy_type:
		"fast":
			enemy = FastEnemy.instantiate()
			enemy.hp = get_enemy_hp_for_wave() * 0.8
			enemy.speed *= 1.5
		"tank":
			enemy = TankEnemy.instantiate()
			enemy.hp = get_enemy_hp_for_wave() * 2.0
			enemy.speed *= 0.6
		"boss":
			enemy = Enemy.instantiate()
			enemy.hp = get_enemy_hp_for_wave() * 5.0
			enemy.speed = enemy.speed * 0.5
			enemy.scale *= Vector3(2, 2, 2)
			print("👑 Boss spawned with HP:", enemy.hp)
		_:
			enemy = Enemy.instantiate()
			enemy.hp = get_enemy_hp_for_wave()

	# ✅ Add to scene
	$Path.add_child(path_follow)
	path_follow.add_child(enemy)

	enemy_spawned_this_wave += 1
	can_spawn = false

	# ⏳ small spawn delay
	get_tree().create_timer(spawn_delay).timeout.connect(func(): can_spawn = true)
