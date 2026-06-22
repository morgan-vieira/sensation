--!strict
--!nolint LocalShadow
-- (c) Studio Elttob 2024. All rights reserved, seek permission before use.

local Package = script.Parent.Parent.Parent
local LibStudioElttob = Package.Parent
local LibOpen = LibStudioElttob.Parent.LibOpen

local Fusion = require(LibOpen.Fusion)
local Children = Fusion.Children
local Panel = require(LibStudioElttob.RbxSensation.Foundation.Panel)
local Button = require(LibStudioElttob.RbxSensation.Foundation.Button)
local Theme = require(Package.Theme)

export type TrackOrientation = "horizontal" | "vertical"

local function ScrollCarousel(
	scope: Fusion.Scope<typeof(Fusion)>,
	props: {
		Theme: Theme.ThemeContext,
		
		ScrollPosition: Fusion.UsedAs<number?>,
		ScrollSize: Fusion.UsedAs<number?>,
		ScrollWindowSize: Fusion.UsedAs<number?>,

		TrackOrientation: TrackOrientation,

		Visible: Fusion.UsedAs<boolean>,

		OnStep: (stepBy: number) -> ()
	}
): Fusion.Child
	local scope = scope:innerScope {
		Panel = Panel,
		Button = Button
	}

	local themeFloating = Theme.context.withZOffset(scope, props.Theme, 1)

	return scope:ForPairs({0, 1}, function(use, scope: typeof(scope), index, sideId)
		local PADDING = 4
		return index, scope:Panel {
			Name = "CarouselButtonArea",
			Theme = themeFloating,

			Position = if props.TrackOrientation == "horizontal" then
					UDim2.new(sideId, (1 - 2*sideId) * PADDING, 0.5, 0)
				else
					UDim2.new(0.5, 0, sideId, (1 - 2*sideId) * PADDING),
			AnchorPoint = if props.TrackOrientation == "horizontal" then
					Vector2.new(sideId, 0.5)
				else
					Vector2.new(0.5, sideId),
			Size = UDim2.fromOffset(32, 32),

			ZIndex = 3,

			Transparency = scope:Spring(scope:Computed(function(use)
				local position = use(props.ScrollPosition) :: number?
				local size = use(props.ScrollSize) :: number?
				local windowSize = use(props.ScrollWindowSize) :: number?
				if position == nil or size == nil or windowSize == nil then
					return 1
				end
				if windowSize >= size then
					return 1
				end
				if sideId == 0 and position < 1  then
					return 1
				end
				if sideId == 1 and position > size - windowSize - 1 then
					return 1
				end
				return 0
			end), 25),

			[Children] = scope:Button {
				Theme = themeFloating,

				Icon = if props.TrackOrientation == "horizontal" then
					if sideId == 0 then "arrowLeftSmall" else "arrowRightSmall"
				else
					if sideId == 0 then "arrowUpSmall" else "arrowDownSmall",
				Interruptible = true,

				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Size = UDim2.new(1, -8, 1, -8),

				Activated = function()
					if sideId == 0 then
						props.OnStep(-1)
					else
						props.OnStep(1)
					end
				end
			}
		}
	end)
end

return ScrollCarousel