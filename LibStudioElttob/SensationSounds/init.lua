--!strict
-- (c) Studio Elttob 2024. All rights reserved, seek permission before use.

local ContentProvider = game:GetService("ContentProvider")

local Sounds = {
	generic = "",
	attention = "",
	subtle = "",
	success = "",
	fail = "",
	ask = ""
}

for _, soundId in Sounds do
	task.spawn(function()
		ContentProvider:PreloadAsync({soundId})
	end)
end

return Sounds