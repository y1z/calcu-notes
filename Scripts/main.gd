extends Control


var text_editor: TextEdit
var text_editor_control: Control

var save_button: Button
var load_button: Button
var calc_button: Button

var sql_manager: SQLManager


func _ready() -> void:
	sql_manager = %sql_manager
	## UI START
	save_button = %save_button
	load_button = %load_button
	calc_button = %calc_button

	save_button.button_down.connect(cb_save_button)
	load_button.button_down.connect(cb_load_button)
	calc_button.button_down.connect(cb_calc_button)

	pass


func cb_save_button() -> void:
	sql_manager.MakeTable(SQLManager.ProjectsTables.TEST)
	print("save button")


func cb_load_button() -> void:
	print("load button")


func cb_calc_button() -> void:
	print("calc button")
