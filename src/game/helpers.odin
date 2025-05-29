package game

import rl "vendor:raylib"

WINDOW_H :: 720
WINDOW_W :: 1280

PIXEL_WINDOW_HEIGHT :: 270
COLOR_BG :: rl.Color{41, 61, 49, 255}
COLOR_FG :: rl.Color{241, 167, 189, 255}
UID :: distinct u128
GRAVITY :: 800.0

Vec2 :: rl.Vector2
Rect :: rl.Rectangle

delta_t :: proc() -> f32 {
	return game_state.scratch.delta_t
}
