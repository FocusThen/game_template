package game

import hm "./handle-map"
import "base:runtime"
import "core:fmt"
import rl "vendor:raylib"

ATLAS_DATA :: #load("../atlas.png")
atlas: rl.Texture
font: rl.Font

PIXEL_WINDOW_HEIGHT :: 270
COLOR_BG :: rl.Color{41, 61, 49, 255}
COLOR_FG :: rl.Color{241, 167, 189, 255}

Vec2 :: rl.Vector2
Rect :: rl.Rectangle


Game_State :: struct {
	ents: hm.Handle_Map(Entity, Entity_Handle, 2048),
}

game_state: Game_State
temp_game_state: Game_State

main :: proc() {
	rl.InitWindow(1280, 720, "Game template")
	rl.SetTargetFPS(240)

	atlas_image := rl.LoadImageFromMemory(".png", raw_data(ATLAS_DATA), i32(len(ATLAS_DATA)))
	atlas = rl.LoadTextureFromImage(atlas_image)
	rl.UnloadImage(atlas_image)
	font = load_atlased_font()
	rl.SetShapesTexture(atlas, SHAPES_TEXTURE_RECT)

	tick_input: Input


	accumulator: f32
	sim_rate :: 1.0 / 60.0

	for !rl.WindowShouldClose() {

		frame_time := rl.GetFrameTime()
		accumulator += frame_time

		frame_input := frame_make_input()
		tick_input.cursor = frame_input.cursor

		for flags, action in frame_input.actions {
			tick_input.actions[action] += flags
		}

		did_tick := false
		defer if did_tick do tick_input = {}
		for accumulator > sim_rate {
			did_tick = true
			accumulator -= sim_rate
			update(&game_state, tick_input, sim_rate)
		}

		runtime.mem_copy_non_overlapping(&temp_game_state, &game_state, size_of(Game_State))
		update(&temp_game_state, frame_input, accumulator)

		draw(temp_game_state)

		free_all(context.temp_allocator)
	}

	rl.CloseWindow()
}


update :: proc(_game_state: ^Game_State, input: Input, delta_t: f32) {

}


draw :: proc(_game_state: Game_State) {
	rl.BeginDrawing()
	rl.ClearBackground(COLOR_BG)
	screen_width := f32(rl.GetScreenWidth())
	screen_height := f32(rl.GetScreenHeight())


	game_camera := rl.Camera2D {
		zoom   = screen_height / PIXEL_WINDOW_HEIGHT,
		target = {},
		offset = {screen_width / 2, screen_height / 2},
	}
	rl.BeginMode2D(game_camera)

	rl.DrawTextEx(
		font,
		"Draw call 1: This text + player + background graphics + tiles",
		{-140, 20},
		15,
		0,
		rl.WHITE,
	)

	rl.DrawTextureRec(atlas, atlas_textures[.Player0].rect, {30, -18}, rl.WHITE)
	// draw_player(player)

	rl.EndMode2D()

	// Here we switch to the UI camera. The stuff drawn in here will be in a separate draw call.
	ui_camera := rl.Camera2D {
		zoom = screen_height / PIXEL_WINDOW_HEIGHT,
	}

	rl.BeginMode2D(ui_camera)
	rl.DrawTextEx(
		font,
		fmt.ctprintf("Draw call 2: This UI\nFPS: %v", rl.GetFPS()),
		{5, 5},
		20,
		0,
		rl.WHITE,
	)
	rl.EndMode2D()

	rl.EndDrawing()
}

load_atlased_font :: proc() -> rl.Font {
	num_glyphs := len(atlas_glyphs)
	font_rects := make([]Rect, num_glyphs)
	glyphs := make([]rl.GlyphInfo, num_glyphs)

	for ag, idx in atlas_glyphs {
		font_rects[idx] = ag.rect
		glyphs[idx] = {
			value    = ag.value,
			offsetX  = i32(ag.offset_x),
			offsetY  = i32(ag.offset_y),
			advanceX = i32(ag.advance_x),
		}
	}

	return {
		baseSize = ATLAS_FONT_SIZE,
		glyphCount = i32(num_glyphs),
		glyphPadding = 0,
		texture = atlas,
		recs = raw_data(font_rects),
		glyphs = raw_data(glyphs),
	}
}
