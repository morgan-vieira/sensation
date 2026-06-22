--!strict
-- (c) Studio Elttob 2024. All rights reserved, seek permission before use.

local Package = script.Parent.Parent
local LibStudioElttob = Package.Parent
local LibOpen = LibStudioElttob.Parent.LibOpen

local Fusion = require(LibOpen.Fusion)
local scoped = Fusion.scoped
local Children = Fusion.Children
local Theme = require(Package.Theme)
local Bevel = require(Package.FX.Bevel)
local GestureSurface = require(Package.Input.GestureSurface)

local function Switch(
	outerScope: Fusion.Scope<{}>,
	props: {
		Theme: Theme.ThemeContext,
	
		Position: Fusion.UsedAs<UDim2>?,
		AnchorPoint: Fusion.UsedAs<Vector2>?,
		LayoutOrder: Fusion.UsedAs<number>?,
		ZIndex: Fusion.UsedAs<number>?,
		Visible: Fusion.UsedAs<boolean>?,
	
		Activated: Fusion.UsedAs<boolean>,
		OnClick: () -> ()
	}
)
	local scope = scoped(Fusion, {
		Bevel = Bevel,
		GestureSurface = GestureSurface
	})
	local themeParent = props.Theme

	local backgroundColour = scope:Spring(scope:Computed(function(use)
		return if use(props.Activated) then use(themeParent.accentAtopBg) else use(themeParent.greyAtopBg)
	end), 50)
	local knobColour = scope:Spring(scope:Computed(function(use)
		return if use(props.Activated) then use(themeParent.fgAtopAccentAtopBg) else use(themeParent.fgAtopGreyAtopBg)
	end), 50)

	local animSmudge
	do
		local animLead = scope:Spring(scope:Computed(function(use)
			return if use(props.Activated) then 1 else 0
		end), 50)
		local animFollow = scope:Spring(animLead, 50)
		animSmudge = scope:Computed(function(use)
			return math.abs(use(animLead) :: number - use(animFollow)) / 2
		end)
	end

	return scope:New "Frame" {
		Name = "Switch",

		Visible = props.Visible,
		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		ZIndex = props.ZIndex,
		LayoutOrder = props.LayoutOrder,

		BackgroundColor3 = backgroundColour,
		Size = UDim2.fromOffset(32, 16),

		[Children] = {
			scope:New "UICorner" {
				CornerRadius = UDim.new(1, 0)
			},
			scope:Bevel {
				CornerRadius = UDim.new(1, 0)
			},
			scope:GestureSurface {
				Color = themeParent.pureAtopAccentAtopBg,
				CornerRadius = UDim.new(1, 0),
				Activated = props.OnClick,
			},

			scope:New "Frame" {
				Name = "KnobTrack",
				Position = UDim2.fromOffset(2, 2),
				Size = UDim2.new(1, -4, 1, -4),
				BackgroundTransparency = 1,

				[Children] = {
					scope:New "Frame" {
						Name = "Knob",
						
						BackgroundColor3 = knobColour,
						Size = scope:Computed(function(use)
							return UDim2.fromScale(1 + use(animSmudge), 1 - use(animSmudge))
						end),
						AnchorPoint = scope:Spring(scope:Computed(function(use)
							return if use(props.Activated) then Vector2.new(1, 0.5) else Vector2.new(0, 0.5)
						end), 50),
						Position = scope:Spring(scope:Computed(function(use)
							return if use(props.Activated) then UDim2.fromScale(1, 0.5) else UDim2.fromScale(0, 0.5)
						end), 50),
						SizeConstraint = "RelativeYY",
						
						[Children] = {
							scope:New "UICorner" {
								CornerRadius = UDim.new(1, 0)
							}
						}
					}
				}
			}
		}
	}
end

return Switch