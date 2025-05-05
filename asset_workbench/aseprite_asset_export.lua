--[[
-- Export script Aseprite
--
-- It takes the currently selected layer and exports it into ../res/images/layer_name.png
--]]

local spr = app.activeSprite
if not spr then
	return print("No active sprite")
end

local local_path, title, extension = spr.filename:match("^(.+[/\\])(.-).([^.]*)$")

local export_path = local_path .. "../res/images/"
local_path = export_path

local sprite_name = app.fs.fileTitle(app.activeSprite.filename)

function layer_export()
	local fn = local_path .. "/" .. app.activeLayer.name
	app.command.ExportSpriteSheet({
		ui = false,
		type = SpriteSheetType.HORIZONTAL,
		textureFilename = fn .. ".png",
		dataFormat = SpriteSheetDataFormat.JSON_ARRAY,
		layer = app.activeLayer.name,
		trim = true,
	})
end

local asset_path = local_path .. "/"

function do_animation_export()
	for i, tag in ipairs(spr.tags) do
		local fn = asset_path .. sprite_name .. "_" .. tag.name
		app.command.ExportSpriteSheet({
			ui = false,
			type = SpriteSheetType.HORIZONTAL,
			textureFilename = fn .. ".png",
			dataFormat = SpriteSheetDataFormat.JSON_ARRAY,
			tag = tag.name,
			listLayers = false,
			listTags = false,
			listSlices = false,
		})
	end
end
