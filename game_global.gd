extends Node
class_name GameGlobal

var kills := 0
var time_in_game := "00:00:00"
var day_night_time := 0


func update_kills() -> void:
	self.kills+=1

func clean_scores() -> void:
	self.kills = 0
	self.time_in_game = "00:00:00"

func update_time(t:String) -> void:
	self.time_in_game = t
	
func get_score() -> Dictionary:
	return {
		kills = kills,
		time_in_game = time_in_game
	}
