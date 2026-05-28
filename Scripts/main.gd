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

var save_button: Button
var load_button: Button
var switch_button: Button

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
	sql_manager = %sql_manager
	save_button = %save_button
	load_button = %load_button
	switch_button = %switch_button

	calculator_control = %calculator_control
	text_editor_control = %text_editor_control

	text_editor = %text_editor

	var rng := RandomNumberGenerator.new()
	var rand_quote_index: int = rng.randi_range(0, random_quotes.size() - 1)
	text_editor.placeholder_text = random_quotes[rand_quote_index]

	pass


func _connect_events():
	save_button.button_down.connect(cb_save_button)
	load_button.button_down.connect(cb_load_button)
	switch_button.button_down.connect(cb_switch_button)
