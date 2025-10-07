extends Node
class_name GameStats

var hp : int
var coin : int
var kill : int
var wave : int

func _ready() -> void:
	coin = 100
	hp = 10
