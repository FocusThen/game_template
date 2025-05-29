package game

import "core:math/linalg"
import rl "vendor:raylib"

Input_Action :: enum u8 {
	Left,
	Right,
	// Up,
	// Down,
  Jump,
	Click,
	Use,
	Interact,
  ToggleDebug
}

get_input_vector :: proc() -> Vec2 {
	input: Vec2
	if is_action_down(.Left) do input.x -= 1.0
	if is_action_down(.Right) do input.x += 1.0

  // no vertical
	// if is_action_down(.Down) do input.y += 1.0
	// if is_action_down(.Up) do input.y -= 1.0

	return input == {} ? {} : linalg.normalize(input)
}

is_action_pressed :: proc(action: Input_Action) -> bool {
	return .Pressed in game_state.input.actions[action]
}

is_action_released :: proc(action: Input_Action) -> bool {
	return .Released in game_state.input.actions[action]
}

is_action_down :: proc(action: Input_Action) -> bool {
	return .Down in game_state.input.actions[action]
}


frame_make_input :: proc() -> Input {
	input: Input

	input.cursor = rl.GetMousePosition()

	input.actions[.Left] = input_flags_from_key(.A)
	input.actions[.Right] = input_flags_from_key(.D)

	input.actions[.Interact] = input_flags_from_key(.E)
  input.actions[.Jump] = input_flags_from_key(.SPACE)

  // no vertical actions
	// input.actions[.Up] = input_flags_from_key(.W)
	// input.actions[.Down] = input_flags_from_key(.S)


	input.actions[.Click] = input_flags_from_mouse_button(.LEFT)
	input.actions[.Use] = input_flags_from_mouse_button(.RIGHT)

  // Bind F6 to toggle debug
  input.actions[.ToggleDebug] = input_flags_from_key(.F6)

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
