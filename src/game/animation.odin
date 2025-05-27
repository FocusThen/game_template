package game

import rl "vendor:raylib"

Animation_Name :: enum {
  nil,
	Idle,
	Run,
}

Animation :: struct {
	texture:       rl.Texture2D,
	num_frames:    int,
	frame_timer:   f32,
	current_frame: int,
	frame_length:  f32,
	name:          Animation_Name,
}

update_animation :: proc(anim: ^Animation) {
	anim.frame_timer += delta_t()
	if anim.frame_timer > anim.frame_length {
		anim.current_frame += 1
		anim.frame_timer = 0

		if anim.current_frame == anim.num_frames {
			anim.current_frame = 0
		}
	}
}
