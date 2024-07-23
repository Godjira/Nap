extends Node

var some_data = {}

var max_tiles = [200, 300, 400, 500, 600, 1000, 1100, 1200, 1400, 2000, 2100, 2200]
var level = 0

func set_data(key, value):
	some_data[key] = value

func get_max_tiles() -> int:
	level += 1
	return max_tiles[level - 1]

func get_data(key):
	return some_data.get(key, null)
