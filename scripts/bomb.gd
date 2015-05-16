extends Node2D

# Nodes
var global
var player

# Member variables
var cell_pos				# Bomb tilemap coordinates
var bomb_range				# Range of the bomb explosion
var counter = 1

var chained_bombs = []		# Bombs triggered by the chain reaction
var anim_ranges = {}		# Explosion range for each direction
var flame_cells = []		# Coordinates and orientation of the cells with flame animation
var destruct_cells = []		# Coordinates of the destructible cells in range
var indestruct_cells = []	# Coordinates of the destructible cells in range

func _on_TimerIdle_timeout():
	self.get_node("AnimatedSprite/AnimationPlayer").play("countdown")

func _on_AnimationPlayer_finished():
	# Find collisions and act accordingly
	global.bomb_manager.find_chain_and_collisions(self)
	# Free bomb spots for the players as soon as they are triggered
	for bomb in self.chained_bombs:
		if (bomb.player extends global.player_script):
			bomb.player.active_bombs -= 1
	if (self.player extends global.player_script):
		self.player.active_bombs -= 1
	# Register as exploding bomb
	global.bomb_manager.exploding_bombs.append(self)
	# Play animation corresponding to the explosion of self and its chain reaction
	global.bomb_manager.start_animation(self)

func _on_TimerAnim_timeout():
	if (counter < 4):
		global.bomb_manager.update_animation(self)
		counter += 1
		get_node("AnimatedSprite/TimerAnim").start()
	else:
		global.bomb_manager.stop_animation(self)
		
		# Free chained bombs and trigger bomb
		for bomb in self.chained_bombs:
			if (bomb.player extends global.player_script):
				bomb.player.bomb_collision_exceptions.erase(bomb)
			bomb.queue_free()
		if (self.player extends global.player_script):
			self.player.bomb_collision_exceptions.erase(self)
		global.bomb_manager.exploding_bombs.erase(self)
		self.queue_free()

func _ready():
	# Initialisations
	global = get_node("/root/global")
