package game

import hm "./handle-map"
import rl "vendor:raylib"

ATLAS_DATA :: #load("../atlas.png")
atlas: rl.Texture
font: rl.Font

PIXEL_WINDOW_HEIGHT :: 180
COLOR_BG :: rl.Color{41, 61, 49, 255}
COLOR_FG :: rl.Color{241, 167, 189, 255}

Vec2 :: rl.Vector2
Rect :: rl.Rectangle


Game_State :: struct {
	ents: hm.Handle_Map(Entity, Entity_Handle, 69696969),
}

game_state, gs: ^Game_State

main :: proc() {
	rl.InitWindow(1280, 720, "Game template")
	rl.SetTargetFPS(240)

	atlas_image := rl.LoadImageFromMemory(".png", raw_data(ATLAS_DATA), i32(len(ATLAS_DATA)))
	atlas = rl.LoadTextureFromImage(atlas_image)
	rl.UnloadImage(atlas_image)
	font = load_atlased_font()
	rl.SetShapesTexture(atlas, SHAPES_TEXTURE_RECT)

	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground({160, 200, 255, 255})
		rl.EndDrawing()
	}

	rl.CloseWindow()
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
