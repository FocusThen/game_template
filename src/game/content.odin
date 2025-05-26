package game

import "core:fmt"
import rl "vendor:raylib"

Entity_Kind :: enum {
	nil,
	player,
	thing1,
}

// update_animation :: proc(anim: ^Animation) {
// 	anim.frame_timer += delta_t()
// 	if anim.frame_timer > anim.frame_length {
// 		anim.current_frame += 1
// 		anim.frame_timer = 0
//
// 		if anim.current_frame == anim.num_frames {
// 			anim.current_frame = 0
// 		}
// 	}
// }

default_entity_draw :: proc(e: ^Entity) {
	anim := e.current_anim
  fmt.println(anim)
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

setup_player :: proc(e: ^Entity) {
	e.kind = .player

	cat_idle := Animation {
		texture      = rl.LoadTexture("cat_idle.png"),
		num_frames   = 2,
		frame_length = 0.5,
		name         = .Idle,
	}
	cat_run := Animation {
		texture      = rl.LoadTexture("cat_run.png"),
		num_frames   = 4,
		frame_length = 0.1,
		name         = .Run,
	}

	append(&e.animations, cat_idle)
	append(&e.animations, cat_run)

	e.current_anim = cat_idle

	e.update_proc = proc(e: ^Entity) {
		input_dir := get_input_vector()
		e.pos += input_dir * 100.0 * delta_t()

		// if e.current_anim.name == .Idle {
		// 	e.current_anim = e.animations[1]
		// } else {
		// 	e.current_anim = e.animations[0]
		// }
	}

  e.draw_proc = proc(e: ^Entity){

  }
}

setup_thing1 :: proc(using e: ^Entity) {
	kind = .thing1

	update_proc = proc(e: ^Entity) {
	}

	draw_proc = proc(e: ^Entity) {
	}
}
