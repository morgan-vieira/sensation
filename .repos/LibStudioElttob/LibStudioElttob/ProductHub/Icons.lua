--!strict
-- (c) Studio Elttob 2024. All rights reserved, seek permission before use.

local Package = script.Parent
local LibStudioElttob = Package.Parent

local IconRamp = require(LibStudioElttob.IconRamp)

local Icons = {}

Icons.productHubRamp = {
	{
		size = 64,
		variants = {
			light = "",
			dark = "",
			mono = ""
		}
	},
	{
		size = 512,
		variants = {
			light = "",
			dark = "",
			mono = ""
		}
	}
} :: IconRamp.IconRamp

Icons.productHubNotifyRamp = {
	{
		size = 64,
		variants = {
			light = "",
			dark = "",
			mono = ""
		}
	},
	{
		size = 512,
		variants = {
			light = "",
			dark = "",
			mono = ""
		}
	}
} :: IconRamp.IconRamp

return Icons