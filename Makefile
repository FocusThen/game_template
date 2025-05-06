OUT_DIR="build/macos_debug"
ODIN_FLAGS=-debug

atlas_build:
	@odin run src/atlas-builder
	@rm atlas-builder

build: atlas_build
	@odin build src -out:$(OUT_DIR)/game.bin

run: build
	@./build/macos_debug/game.bin
