--!strict
-- (c) Studio Elttob 2024. All rights reserved, seek permission before use.

local Package = script.Parent.Parent
local LibStudioElttob = Package.Parent
local LibOpen = LibStudioElttob.Parent.LibOpen

local Fusion = require(LibOpen.Fusion)
local Children = Fusion.Children

local function Bevel(
	scope: Fusion.Scope<typeof(Fusion)>,
	props: {
		Height: Fusion.UsedAs<number>?,
		Thickness: Fusion.UsedAs<number>?,
		CornerRadius: Fusion.UsedAs<UDim>?,
	}
)
	local inverted = scope:Computed(function(use)
		return use(props.Height or 1) < 0
	end)

	return scope:New "Frame" {
		Position = scope:Computed(function(use)
			if use(inverted) then
				return UDim2.new()
			else
				local thickness = use(props.Thickness or 1)
				return UDim2.fromOffset(thickness, thickness)
			end
		end),
		Size = scope:Computed(function(use)
			if use(inverted) then
				return UDim2.fromScale(1, 1)
			else
				local thickness = use(props.Thickness or 1)
				return UDim2.new(1, -thickness * 2, 1, -thickness * 2)
			end
		end),
		BackgroundTransparency = 1,
		ZIndex = 2000,

		[Children] = scope:ForPairs({0, 1}, function(_, scope: typeof(scope), index, topBottom)
			local isShaded = scope:Computed(function(use)
				return if use(inverted) then topBottom == 0 else topBottom == 1
			end)
			return index, scope:New "Frame" {
				Position = UDim2.fromScale(0, topBottom),
				AnchorPoint = Vector2.new(0, topBottom),
				Size = UDim2.new(1, 0, 0, 32),
				BackgroundTransparency = 1,

				[Children] = {
					if props.CornerRadius ~= nil then {
						scope:New "UICorner" {
							CornerRadius = scope:Computed(function(use)
								local thickness = use(props.Thickness or 1)
								local offset = if use(inverted) then 0 else -thickness
								return use(props.CornerRadius) :: UDim + UDim.new(0, offset)
							end)
						}
					} else {} :: any,
		
					scope:New "UIStroke" {
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
						Color = Color3.new(1, 1, 1),
						LineJoinMode = Enum.LineJoinMode.Round,
						Thickness = props.Thickness,
						Transparency = 0,
		
						[Children] = scope:New "UIGradient" {
							Color = scope:Computed(function(use)
								return ColorSequence.new(
									if use(isShaded) then Color3.new(0, 0, 0) else Color3.new(1, 1, 1)
								)
							end),
							Transparency = scope:Computed(function(use)
								local intensity = math.clamp(math.abs(use(props.Height or 1)), 0, 1)
								intensity *= if use(isShaded) then 0.15 else 0.2
								return NumberSequence.new({
									NumberSequenceKeypoint.new(0, 1 - intensity),
									NumberSequenceKeypoint.new(0.1, 1),
									NumberSequenceKeypoint.new(1, 1),
								})
							end),
							Rotation = if topBottom == 0 then 90 else -90
						}
					}
				}
			}
		end)
	}
end

return Bevel