--!strict
-- (c) Studio Elttob 2024. All rights reserved, seek permission before use.

local LibStudioElttob = script.Parent
local IsLocalDev = require(LibStudioElttob.IsLocalDev)

return {
	SUITE_API = 
		if IsLocalDev then
			"http://localhost:5500/api"
		else
			error("omitted")
}