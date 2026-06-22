--!strict
-- (c) Studio Elttob 2024. All rights reserved, seek permission before use.

local Package = script.Parent.Parent
local LibStudioElttob = Package.Parent
local LibOpen = LibStudioElttob.Parent.LibOpen

local Fusion = require(LibOpen.Fusion)
local Children = Fusion.Children

local function Halo(
	scope: Fusion.Scope<typeof(Fusion)>,
	props: {
		Color: Fusion.UsedAs<Color3>?,
		Thickness: Fusion.UsedAs<number>?,
		CornerRadius: Fusion.UsedAs<UDim>?,
		Enabled: Fusion.UsedAs<boolean>
	}
)
	return scope:New "Frame" {
		Position = scope:Computed(function(use)
			local halfThickness = use(props.Thickness or 2) :: number // 2
			return UDim2.fromOffset(halfThickness, halfThickness)
		end),
		Size = scope:Computed(function(use)
			local halfThickness = use(props.Thickness or 2) :: number // 2
			return UDim2.new(1, -halfThickness * 2, 1, -halfThickness * 2)
		end),
		BackgroundTransparency = 1,
		ZIndex = 3000,

		[Children] = {
			if props.CornerRadius ~= nil then {
				scope:New "UICorner" {
					CornerRadius = scope:Computed(function(use)
						local halfThickness = use(props.Thickness or 2) :: number // 2
						local offset = -halfThickness
						return use(props.CornerRadius) :: UDim + UDim.new(0, offset)
					end)
				}
			} else {} :: any,

			scope:New "UIStroke" {
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Color = props.Color,
				LineJoinMode = Enum.LineJoinMode.Round,
				Thickness = scope:Spring(scope:Computed(function(use)
					return use(props.Thickness or 2) :: any + if use(props.Enabled) then 0 else 4
				end), 25),
				Transparency = scope:Spring(scope:Computed(function(use)
					return if use(props.Enabled) then 0 else 1
				end), 50)
			}
		}
	}
end

return Halo