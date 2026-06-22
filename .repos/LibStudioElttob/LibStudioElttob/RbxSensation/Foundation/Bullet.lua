--!strict
-- (c) Studio Elttob 2024. All rights reserved, seek permission before use.

local Package = script.Parent.Parent
local LibStudioElttob = Package.Parent
local LibOpen = LibStudioElttob.Parent.LibOpen

local Fusion = require(LibOpen.Fusion)
local Children = Fusion.Children
local Theme = require(LibStudioElttob.RbxSensation.Theme)

local function Bullet(
	scope: Fusion.Scope<typeof(Fusion)>,
	props: {
		Theme: Theme.ThemeContext,
	
		Position: Fusion.UsedAs<UDim2>?,
		AnchorPoint: Fusion.UsedAs<Vector2>?,
		Size: Fusion.UsedAs<UDim2>?,
		AutomaticSize: Fusion.UsedAs<Enum.AutomaticSize>?,
		LayoutOrder: Fusion.UsedAs<number>?,
		ZIndex: Fusion.UsedAs<number>?,
		Visible: Fusion.UsedAs<boolean>?,
	
		[typeof(Children)]: Fusion.Child,
	}
)
	local themeParent = props.Theme

	return scope:New "Frame" {
		Name = "Bullet",

		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		Size = props.Size,
		AutomaticSize = props.AutomaticSize,
		LayoutOrder = props.LayoutOrder,
		ZIndex = props.ZIndex,
		Visible = props.Visible,

		BackgroundTransparency = 1,

		[Children] = {
			scope:New "Frame" {
				Name = "BulletMark",
				BackgroundColor3 = themeParent.fgAtopBg,
				Position = UDim2.fromOffset(2, 8),
				AnchorPoint = Vector2.new(0, 0.5),
				Size = UDim2.fromOffset(4, 4),

				[Children] = scope:New "UICorner" {
					CornerRadius = UDim.new(1, 0)
				}
			},
			scope:New "Frame" {
				Name = "Contents",
				Position = UDim2.new(0, 12, 0, 0),
				Size = UDim2.new(1, -12, 0, 0),
				AutomaticSize = props.AutomaticSize,

				BackgroundTransparency = 1,

				[Children] = props[Children]
			}
		}
	}
end

return Bullet