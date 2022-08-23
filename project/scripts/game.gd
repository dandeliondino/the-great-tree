extends Node

# game state
enum states { PRELOAD, WORLD, DIALOGUE, PANEL, MENU }
var state = states.PRELOAD
var game_started = false
var debug = true

# common nodes
var camera : Camera2D
var player_camera : Camera2D
var render_components : Node2D
var inkPlayer
var Ink : Node2D
var player : KinematicBody2D
var interact_hint : Control
var Inventory : Node2D

# current
var current_interactable : Node2D
var gold : int = 0
var current_level : String
