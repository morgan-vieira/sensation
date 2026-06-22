--!strict
-- (c) Studio Elttob 2024. All rights reserved, seek permission before use.

local Package = script.Parent.Parent
local LibStudioElttob = Package.Parent
local LibOpen = LibStudioElttob.Parent.LibOpen

local Fusion = require(LibOpen.Fusion)
local Children = Fusion.Children

local function Shadow(
	scope: Fusion.Scope<typeof(Fusion)>,
    props: {
		Elevation: Fusion.UsedAs<number>?,
		CornerRadius: Fusion.UsedAs<UDim>?
	}
)
    local inset = scope:Computed(function(use)
        return use(props.Elevation or 0) < 0
    end)

    return scope:New "Frame" {
        Position = scope:Computed(function(use)
            return if use(inset) then UDim2.fromOffset(1, 1) else UDim2.fromOffset(0, 0)
        end),
        Size = scope:Computed(function(use)
            return if use(inset) then UDim2.new(1, -2, 1, -2) else UDim2.fromScale(1, 1)
        end),
        BackgroundTransparency = 1,
        ZIndex = 2000,

        [Children] = {
            if props.CornerRadius ~= nil then {
                scope:New "UICorner" {
                    CornerRadius = scope:Computed(function(use)
                        local offset = if use(inset) then -1 else 0
                        return use(props.CornerRadius) :: UDim + UDim.new(0, offset)
                    end)
                }
            } else {} :: any,

            scope:New "UIStroke" {
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                Color = Color3.new(0, 0, 0),
                LineJoinMode = Enum.LineJoinMode.Round,
                Thickness = 1,
                Transparency = 0.9
            }
        }
    }
end

return Shadow