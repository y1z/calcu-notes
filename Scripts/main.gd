extends Control

enum AppsToChose
{
	Notes,
	Calculator,
}

var which_app_is_chosen: AppsToChose

var text_editor: TextEdit
var text_editor_control: Control

var calculator_control: Control

## Universal UI
var save_button: Button
var load_button: Button
var switch_button: Button

## Calculator Buttons UI
var button_0: Button
var button_1: Button
var button_2: Button
var button_3: Button
var button_4: Button
var button_5: Button
var button_6: Button
var button_7: Button
var button_8: Button
var button_9: Button
## Math operators
var button_dot: Button;
var button_equals: Button;
var button_plus: Button;
var button_minus: Button;
var button_mul: Button;
var button_div: Button;
## screen operators
var button_c: Button;
var button_ac: Button;
var button_prev: Button;
var button_next: Button;

var sql_manager: SQLManager

var random_quotes := ["I love being a writer. What I can't stand is the paperwork.\n
Peter De Vries",
	"One must be a wise reader to quote wisely and well.\n
Amos Bronson Alcott\n
US educator & Transcendentalist (1799 - 1888)\n",
	"
Work is not always required... there is such a thing as sacred idleness, the
cultivation of which is now fearfully neglected.\n
George McDonald\n
"]


func _ready() -> void:
	_set_variables();
	_connect_events();
	make_visible(AppsToChose.Notes)
	pass


func make_visible(which: AppsToChose) -> void:
	match which:
		AppsToChose.Notes:
			calculator_control.visible = false;
			text_editor_control.visible = true;
			pass
		AppsToChose.Calculator:
			calculator_control.visible = true;
			text_editor_control.visible = false;
			pass
	which_app_is_chosen = which;
	pass


func cb_save_button() -> void:
	sql_manager.MakeTable(SQLManager.ProjectsTables.TEST)
	print("save button")


func cb_load_button() -> void:
	print("load button")


func cb_switch_button() -> void:
	match which_app_is_chosen:
		AppsToChose.Notes:
			make_visible(AppsToChose.Calculator)
		AppsToChose.Calculator:
			make_visible(AppsToChose.Notes)


func _set_variables():
	## SQL
	sql_manager = %sql_manager
	## shared UI
	save_button = %save_button
	load_button = %load_button
	switch_button = %switch_button
	## Text Editor
	text_editor = %text_editor
	text_editor_control = %text_editor_control

	var rng := RandomNumberGenerator.new()
	var rand_quote_index: int = rng.randi_range(0, random_quotes.size() - 1)
	text_editor.placeholder_text = random_quotes[rand_quote_index]
	## CALCULATOR
	calculator_control = %calculator_control
	# Buttons
	button_0 = %"0_button"
	button_1 = %"1_button"
	button_2 = %"2_button"
	button_3 = %"3_button"
	button_4 = %"4_button"
	button_5 = %"5_button"
	button_6 = %"6_button"
	button_7 = %"7_button"
	button_8 = %"8_button"
	button_9 = %"9_button"
	button_dot = %"dot_button"
	button_equals = %"equal_button"
	button_plus = %"plus_button"
	button_minus  = %"minus_button"
	button_mul = %"mul_button"
	button_div = %"div_button"
	button_c = %"c_button"
	button_ac  = %"ac_button"
	button_next  = %"next_button"
	button_prev = %"prev_button"

	


	pass


func _connect_events():
	save_button.button_down.connect(cb_save_button)
	load_button.button_down.connect(cb_load_button)
	switch_button.button_down.connect(cb_switch_button)
