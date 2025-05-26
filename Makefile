FLAGS = -collection:utils=src/utils
OUT_DIR = bin/game
build_cmd = odin build src -out:${OUT_DIR} ${FLAGS}

build:
	@${build_cmd}

debug:
	@${build_cmd} -debug

run: debug
	@./bin/game
