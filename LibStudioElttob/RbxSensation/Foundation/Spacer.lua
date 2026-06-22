--!strict
-- (c) Studio Elttob 2024. All rights reserved, seek permission before use.

local Package = script.Parent.Parent
local LibStudioElttob = Package.Parent
local LibOpen = LibStudioElttob.Parent.LibOpen

local Fusion = require(LibOpen.Fusion)

local function Spacer(
	scope: Fusion.Scope<typeof(Fusion)>,
	props: {
		Spacing: Fusion.UsedAs<number>,
		LayoutOrder: Fusion.UsedAs<number>?,
		Visible: Fusion.UsedAs<boolean>
	}
)
	return scope:New "Frame" {
		Name = "Spacer",

		Size = scope:Computed(function(use)
			return UDim2.fromOffset(use(props.Spacing), use(props.Spacing))
		end),
		LayoutOrder = props.LayoutOrder,
		Visible = props.Visible,

		BackgroundTransparency = 1
	}
end

return Spacer