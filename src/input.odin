package game

import rl "vendor:raylib"

Input_Action :: enum u8 {
	Left,
	Right,
	Up,
	Down,
	Click,
	Use,
	Interact,
}

frame_make_input :: proc() -> Input {
	input: Input

  input.cursor = rl.GetMousePosition()

	input.actions[.Up] = input_flags_from_key(.W)
	input.actions[.Left] = input_flags_from_key(.A)
	input.actions[.Right] = input_flags_from_key(.D)
	input.actions[.Down] = input_flags_from_key(.S)
	input.actions[.Interact] = input_flags_from_key(.E)


	input.actions[.Click] = input_flags_from_mouse_button(.LEFT)
	input.actions[.Use] = input_flags_from_mouse_button(.RIGHT)

	return input
}


Input :: struct {
	cursor:  rl.Vector2,
	actions: [Input_Action]bit_set[Input_Flag],
}

Input_Flag :: enum u8 {
	Down,
	Pressed,
	Released,
}

input_flags_from_key :: proc(key: rl.KeyboardKey) -> (flags: bit_set[Input_Flag]) {
	if rl.IsKeyDown(key) do flags += {.Down}
	if rl.IsKeyPressed(key) do flags += {.Pressed}
	if rl.IsKeyReleased(key) do flags += {.Released}
	return
}

input_flags_from_mouse_button :: proc(mb: rl.MouseButton) -> (flags: bit_set[Input_Flag]) {
	if rl.IsMouseButtonDown(mb) do flags += {.Down}
	if rl.IsMouseButtonPressed(mb) do flags += {.Pressed}
	if rl.IsMouseButtonReleased(mb) do flags += {.Released}
	return
}

input_clear_temp :: proc(input: ^Input) {
	for &action in input.actions {
		action -= ~{.Down} // clear all except down flag
	}
}
