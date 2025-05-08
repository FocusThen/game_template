package game

import hm "./handle-map"
import "core:log"

Entity_Handle :: distinct hm.Handle
Entity :: struct {
	handle:                 Entity_Handle,
	kind:                   Entity_Kind,
	update_proc, draw_proc: proc(_: ^Entity),

	//
	texture:                Texture_Name,
	animation:              Animation_Name,
}

@(rodata)
zero_entity: Entity

entity_create :: proc() -> ^Entity {
	handle, ok := hm.add(&game_state.ents, Entity{})
	if !ok {
		log.error("too many entities")
		return &zero_entity
	}

	entity := hm.get(&game_state.ents, handle)
	assert(entity != nil, "This shouldn't break")

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


//
// THE CONTENT ZONE
//

Entity_Kind :: enum {
	nil,
	player,
	thing1,
}

entity_setup :: proc(e: ^Entity) {
	switch e.kind {
	case .nil:
	case .player:
		setup_player(e)
	case .thing1:
		setup_thing1(e)
	}
}
setup_player :: proc(using e: ^Entity) {
	kind = .player
	update_proc = proc(e: ^Entity) {
		e.texture = .Player0
	}
}
setup_thing1 :: proc(using e: ^Entity) {
	kind = .thing1
	update_proc = proc(e: ^Entity) {
	}
}
