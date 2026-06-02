class_name SQLManager extends Node

enum ProjectsTables
{
	NONE,
	TEST,
	CALCULATOR_ENTRY,
	MLEP,
	SESSION,
	TEXT_EDITOR_ENTRY,
	BUTTON_PRESSED,
	ACTION,
	UNDO,
	CALC_ENTRY,
	COUNT,
}

const ProjectTableToString: Dictionary = {
	ProjectsTables.NONE: "none", #only exist for testing reasons,
	ProjectsTables.TEST: "test",
	ProjectsTables.COUNT: "count",
	ProjectsTables.CALCULATOR_ENTRY: "calculator_entry",
	ProjectsTables.MLEP: "melp",
	ProjectsTables.SESSION: "session",
	ProjectsTables.TEXT_EDITOR_ENTRY: "text_editor_entry",
	ProjectsTables.BUTTON_PRESSED: "button_pressed",
	ProjectsTables.ACTION: "action",
	ProjectsTables.UNDO: "undo",
	ProjectsTables.CALC_ENTRY: "calc_entry"
}

var database: SQLite


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	database = SQLite.new()
	database.path = "res://database/data.db"
	database.foreign_keys = true
	database.verbosity_level = SQLite.VERY_VERBOSE
	if not database.open_db():
		printerr("COULT NOT OPEN DATA BASE AT |%s|" % database.path)

	start_up_database()
	var session_table: Dictionary = Dictionary()
	session_table["unix_start_time"] = get_unix_time()
	session_table["unix_end_time"] = 0 # { "data_type": "int", "default": 0 }
	database.insert_row(ProjectTableToString[ProjectsTables.SESSION], session_table)
	pass # Replace with function body.


func start_up_database() -> void:
	make_table(ProjectsTables.CALC_ENTRY)
	for i in ProjectsTables.values():
		var current_proj_table: ProjectsTables = i as ProjectsTables;
		if (
				current_proj_table != ProjectsTables.CALCULATOR_ENTRY
				and current_proj_table != ProjectsTables.MLEP):
			make_table(i as ProjectsTables)

		pass
	pass


func does_table_exist(which_one: ProjectsTables) -> bool:
	#-- Source - https://stackoverflow.com/a/1604121
	# -- Posted by PoorLuzer, modified by community. See post 'Timeline' for change history
	#-- Retrieved 2026-05-30, License - CC BY-SA 4.0
	var result: bool = false;
	var query: String = "SELECT name FROM sqlite_master WHERE type='table' AND name='@table_name';";
	var name_param: Dictionary = { "table_name": ProjectTableToString[which_one] }
	database.query_with_named_bindings(query, name_param)
	for i in database.query_result:
		result = true;
	return result


func make_table(which_one: ProjectsTables) -> void:
	if which_one == ProjectsTables.NONE: return

	var table_name: String = ProjectTableToString[which_one]
	var id_name: String = get_table_id(which_one)
	print("id_name = " + id_name)
	var table: Dictionary
	table[id_name] = { "data_type": "int", "primary_key": true, "not_null": true, "auto_increment": true }
	match which_one:
		ProjectsTables.TEST:
			table["name"] = { "data_type": "text" }
		ProjectsTables.CALCULATOR_ENTRY:
			## TODO : FIND OUT WHY THIS ENTRY DOES NOT WORK
			table["unix_entry_time"] = { "data_type": "int", "not_null": true }
			table["entry_data"] = { "data_type": "text", "default": "'hello I am empty'" }
		ProjectsTables.MLEP:
			table["name"] = { "data_type": "text" }
			table["melp_unix_entry_time"] = { "data_type": "int", "not_null": true }
			table["melp_text"] = { "data_type": "text", "default": "'hello I am empty'" }
		ProjectsTables.SESSION:
			table["unix_start_time"] = { "data_type": "int", "default": 0, "not_null": true }
			table["unix_end_time"] = { "data_type": "int", "default": 0 }
		ProjectsTables.TEXT_EDITOR_ENTRY:
			table["name"] = { "data_type": "text" }
			table["unix_date"] = { "data_type": "int", "default": 0, "not_null": true }
			table["entry_text"] = { "data_type": "text" }
		ProjectsTables.BUTTON_PRESSED:
			table["which_button"] = { "data_type": "int", "not_null": true, "default": -1 }
		ProjectsTables.ACTION:
			table["type_of_action"] = { "data_type": "int", "not_null": true, "default": 0 }
		ProjectsTables.UNDO:
			table["type_of_undo"] = { "data_type": "int", "not_null": true, "default": 0 }
		ProjectsTables.CALC_ENTRY:
			#table["name"] = {"data_type": "text"}
			table["entry"] = { "data_type": "text", "default": "'hello I am empty'" }
			pass
	pass

	if which_one != ProjectsTables.CALCULATOR_ENTRY:
		if not database.create_table(table_name, table):
			printerr("FAILED AT CREATE TABLE")
			printerr("Table name = %s" % table_name)
			printerr("Table data = %s" % table)
			printerr("|%s|" % database.error_message)
			printerr("QUERY RESULT")
			printerr(database.query_result)

	else:
		var id_name_params: String = " INTEGER PRIMARY KEY NOT NULL,"
		var name_param: String = "entry_data text);"
		var query: String = "CREATE TABLE IF NOT EXISTS " + table_name + " (" + id_name + id_name_params + name_param
		if not database.query(query):
			printerr("|%s|" % database.error_message)
	pass


func save_all_things(text_editor: TextEdit, calc_screen: RichTextLabel, calc_buttons: Array[Globals.CalcButtons], _calc_data: Array[String]) -> bool:
	var result: bool = false
	var session_table: Dictionary = Dictionary()
	session_table["unix_end_time"] = get_unix_time() # { "data_type": "int", "default": 0 }
	#print(session_table)
	database.insert_row(ProjectTableToString[ProjectsTables.SESSION], session_table)
	#database.select_rows(, )

	var session_name: String = ProjectTableToString[ProjectsTables.SESSION]
	var session_id: String = get_table_id(ProjectsTables.SESSION)
	database.query("SELECT " + session_id + " from " + session_name + " ORDER BY " + session_id + " DESC LIMIT 1")

	print("-=----=-=-==-=")
	print(database.query_result[0][session_id]) ;
	print("-=----=-=-==-=")
	var condition: String = session_id + "= " + str(database.query_result[0][session_id])
	print("condition |%s|" % condition)
	database.update_rows(session_name, condition, { "unix_end_time": get_unix_time() });

	database.insert_row(ProjectTableToString[ProjectsTables.TEXT_EDITOR_ENTRY], { "unix_date": get_unix_time(), "entry_text": text_editor.text })
	var value_input: String = "(NULL,NULL)" % calc_screen.text ;
	var calc_id: String = get_table_id(ProjectsTables.CALCULATOR_ENTRY)
	var cal_query: String = "INSERT INTO " + ProjectTableToString[ProjectsTables.CALCULATOR_ENTRY] + " (" + calc_id + ",entry_data)\n VALUES " + value_input + ";"
	database.query(cal_query)
	print("ERROR MESSAGE %s" % database.error_message)

	return result;


func get_table_id(which_one: ProjectsTables) -> String:
	return ProjectTableToString[which_one] + "_id"


func get_unix_time() -> int:
	var unix_time_dict: Dictionary = Time.get_datetime_dict_from_unix_time(true);

	Time.get_datetime_string_from_datetime_dict(Time.get_time_dict_from_system(), true)

	return Time.get_unix_time_from_system()# get_unix_time_from_datetime_dict(unix_time_dict)


func _exit_tree() -> void:
	database.close_db()
