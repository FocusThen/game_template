package game

import "core:fmt"
import hm "utils:handle_map"
import rl "vendor:raylib"

Entity_Kind :: enum {
	nil,
	player,
	thing1,
	platform,
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
	case .platform:
		setup_platfrom(e)
	}
}

// Get Player
get_player :: proc() -> ^Entity {
	return entity_from_handle(game_state.player_handle)
}
setup_player :: proc(using e: ^Entity) {
	kind = .player

	cat_idle := Animation {
		texture      = get_texture_by_name(.CatIdle),
		num_frames   = 2,
		frame_length = 0.5,
		name         = .Idle,
	}
	cat_run := Animation {
		texture      = get_texture_by_name(.CatRun),
		num_frames   = 4,
		frame_length = 0.1,
		name         = .Run,
	}
	animations[.Idle] = cat_idle
	animations[.Run] = cat_run
	current_anim = .Idle

	velocity = {}
	acceleration = {0, 0}

	update_proc = proc(e: ^Entity) {
		e.acceleration.y = GRAVITY
		input_dir := get_input_vector()
		player_speed := 200.0
		prev_pos := e.pos

		e.velocity.x = input_dir.x * f32(player_speed)
		e.pos += e.velocity * delta_t()
		e.velocity += e.acceleration * delta_t()

		player_world_rect := rl.Rectangle {
			x      = e.pos.x + e.collision_rect.x,
			y      = e.pos.y + e.collision_rect.y,
			width  = e.collision_rect.width,
			height = e.collision_rect.height,
		}

		// check platforms
		for platform in get_all_platforms() {
			platfrom_rec := rl.Rectangle {
				x      = platform.pos.x,
				y      = platform.pos.y,
				width  = platform.collision_rect.width,
				height = platform.collision_rect.height,
			}

			if rl.CheckCollisionRecs(player_world_rect, platfrom_rec) {
				player_prev_bottom := prev_pos.y + e.collision_rect.y + e.collision_rect.height
				platform_top := platfrom_rec.y
				if player_prev_bottom <= platform_top {
					e.pos.y = platfrom_rec.y - e.collision_rect.y - e.collision_rect.height
					e.velocity.y = 0
					e.is_grounded = true
					break
				}
			}
		}

		if e.is_grounded && is_action_pressed(.Jump) {
			jump_force := -300.0
			e.is_grounded = false
			e.velocity.y = f32(jump_force)
		}

		stand_dir: Vec2
		if input_dir == stand_dir {
			e.current_anim = .Idle
		} else {
			e.current_anim = .Run
		}

		if input_dir.x < 0 {
			e.flip_x = true
		} else if input_dir.x > 0 {
			e.flip_x = false
		}
	}
}

setup_thing1 :: proc(using e: ^Entity) {
	kind = .thing1

	update_proc = proc(e: ^Entity) {}
	draw_proc = proc(e: ^Entity) {}
}

get_all_platforms :: proc() -> [dynamic]^Entity {
	platforms: [dynamic]^Entity
	for e in get_all_ents() {
		if e.kind == .platform {
			append(&platforms, e)
		}
	}
	return platforms
}
setup_platfrom :: proc(using e: ^Entity) {
	kind = .platform

	collision_rect = rl.Rectangle {
		x      = 0,
		y      = 0,
		width  = 100,
		height = 30,
	}

	update_proc = proc(e: ^Entity) {}

	draw_proc = proc(e: ^Entity) {
		rl.DrawRectangleRec(
			rl.Rectangle {
				x = e.pos.x + e.collision_rect.x,
				y = e.pos.y + e.collision_rect.y,
				width = e.collision_rect.width,
				height = e.collision_rect.height,
			},
			rl.GRAY,
		)
	}
}
