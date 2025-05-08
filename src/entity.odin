package game

import hm "./handle-map"
import "core:log"

Entity_Handle :: distinct hm.Handle

Entity :: struct {
	handle: Entity_Handle,
}

@(rodata)
zero_entity: Entity

entity_create :: proc() -> ^Entity {
	handle, err := hm.add(&gs.ents, Entity{})
	if err != nil {
		log.error(err)
		return &zero_entity
	}

	entity := hm.get(gs.ents, handle)
	assert(entity != nil, "This shouldn't break")

	return entity
}

entity_destory :: proc(e: ^Entity) {
	hm.remove(&gs.ents, e.handle)
}
