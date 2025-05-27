FLAGS = -collection:utils=src/utils
OUT_DIR = bin/game
build_cmd = odin build src -out:${OUT_DIR} ${FLAGS}

asset_builder:
	@odin run asset_builder && rm asset_builder

build: asset_builder
	@${build_cmd}

debug:
	@${build_cmd} -debug

run: debug
	@./bin/game
