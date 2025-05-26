package game

Asset :: struct {
	path: string,
	data: []u8,
}

TextureName :: enum {
	None,
	CatRun,
	CatIdle,
}

LevelName :: enum {}


all_textures := [TextureName]Asset {
	.None = {},
	.CatRun = {path = "./res/images/cat_run.png", data = #load("../../res/images/cat_run.png")},
	.CatIdle = {path = "./res/images/cat_idle.png", data = #load("../../res/images/cat_idle.png")},
}
