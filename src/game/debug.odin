package game

import "core:fmt"
import "core:slice"
import "core:strings"
import hh "utils:handle_hash"
import hm "utils:handle_map"
import rl "vendor:raylib"

selected_texture_handle: Texture_Handle = Texture_Handle_None

PlacedObject :: struct {
	texture_handle: Texture_Handle,
	position:       rl.Vector2,
}

placed_objects: [dynamic]PlacedObject

handle_editing_input :: proc(camera: rl.Camera2D) {
	if game_state.is_debug_mode {
		if selected_texture_handle.idx != 0 {
			if rl.IsMouseButtonPressed(.LEFT) {
				mouse_pos := rl.GetMousePosition()
        placement_position := rl.GetScreenToWorld2D(mouse_pos, camera)
				append(&placed_objects, PlacedObject{selected_texture_handle, placement_position})
			}
		}
	}
}

draw_editing_mode :: proc(camera: rl.Camera2D) {
	if game_state.is_debug_mode {
		for obj in placed_objects {
			texture := get_texture(obj.texture_handle)
			rl.DrawTextureV(texture, obj.position, rl.WHITE)
		}

    rl.EndMode2D()

		draw_asset_sidebar()

		if selected_texture_handle.idx != 0 {
			selected_texture := get_texture(selected_texture_handle)
      mouse_pos := rl.GetMousePosition()
			rl.DrawTextureV(selected_texture, mouse_pos, rl.Fade(rl.WHITE, 0.7))
		}

    rl.BeginMode2D(camera)
	}
}

draw_asset_sidebar :: proc() {
	sidebar_width := 200.0
	screen_width := rl.GetScreenWidth()
  screen_height := rl.GetScreenHeight()

  rl.DrawRectangle(screen_width - i32(sidebar_width), 0, i32(sidebar_width), screen_height, rl.Fade(rl.BLUE, 0.8))

	texture_handles := get_all_texture_handles()

	text_y := 10.0
	for handle in texture_handles {
		texture_path := get_texture_path(handle)
		texture := get_texture(handle)

		rl.DrawText(
			strings.unsafe_string_to_cstring(texture_path),
			i32(screen_width - i32(sidebar_width) + 10),
			i32(text_y),
			20,
			rl.WHITE,
		)

		texture_preview_size := 50.0
		texture_preview_rect := rl.Rectangle {
			f32(screen_width - i32(sidebar_width) + 10),
			f32(text_y + 25),
			f32(texture_preview_size),
			f32(texture_preview_size),
		}
		rl.DrawTexturePro(
			texture,
			rl.Rectangle{0, 0, f32(texture.width), f32(texture.height)},
			texture_preview_rect,
			rl.Vector2{0, 0},
			0,
			rl.WHITE,
		)

		mouse_pos := rl.GetMousePosition()
		if rl.CheckCollisionPointRec(mouse_pos, texture_preview_rect) {
			if rl.IsMouseButtonPressed(.LEFT) {
				selected_texture_handle = handle
				fmt.println("Selected texture: ", texture_path)
			}
			rl.DrawRectangleLinesEx(texture_preview_rect, 2, rl.YELLOW)
		}

		text_y += texture_preview_size + 40
	}
}

debug_shutdown :: proc() {
	delete(placed_objects)
}
