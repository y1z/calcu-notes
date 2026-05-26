@tool
extends EditorScript
class_name CreateProjectFolders

const proj_dirs := [
	"res://Entities",
	"res://Entities/UI",
	"res://Scenes",
	"res://Scenes/UI",
	"res://Scripts",
	"res://Scripts/Debug Only",
	"res://Scripts/Editor",
	"res://Scripts/UI",
	"res://Sprites",
	"res://Textures",
	"res://Themes",
]

const folder_colors := {
	"res://Entities/": "orange",
	"res://Scenes/": "red",
	"res://Scripts/": "green",
	"res://Sprites/": "yellow",
	"res://Textures/": "purple",
	"res://Themes/": "pink"
}


# Called when the script is executed (using File -> Run in Script Editor).
func _run() -> void:
	
	if generate_directories():
		color_folders()
	pass


func generate_directories() -> bool:
	print("generating folders for project")
	var result: bool = false

	for d:String in proj_dirs:
		if not DirAccess.dir_exists_absolute(d):
			var err := DirAccess.make_dir_recursive_absolute(d)

			if err != OK:
				push_error("Failed to create: %s (error %d)" % [d, err])
				return result;
		else:
			print("Already created %s" % d)

	result = true
	EditorInterface.get_resource_filesystem().scan()
	print_rich("[b]Finished generating folders for project [/b]")

	return result


func color_folders() -> void:
	print_rich("[i]Coloring folder for Project[/i]")
	ProjectSettings.set_setting("file_customization/folder_colors", folder_colors)
	EditorInterface.get_resource_filesystem().scan()
	print_rich("[b]Finished coloring folder for Project [/b]")

	pass
