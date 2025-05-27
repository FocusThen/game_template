package hash

import core_hash "core:hash"

Hash :: distinct u64

hash :: proc(s: string) -> Hash {
	return Hash(core_hash.murmur64a(transmute([]byte)(s)))
}
