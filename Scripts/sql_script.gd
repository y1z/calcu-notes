class_name SQLManager extends Node

enum ProjectsTables
{
	NONE,
	TEST,
	NOTES,
	CALCULATOR,
	COUNT,
}

const ProjectTableToString: Dictionary = {
	ProjectsTables.NONE: "none", #only exist for testing reasons,
	ProjectsTables.TEST: "test",
	ProjectsTables.COUNT: "count",

}

var database: SQLite


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	database = SQLite.new()
	database.path = "res://database/data.db"
	database.open_db();

	pass # Replace with function body.


func MakeTable(which_one: ProjectsTables) -> void:
	var table_name: String = ProjectTableToString[which_one]
	var id_name: String = table_name + "_id"
	var table: Dictionary
	table[id_name] = { "data_type": "int", "primary_key": true, "not_null": true, "auto_increment": true }
	table["name"] = {"data_type": "text"}
	database.create_table(table_name, table)
	pass


func _exit_tree() -> void:
	database.close_db()
