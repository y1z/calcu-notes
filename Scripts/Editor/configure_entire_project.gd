@tool
extends EditorScript
class_name ConfigureEntireProject

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

const window_title :String = "Configure entire project"
const window_size : Vector2i = Vector2i(500, 700)

var cb_default_function := Callable (default_button_function)

const default_ui_size:Vector2i = Vector2i(100,100)


func dumb() -> void:
  	
	print("hello;")
	pass

# Called when the script is executed (using File -> Run in Script Editor).
func _run() -> void:
	var window : Window = Window.new()
	window.title = window_title
	window.size = window_size
	window.close_requested.connect(
		func() -> void:
			window.queue_free()
	)
	add_ui_to_window(window)
	EditorInterface.popup_dialog_centered(window, window.size)

#region CREATE PROJECT FOLDERS
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

func create_project_folders() ->void :
	if generate_directories():
		color_folders()
	pass
#endregion

#region ADD UI ELEMENTS
func add_button(name : String, size :Vector2i, call_back_function : Callable  = default_button_function ) -> Button:
	var result : Button = Button.new()
	result.text = name
	result.size = size
	callable_info_print(call_back_function)
	if call_back_function.is_null():
		call_back_function = func() -> void: print("pressed button")

	if call_back_function.get_argument_count() != 0:
		printerr("Can only use callables with zero arguments")
		assert(false)
	
	result.pressed.connect(
		func() -> void:
			call_back_function.call()
	)
	
	return result

func add_line_edit(size:Vector2i ,call_back :Callable = default_line_edit_function ) -> LineEdit:
	var result : LineEdit = LineEdit.new()
	result.size = size
	result.text_submitted.connect(
		func(input_text:String) -> void:
			call_back.call(input_text)
	)
	return result

func add_hbox(elements: Array[Control]) -> HBoxContainer:
	var result : HBoxContainer = HBoxContainer.new()
	for e in elements:
		result.add_child(e)
	return result

## THIS HAS TO BE STATIC OR we get the following error `ERROR: res://Scripts/configure_entire_project.gd:96 - Attempt to call function 'null::default_button_function (Callable)' on a null instance.`
static func default_button_function() -> void:
	print("Default Button pressed function")

static func default_line_edit_function(input_string : String) -> void:
	print("Current input text = %s" % input_string)

#endregion



func add_ui_to_window(window: Window) -> void :
	var vbox : VBoxContainer = VBoxContainer.new()
	var control : Control = Control.new()
	control.add_child(vbox)
	
	vbox.add_child(
		add_button("save and reset",
		Vector2i(100,100),
		func() -> void:
			ProjectSettings.save()
			EditorInterface.restart_editor(true)
			)
	)
	
	vbox.add_child(
		add_button("create folders",
		Vector2i(100,100),
		func() -> void:create_project_folders()
	))
	
	var line_edit_width := add_line_edit(default_ui_size,
	 func(input_text:String) -> void:
		change_viewport_size(true, input_text.to_int()
		) )
	var width_text_input :HBoxContainer = add_hbox([
		line_edit_width,
		add_button("confirm width",default_ui_size,
		 func() -> void:
			line_edit_width.text_submitted.emit(line_edit_width.text)),
		 ])

	
	var line_edit_height := add_line_edit(default_ui_size, 
	func(input_text:String) -> void:
		change_viewport_size(false, input_text.to_int()) 
		)

	var height_text_input :HBoxContainer = add_hbox([
		line_edit_height,
		add_button("confirm height",default_ui_size, 
		func() -> void:
			line_edit_height.text_submitted.emit(line_edit_height.text)),
		 ])

	vbox.add_child(width_text_input)
	vbox.add_child(height_text_input)
	
	vbox.add_child(
		add_button("Make shadow warnings into warnings",
		Vector2i(100,100),
		func() -> void: change_shadow_warnings(false); ProjectSettings.save()
		)
	)
	
	vbox.add_child(
		add_button("Make shadow warnings into ERRORS",
		Vector2i(100,100),
		func() -> void: change_shadow_warnings(true); ProjectSettings.save()
		)
	)
	
	window.add_child(control)
	pass

func callable_info_print(call_back_function: Callable) -> void:
	print("is null = %s"% call_back_function.is_null())
	print("is valid = %s" % call_back_function.is_valid())
	print("is custom = %s" % call_back_function.is_custom())
	print("is standard = %s" % call_back_function.is_standard())
	print("method is = %s" % call_back_function.get_method())
	print("call argument count is = %s" % call_back_function.get_argument_count())
	pass

func change_viewport_size(should_change_width : bool , new_size:int) -> void:
	if should_change_width:
		print("change width = %s" % new_size)
		ProjectSettings.set_setting("display/window/size/viewport_width", new_size)
	else:
		print("change height = %s" % new_size)
		ProjectSettings.set_setting("display/window/size/viewport_height", new_size)
	pass
 
func change_shadow_warnings(should_make_them_errors : bool) -> void:
	var base_path : String = "debug/gdscript/warnings/"
	var new_value : int = 1
	if should_make_them_errors:
		new_value = 2
		print("Will set all shadow warnings to ERRORS")
	else:
		print("will set all shadow warnings to WARNINGS")
	var shadow_var_path := base_path + "shadowed_variable"
	if ProjectSettings.has_setting(shadow_var_path):
		ProjectSettings.set_setting(shadow_var_path, new_value);
	
	var global_shadow_var_path = base_path + "shadowed_global_identifier"
	if ProjectSettings.has_setting(global_shadow_var_path):
		ProjectSettings.set_setting(global_shadow_var_path, new_value)
	
	var shadow_variable_base_class_path = base_path + "shadowed_variable_base_class"
	if ProjectSettings.has_setting(shadow_variable_base_class_path):
		ProjectSettings.set_setting(shadow_variable_base_class_path,new_value)
	
	print("DONE")
	pass
