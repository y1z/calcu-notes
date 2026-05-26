extends Control

var text_editor: TextEdit
var text_editor_control: Control

var save_button: Button
var load_button: Button
var calc_button: Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	save_button = %save_button
	load_button = %load_button
	calc_button = %calc_button

	save_button.button_down.connect(cb_save_button)
	load_button.button_down.connect(cb_load_button)
	calc_button.button_down.connect(cb_calc_button)
	pass # Replace with function body.




func cb_save_button() -> void:
	print("save button")


func cb_load_button() -> void:
	print("load button")


func cb_calc_button() -> void:
	print("calc button")
