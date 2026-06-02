extends Control

enum AppsToChose
{
	Notes,
	Calculator,
}

enum MathOperator
{
	Plus,
	Minus,
	Mul,
	Div,
	Equal,
}

enum CalculatorState
{
	DoesNotHaveDot,
	HasDot,
}

const MathOperatorToSymbol: Dictionary = {
	MathOperator.Plus: "+",
	MathOperator.Minus: "-",
	MathOperator.Mul: "*",
	MathOperator.Div: "/",
	MathOperator.Equal: "=",
}

var calculator_state: CalculatorState
var which_app_is_chosen: AppsToChose

var text_editor: TextEdit
var text_editor_control: Control

var calculator_control: Control

var calculator_screen: RichTextLabel

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
## calc data
var calc_buttons: Array[Globals.CalcButtons]
var calc_expr_data: Array[String]
var calc_expr_index: int

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
	sql_manager.save_all_things(text_editor, calculator_screen, calc_buttons, calc_expr_data)
	print("save button")


func cb_load_button() -> void:
	print("load button")


func cb_switch_button() -> void:
	match which_app_is_chosen:
		AppsToChose.Notes:
			make_visible(AppsToChose.Calculator)
		AppsToChose.Calculator:
			make_visible(AppsToChose.Notes)


func cb_add_text_to_calculator(input: String) -> void:
	match input:
		"0":
			calc_buttons.append(Globals.CalcButtons.Button_0)
		"1":
			calc_buttons.append(Globals.CalcButtons.Button_1)
		"2":
			calc_buttons.append(Globals.CalcButtons.Button_2)
		"3":
			calc_buttons.append(Globals.CalcButtons.Button_3)
		"4":
			calc_buttons.append(Globals.CalcButtons.Button_4)
		"5":
			calc_buttons.append(Globals.CalcButtons.Button_5)
		"6":
			calc_buttons.append(Globals.CalcButtons.Button_6)
		"7":
			calc_buttons.append(Globals.CalcButtons.Button_7)
		"8":
			calc_buttons.append(Globals.CalcButtons.Button_8)
		"9":
			calc_buttons.append(Globals.CalcButtons.Button_9)
	calculator_screen.text += input;
	pass


func cb_remove_text_from_calculator() -> void:
	calculator_screen.clear()
	calculator_screen.text = "";
	calc_buttons.append(Globals.CalcButtons.Button_c)


func cb_previous_expresion() -> void:
	var next_index: int = calc_expr_index - 1;
	if next_index < 0:
		next_index = calc_expr_data.size() - 1;
	calculator_screen.text = calc_expr_data[next_index]
	calc_expr_index = next_index
	pass


func cb_next_expresion() -> void:
	var next_index: int = calc_expr_index + 1;
	if next_index > calc_expr_data.size() - 1:
		next_index = 0;
	calculator_screen.text = calc_expr_data[next_index]
	calc_expr_index = next_index
	pass


func cb_add_dot_to_calculator() -> void:
	if calculator_state == CalculatorState.HasDot: return
	calc_buttons.append(Globals.CalcButtons.Button_dot)
	calculator_state = CalculatorState.HasDot
	calculator_screen.text += "."
	pass


func cb_add_math_operator_to_calculator(which_operator: MathOperator) -> void:
	match which_operator:
		MathOperator.Plus:
			calc_buttons.append(Globals.CalcButtons.Button_plus)
		MathOperator.Minus:
			calc_buttons.append(Globals.CalcButtons.Button_minus)
		MathOperator.Mul:
			calc_buttons.append(Globals.CalcButtons.Button_mul)
		MathOperator.Div:
			calc_buttons.append(Globals.CalcButtons.Button_div)
		MathOperator.Equal:
			calc_buttons.append(Globals.CalcButtons.Button_equal)
	calculator_state = CalculatorState.DoesNotHaveDot
	calculator_screen.text += " " + MathOperatorToSymbol[which_operator] + " "
	pass


func cb_evaluate_expression() -> void:
	calc_buttons.append(Globals.CalcButtons.Button_equal)
	var expr: Expression = Expression.new()
	calc_expr_data.append(calculator_screen.text)
	var err = expr.parse(calculator_screen.text)

	if err != OK:
		printerr("Could not execute |%s|" % calculator_screen.text)
		calculator_screen.text = "Error"
		return
	var result: Variant = expr.execute()
	match typeof(result):
		TYPE_FLOAT:
			var final: float = result
			calculator_screen.text = str(final)
		TYPE_INT:
			var final: int = result
			calculator_screen.text = str(final)
		_:
			printerr("INVALID OPERATION")
			calculator_screen.text = "INVALID OPERATION"

	pass


func _set_variables():
	## calculator state
	calculator_state = CalculatorState.DoesNotHaveDot
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
	calculator_screen = % "calculator_screen"
	# Buttons
	button_0 = % "0_button"
	button_1 = % "1_button"
	button_2 = % "2_button"
	button_3 = % "3_button"
	button_4 = % "4_button"
	button_5 = % "5_button"
	button_6 = % "6_button"
	button_7 = % "7_button"
	button_8 = % "8_button"
	button_9 = % "9_button"
	button_dot = % "dot_button"
	button_equals = % "equal_button"
	button_plus = % "plus_button"
	button_minus = % "minus_button"
	button_mul = % "mul_button"
	button_div = % "div_button"
	button_c = % "c_button"
	button_ac = % "ac_button"
	button_next = % "next_button"
	button_prev = % "prev_button"

	calc_expr_index = 0;
	calc_expr_data = []
	pass


func _connect_events() -> void:


	var default_func = func(x: String) -> void:
		cb_add_text_to_calculator(x);
		pass
	save_button.button_down.connect(cb_save_button)
	load_button.button_down.connect(cb_load_button)
	switch_button.button_down.connect(cb_switch_button)

	button_0.button_down.connect(default_func.bind("0"))
	button_1.button_down.connect(default_func.bind("1"))
	button_2.button_down.connect(default_func.bind("2"))
	button_3.button_down.connect(default_func.bind("3"))
	button_4.button_down.connect(default_func.bind("4"))
	button_5.button_down.connect(default_func.bind("5"))
	button_6.button_down.connect(default_func.bind("6"))
	button_7.button_down.connect(default_func.bind("7"))
	button_8.button_down.connect(default_func.bind("8"))
	button_9.button_down.connect(default_func.bind("9"))

	button_dot.button_down.connect(cb_add_dot_to_calculator)
	button_plus.button_down.connect(cb_add_math_operator_to_calculator.bind(MathOperator.Plus))
	button_minus.button_down.connect(cb_add_math_operator_to_calculator.bind(MathOperator.Minus))
	button_mul.button_down.connect(cb_add_math_operator_to_calculator.bind(MathOperator.Mul))
	button_div.button_down.connect(cb_add_math_operator_to_calculator.bind(MathOperator.Div))
	button_equals.button_down.connect(cb_evaluate_expression)
	button_c.button_down.connect(cb_remove_text_from_calculator)
	button_prev.button_down.connect(cb_previous_expresion)
	button_next.button_down.connect(cb_previous_expresion)

	pass
