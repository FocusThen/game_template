package game

import "base:runtime"
import "core:fmt"
import rl "vendor:raylib"


Game_State :: struct {
	input:                   Input, // this gets accumulated every actual render frame
	ticks:                   u64,
	world_time_elapse:       f64,
	player_handle:           Entity_Handle,
	using entity_game_state: Entity_Game_State,
	asset_store:             Asset_Storage,
	//
	scratch:                 Game_State_Scratch,
	delta:                   f32,
}

Game_State_Scratch :: struct {
	using entity_scratch: Entity_Scratch,
	delta_t:              f32,
}

game_state: ^Game_State
actual_game_state: ^Game_State
font: rl.Font

TICKS_PER_SECOND :: 60
SIM_RATE :: 1.0 / TICKS_PER_SECOND

run :: proc() {
	rl.InitWindow(WINDOW_W, WINDOW_H, "Game")
	rl.SetTargetFPS(60)

	actual_game_state = new(Game_State)

  asset_storage_init(&actual_game_state.asset_store)
	game_init(actual_game_state)

	accumulator: f32

	for !rl.WindowShouldClose() {
		frame_time := rl.GetFrameTime()
		accumulator += frame_time

		{
			frame_input := frame_make_input()
			actual_game_state.input.cursor = frame_input.cursor
			for flags, action in frame_input.actions {
				actual_game_state.input.actions[action] += flags
			}
		}
		did_tick := false
		defer if did_tick do actual_game_state.input = {}
		for accumulator > SIM_RATE {
			did_tick = true
			accumulator -= SIM_RATE
			game_update(actual_game_state, SIM_RATE)
			input_clear_temp(&actual_game_state.input)
		}

		temp_game_state := new(Game_State, allocator = context.temp_allocator)
		runtime.mem_copy_non_overlapping(temp_game_state, actual_game_state, size_of(Game_State))
		game_update(temp_game_state, accumulator)
		game_draw(temp_game_state)

		free_all(context.temp_allocator)
	}

	rl.CloseWindow()
}


game_init :: proc(_game_state: ^Game_State) {
	old_gs := game_state
	game_state = _game_state
	defer game_state = old_gs

	// font
	font = load_font(.Alagard, 15)

	// player
	e := entity_create(.player)
	game_state.player_handle = e.handle
}

game_update :: proc(_game_state: ^Game_State, delta_t: f32) {
	old_gs := game_state
	game_state = _game_state
	defer game_state = old_gs

	defer {
		game_state.world_time_elapse += f64(delta_t)
		game_state.ticks += 1
	}

	{
		game_state.scratch = {}
		entity_scratch_reset(&game_state.scratch.entity_scratch)
		game_state.scratch.delta_t = delta_t
	}

	update_entities()
}

game_draw :: proc(_game_state: ^Game_State) {
	old_gs := game_state
	game_state = _game_state
	defer game_state = old_gs

	rl.BeginDrawing()
	rl.ClearBackground(COLOR_BG)
	screen_width := f32(rl.GetScreenWidth())
	screen_height := f32(rl.GetScreenHeight())

	// game world draw
	{
		game_camera := rl.Camera2D {
			zoom   = screen_height / PIXEL_WINDOW_HEIGHT,
			target = {},
			offset = {screen_width / 2, screen_height / 2},
		}

		rl.BeginMode2D(game_camera)
		rl.DrawTextEx(
			font,
			"Draw call 1: This text + player + background graphics + tiles",
			{-200, 20},
			15,
			0,
			rl.WHITE,
		)
		draw_entities()
		rl.EndMode2D()
	}

	// ui draw
	{
		ui_camera := rl.Camera2D {
			zoom = screen_height / PIXEL_WINDOW_HEIGHT,
		}

		rl.BeginMode2D(ui_camera)
		rl.DrawTextEx(
			font,
			fmt.ctprintf("Draw call 2: This UI\nFPS: %v", rl.GetFPS()),
			{5, 5},
			21,
			0,
			rl.WHITE,
		)

		rl.EndMode2D()
	}

	rl.EndDrawing()
}
