--!strict
-- (c) Studio Elttob 2024. All rights reserved, seek permission before use.

local Package = script.Parent.Parent
local LibStudioElttob = Package.Parent
local LibOpen = LibStudioElttob.Parent.LibOpen

-- LibOpen
local Fusion = require(LibOpen.Fusion)

local function OverlayPortal(
	scope: Fusion.Scope<typeof(Fusion)>,
    props: {
		OverlayLayer: Fusion.UsedAs<Frame?>,
		Clamp: Fusion.UsedAs<boolean>
	}
)
    error("TODO: implement this")
end

return OverlayPortal