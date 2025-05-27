FLAGS = -collection:utils=src/utils
OUT_DIR = bin/game
build_cmd = odin build src -out:$(OUT_DIR) $(FLAGS)

.PHONY: asset_builder build debug run

asset_builder:
	@odin run asset_builder
	@rm -f asset_builder.bin

build_common:
	@if [ ! -f src/game/asset.odin ]; then \
		$(MAKE) asset_builder; \
	fi

build: build_common
	@$(BASE_BUILD_CMD)

debug: build_common
	@$(BASE_BUILD_CMD) -debug

run: debug
	@./bin/game

