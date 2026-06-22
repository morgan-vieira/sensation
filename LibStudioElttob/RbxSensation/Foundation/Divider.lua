--!strict
-- (c) Studio Elttob 2024. All rights reserved, seek permission before use.

local Package = script.Parent.Parent
local LibStudioElttob = Package.Parent
local LibOpen = LibStudioElttob.Parent.LibOpen

local Fusion = require(LibOpen.Fusion)
local Theme = require(LibStudioElttob.RbxSensation.Theme)

local function Divider(
	scope: Fusion.Scope<typeof(Fusion)>,
	props: {
		Theme: Theme.ThemeContext,
	
		Position: Fusion.UsedAs<UDim2>?,
		AnchorPoint: Fusion.UsedAs<Vector2>?,
		LayoutOrder: Fusion.UsedAs<number>?,
		ZIndex: Fusion.UsedAs<number>?,
		Visible: Fusion.UsedAs<boolean>?,
	
		Direction: Fusion.UsedAs<"horizontal" | "vertical">
	}
)
	local themeParent = props.Theme

	return scope:New "Frame" {
		Name = "Divider",

		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		Size = scope:Computed(function(use)
			return if use(props.Direction) == "horizontal" then UDim2.new(1, 0, 0, 1) else UDim2.new(0, 1, 1, 0)
		end),
		LayoutOrder = props.LayoutOrder,
		ZIndex = props.ZIndex,
		Visible = props.Visible,

		BackgroundColor3 = themeParent.fgAtopBg,
		BackgroundTransparency = 0.8,
	}
end

return Divider