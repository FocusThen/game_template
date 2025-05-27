package game

import "core:fmt"
import rl "vendor:raylib"
import hm "utils:handle_map"

Entity_Kind :: enum {
	nil,
	player,
	thing1,
}

default_entity_draw :: proc(e: ^Entity) {
    anim := e.animations[e.current_anim]
		anim_width := f32(anim.texture.width)
		anim_height := f32(anim.texture.height)

		source := rl.Rectangle {
			x      = f32(anim.current_frame) * anim_width / f32(anim.num_frames),
			y      = 0,
			width  = anim_width / f32(anim.num_frames),
			height = anim_height,
		}

		if e.flip_x {
			source.width = -source.width
		}

		dest := rl.Rectangle {
			x      = e.pos.x,
			y      = e.pos.y,
			width  = anim_width / f32(anim.num_frames),
			height = anim_height,
		}

		rl.DrawTexturePro(anim.texture, source, dest, {dest.width / 2, dest.height}, 0, rl.WHITE)
}

entity_setup :: proc(e: ^Entity, kind: Entity_Kind) {
	e.draw_proc = default_entity_draw

	switch kind {
	case .nil:
	case .player:
		setup_player(e)
	case .thing1:
		setup_thing1(e)
	}
}

// Get Player
get_player :: proc() -> ^Entity{
  return entity_from_handle(game_state.player_handle)
}
setup_player :: proc(e: ^Entity) {
	e.kind = .player

	cat_idle := Animation {
		texture      = rl.LoadTexture("./res/images/cat_idle.png"),
		num_frames   = 2,
		frame_length = 0.5,
		name         = .Idle,
	}
	cat_run := Animation {
		texture      = rl.LoadTexture("./res/images/cat_run.png"),
		num_frames   = 4,
		frame_length = 0.1,
		name         = .Run,
	}
	e.animations[.Idle] = cat_idle
	e.animations[.Run] = cat_run
  e.current_anim = .Idle

	e.update_proc = proc(e: ^Entity) {
    stand_dir: Vec2
		input_dir := get_input_vector()
		e.pos += input_dir * 100.0 * delta_t()

    if input_dir == stand_dir{
      e.current_anim = .Idle
    }else{
      e.current_anim = .Run
    }

    if input_dir.x < 0 {
      e.flip_x = true
    } else if input_dir.x > 0{
      e.flip_x = false
    }

	}
}

setup_thing1 :: proc(using e: ^Entity) {
	kind = .thing1

	update_proc = proc(e: ^Entity) {}

	draw_proc = proc(e: ^Entity) {}
}
