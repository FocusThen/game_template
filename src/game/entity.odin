package game

import "core:fmt"
import "core:log"
import hm "utils:handle_map"
import rl "vendor:raylib"

MAX_ENTITIES :: 2048

// Entity system
Entity_Game_State :: struct {
	ents: hm.Handle_Map(Entity, Entity_Handle, MAX_ENTITIES),
}

Entity_Scratch :: struct {
	entity_list: [dynamic]^Entity,
}

Animation_Name :: enum {
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

Entity_Handle :: distinct hm.Handle
Entity :: struct {
	handle:       Entity_Handle,
	kind:         Entity_Kind,
	//
	pos:          Vec2,
	//
	update_proc:  proc(_: ^Entity),
	draw_proc:    proc(_: ^Entity),
	//
	flip_x:       bool,
	animations:   [dynamic]Animation,
	current_anim: Animation,
}

@(rodata)
zero_entity: Entity

get_all_ents :: proc() -> []^Entity {
	return game_state.scratch.entity_list[:]
}

entity_create :: proc(kind: Entity_Kind) -> ^Entity {
	handle, ok := hm.add(&game_state.ents, Entity{})
	if !ok {
		log.error("too many entities")
		return &zero_entity
	}

	entity := hm.get(&game_state.ents, handle)
	assert(entity != nil, "This shouldn't break")

	entity_setup(entity, kind)
	assert(entity.kind != nil, fmt.tprint("entity didn't define a kind  during setup?", kind))

	return entity
}

entity_from_handle :: proc(handle: Entity_Handle) -> ^Entity {
	e := hm.get(&game_state.ents, handle)
	if e == nil {
		return &zero_entity
	}
	return e
}

entity_destory :: proc(e: ^Entity) {
	hm.remove(&game_state.ents, e.handle)
}

entity_scratch_reset :: proc(frame: ^Entity_Scratch) {
	game_state.scratch.entity_list = make(
		[dynamic]^Entity,
		0,
		hm.num_used(game_state.ents),
		allocator = context.temp_allocator,
	)
	for &e in game_state.ents.items {
		if hm.skip(e) do continue
		append(&game_state.scratch.entity_list, &e)
	}
}

update_entities :: proc() {
	for e in get_all_ents() {
		// update_animation(&e.current_anim)
		if e.update_proc != nil {
			e.update_proc(e)
		}
	}
}

draw_entities :: proc() {
	for e in get_all_ents() {
		e.draw_proc(e)
	}
}
