--!strict
-- (c) Studio Elttob 2024. All rights reserved, seek permission before use.

local Package = script.Parent.Parent.Parent
local LibStudioElttob = Package.Parent
local LibOpen = LibStudioElttob.Parent.LibOpen

local Fusion = require(LibOpen.Fusion)
local peek = Fusion.peek
local Children = Fusion.Children

local function FadeTransition(
	creationProps: {
		Colour: Fusion.UsedAs<Color3>,
		EntryDirection: Fusion.UsedAs<Vector2>?,
		ExitDirection: Fusion.UsedAs<Vector2>?,
		EntryDistance: Fusion.UsedAs<number>?,
		Speed: number?
	}
)
	return function(
		scope: Fusion.Scope<typeof(Fusion)>,
		props: {
			Content: Fusion.Child,
			Shown: Fusion.StateObject<boolean>,
			TransitionCompleted: () -> ()
		}
	)
		local fade = scope:Computed(function(use)
			return if use(props.Shown) then 1 else 0
		end)
		local animFade = scope:Spring(fade, creationProps.Speed or 25)
		local exiting = scope:Computed(function(use)
			return use(animFade) > use(fade)
		end)

		local transitioning = false
		scope:Observer(fade):onChange(function()
			transitioning = true
		end)
		scope:Observer(animFade):onBind(function()
			if transitioning then
				local difference = math.abs(peek(animFade) - peek(fade))
				if difference < 0.1 then
					transitioning = false
					props.TransitionCompleted()
				end
			end
		end)

		return {
			scope:New "Frame" {
				Name = "OverlayFade",
				Size = UDim2.fromScale(1, 1),
				BackgroundColor3 = creationProps.Colour,
				BackgroundTransparency = animFade,
				ZIndex = 10
			},
			scope:New "Frame" {
				Name = "Content",
				Position = scope:Computed(function(use)
					local dir = 
						if use(exiting) then
							use(creationProps.ExitDirection or Vector2.zero) :: Vector2
						else
							use(creationProps.EntryDirection or Vector2.zero) :: Vector2
					dir *= use(creationProps.EntryDistance or 16) :: number * (1 - use(animFade))
					return UDim2.fromOffset(dir.X, dir.Y)
				end),
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				ZIndex = 1,

				[Children] = props.Content
			}
		}
	end
end

return FadeTransition