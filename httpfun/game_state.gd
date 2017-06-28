extends Node
# Member variables
var mail_score = 10
var enemy_score = 12

# Bootstrapping scores; best_time == 9999 initially 
var best_time = 99999999
var best_score = 100
var user_time_completed = 200

# Seconds to delay before changing scene
var game_over_delay_scene_change=3

func setup_game():
	# Want to get highest number of mails collected (mail_score) before killing all enemies (enemy_score)
	# When enemy_score == 0, game over!
	mail_score = 0
	enemy_score = 2
	user_time_completed = 0
	#print("Resetting game state: ", mail_score,enemy_score,user_time_completed)


func _ready():
	var f = File.new()
	#Load high score will be saved to : C:\Users\<USER>\AppData\Roaming\Godot\app_userdata\ 
	# Not sure of file save location after exporting to HTML5
	if (f.open("user://highscore", File.READ) == OK):
		best_time = f.get_var()
		best_score = f.get_var()

func game_over():
	get_node("/root/stage/player/hud/game_over").show()
	get_node("/root/stage/player").stop()
	
	#get_node("/root/stage/player/hud/restartButton").show()
	# stop updates to timer + game state
	get_node("/root/stage/player/hud/timer").stopTimer()
	
	#Execute function to change scene to game_complete
	##### timeout delay before change to game complete #####
	var timeout_complete = Timer.new()
	timeout_complete.set_wait_time(game_over_delay_scene_change)
	timeout_complete.set_one_shot(true)
	self.add_child(timeout_complete)
	timeout_complete.start()
	yield(timeout_complete, "timeout")
	print("Changing to Game Complete scene")
	
	#change scene to game complete
	get_tree().change_scene("res://game_complete.tscn")


func game_over_file_save():
	# set BEST score = mail score (number of mails user collected) if it is higher
	if(mail_score > best_score):
		best_score = mail_score
		print("SAVING BEST SCORE: ", best_score)
	#if (user_time_completed < best_time):
		best_time = user_time_completed
		print("SAVING BEST TIME: ", best_time)
		# Save high score / best time
		var f = File.new()
		f.open("user://highscore", File.WRITE)
		f.store_var(best_time)
		f.store_var(best_score)
	elif(mail_score == best_score):
		#print("mail score == current highest score, checking if faster time")
		# if user_time_completed in FASTER time than the best time, update it
		if (user_time_completed < best_time):
			best_time = user_time_completed
			print("SAVING BEST TIME: ", best_time)
		# Save high score / with updated best time
			var f = File.new()
			f.open("user://highscore", File.WRITE)
			f.store_var(best_time)
			f.store_var(best_score)