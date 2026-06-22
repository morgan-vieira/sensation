--!strict
-- (c) Studio Elttob 2024. All rights reserved, seek permission before use.

local Package = script.Parent.Parent
local LibStudioElttob = Package.Parent
local LibOpen = LibStudioElttob.Parent.LibOpen

local Fusion = require(LibOpen.Fusion)
local scoped = Fusion.scoped
local Children, Out = Fusion.Children, Fusion.Out
local Shadow = require(Package.FX.Shadow)
local LightweightCanvas = require(Package.FX.LightweightCanvas)
local Theme = require(Package.Theme)

local SHADOW_MARGIN = 64

local function Panel(
	outerScope: Fusion.Scope<{}>,
	props: {
		Theme: Theme.ThemeContext,

		Name: Fusion.UsedAs<string>?,
		Elevation: Fusion.UsedAs<number>?,
		Transparency: Fusion.UsedAs<number>?,
	
		Position: Fusion.UsedAs<UDim2>?,
		AnchorPoint: Fusion.UsedAs<Vector2>?,
		Size: Fusion.UsedAs<UDim2>?,
		LayoutOrder: Fusion.UsedAs<number>?,
		ZIndex: Fusion.UsedAs<number>?,
		Visible: Fusion.UsedAs<boolean>?,

		OutSize: Fusion.Value<Vector2>?,
	
		[typeof(Children)]: Fusion.Child
	}
)
	local scope = scoped(Fusion, {
		Shadow = Shadow,
		LightweightCanvas = LightweightCanvas
	})
	table.insert(outerScope, scope)
	local themeParent = props.Theme

	return scope:New "Frame" {
		Name = props.Name or "Panel",

		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		Size = props.Size,
		LayoutOrder = props.LayoutOrder,
		ZIndex = props.ZIndex,
		Visible = props.Visible,

		BackgroundTransparency = 1,

		[Out "AbsoluteSize"] = props.OutSize,

		[Children] = scope:LightweightCanvas {
			Name = "ClipArea",
			Position = UDim2.new(0, -SHADOW_MARGIN, 0, -SHADOW_MARGIN),
			Size = UDim2.new(1, SHADOW_MARGIN * 2, 1, SHADOW_MARGIN * 2),
			BackgroundTransparency = 1,

			GroupTransparency = props.Transparency or 0,
			Visible = props.Visible,

			PersistentChildren = scope:New "Frame" {
				Name = "Backplate",
		
				Position = UDim2.new(0, SHADOW_MARGIN, 0, SHADOW_MARGIN),
				Size = UDim2.new(1, -SHADOW_MARGIN * 2, 1, -SHADOW_MARGIN * 2),
		
				BackgroundColor3 = themeParent.bg,
		
				[Children] = {
					scope:New "UICorner" {
						CornerRadius = UDim.new(0, 8)
					},
		
					scope:Shadow {
						CornerRadius = UDim.new(0, 8),
						Elevation = props.Elevation
					},
		
					scope:New "Frame" {
						Name = "Contents",
						Size = UDim2.fromScale(1, 1),
						BackgroundTransparency = 1,
		
						[Children] = props[Children]
					}
				}
			}
		}
	}
end

return Panel