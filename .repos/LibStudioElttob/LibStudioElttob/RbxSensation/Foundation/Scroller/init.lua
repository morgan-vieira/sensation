--!strict
--!nolint LocalShadow
-- (c) Studio Elttob 2024. All rights reserved, seek permission before use.

local RunService = game:GetService("RunService")

local Package = script.Parent.Parent
local LibStudioElttob = Package.Parent
local LibOpen = LibStudioElttob.Parent.LibOpen

local Fusion = require(LibOpen.Fusion)
local peek, scoped = Fusion.peek, Fusion.scoped
local Children, Out = Fusion.Children, Fusion.Out
local IconPlayer = require(LibStudioElttob.RbxVanilla.IconPlayer)
local GestureSurface = require(Package.Input.GestureSurface)
local Theme = require(Package.Theme)
local ScrollTrack = require(script.ScrollTrack)
local ScrollCarousel = require(script.ScrollCarousel)

export type ScrollBy = number | "page" | "continuous" | "none"

local function Scroller(
	outerScope: Fusion.Scope<{}>,
	props: {
		Theme: Theme.ThemeContext,
		ScrollByX: Fusion.UsedAs<ScrollBy>,
		ScrollByY: Fusion.UsedAs<ScrollBy>,
		TrackPosition: Fusion.UsedAs<"overlay" | "aside" | "carousel">,
		CornerRadius: Fusion.UsedAs<UDim>?,
	
		Name: Fusion.UsedAs<string?>,
		Position: Fusion.UsedAs<UDim2>?,
		AnchorPoint: Fusion.UsedAs<Vector2>?,
		Size: Fusion.UsedAs<UDim2>?,
		LayoutOrder: Fusion.UsedAs<number>?,
		ZIndex: Fusion.UsedAs<number>?,
		Visible: Fusion.UsedAs<boolean>?,
	
		OutScrollPosition: Fusion.Value<Vector2?>?,
		OutScrollSize: Fusion.Value<Vector2?>?,
		OutScrollWindowSize: Fusion.Value<Vector2?>?,
	
		CanvasSize: Fusion.UsedAs<UDim2>,
	
		[typeof(Children)]: Fusion.Child
	}
)
	local scope = scoped(Fusion, {
		GestureSurface = GestureSurface,
		IconPlayer = IconPlayer,
		ScrollTrack = ScrollTrack,
		ScrollCarousel = ScrollCarousel
	})
	table.insert(outerScope, scope)

	local themeParent = props.Theme

	local scrollPosition = scope:Value(nil :: Vector2?)
	local scrollSize = scope:Value(nil :: Vector2?)
	local scrollWindowSize = scope:Value(nil :: Vector2?)

	if props.OutScrollPosition ~= nil then
		scope:Observer(scrollPosition):onChange(function()
			props.OutScrollPosition:set(peek(scrollPosition))
		end)
	end
	if props.OutScrollSize ~= nil then
		scope:Observer(scrollSize):onChange(function()
			props.OutScrollSize:set(peek(scrollSize))
		end)
	end
	if props.OutScrollWindowSize ~= nil then
		scope:Observer(scrollWindowSize):onChange(function()
			props.OutScrollWindowSize:set(peek(scrollWindowSize))
		end)
	end

	local currentlyDragging = scope:Value(false)

	local idealScrollTo = nil :: Vector2?
	local canCancelScrollTo = false
	local function scrollTo(newIdealScrollTo: Vector2)
		local shouldSpawnThread = idealScrollTo == nil
		idealScrollTo = Vector2.new(newIdealScrollTo.X // 1, newIdealScrollTo.Y // 1)
		if shouldSpawnThread then
			task.spawn(function()
				while true do
					local deltaTime = RunService.RenderStepped:Wait()
					if idealScrollTo == nil then
						break
					end
					local currentPosition = peek(scrollPosition) :: Vector2?
					local scrollSize = peek(scrollSize) :: Vector2?
					local scrollWindowSize = peek(scrollWindowSize) :: Vector2?
					if currentPosition == nil or scrollSize == nil or scrollWindowSize == nil then
						idealScrollTo = nil
						break
					end
					local speed = 20
					-- We clamp here instead of externally, because if we want
					-- to scroll somewhere but the layout hasn't caught up, we
					-- can smoothly deal with the change in sizing.
					local clampedScrollTo = Vector2.new(
						math.clamp(idealScrollTo.X, 0, math.max(0, scrollSize.X - scrollWindowSize.X)),
						math.clamp(idealScrollTo.Y, 0, math.max(0, scrollSize.Y - scrollWindowSize.Y))
					)
					local nextPosition = currentPosition:Lerp(clampedScrollTo, 1 - math.exp(-speed * deltaTime))
					if (nextPosition - idealScrollTo).Magnitude < 1 then
						canCancelScrollTo = false
						scrollPosition:set(idealScrollTo)
						canCancelScrollTo = true
						idealScrollTo = nil
						break
					else
						canCancelScrollTo = false
						scrollPosition:set(nextPosition)
						canCancelScrollTo = true
					end
				end
			end)
		end
	end
	scope:Observer(scrollPosition):onChange(function()
		if canCancelScrollTo then
			idealScrollTo = nil
		end
	end)

	return scope:New "Frame" {
		Name = props.Name or "Scroller",
		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		Size = props.Size,
		LayoutOrder = props.LayoutOrder,
		ZIndex = props.ZIndex,
		Visible = props.Visible,

		BackgroundTransparency = 1,
		ClipsDescendants = true,

		[Children] = Fusion.Child {
			scope:ForValues(
				{"vertical", "horizontal"},
				function(use, scope: typeof(scope), orientation): Fusion.Child
					local directionScrollable = scope:Computed(function(use)
						return use(if orientation == "horizontal" then props.ScrollByX else props.ScrollByY) ~= "none"
					end)

					local scrollPosition1D = if orientation == "horizontal" then
						scope:Computed(function(use)
							local original = use(scrollPosition)
							return if original == nil then nil else original.X
						end)
					else
						scope:Computed(function(use)
							local original = use(scrollPosition)
							return if original == nil then nil else original.Y
						end)
					local scrollSize1D = if orientation == "horizontal" then
						scope:Computed(function(use)
							local original = use(scrollSize)
							return if original == nil then nil else original.X
						end)
					else
						scope:Computed(function(use)
							local original = use(scrollSize)
							return if original == nil then nil else original.Y
						end)
					local scrollWindowSize1D = if orientation == "horizontal" then
						scope:Computed(function(use)
							local original = use(scrollWindowSize)
							return if original == nil then nil else original.X
						end)
					else
						scope:Computed(function(use)
							local original = use(scrollWindowSize)
							return if original == nil then nil else original.Y
						end)

					local function scrollStep(
						stepBy: number
					): ()

						local stepAxis = if orientation == "horizontal" then Vector2.xAxis else Vector2.yAxis
						local semanticScrollBy = peek(if orientation == "horizontal" then props.ScrollByX else props.ScrollByY) :: ScrollBy
						local pixelScrollBy =
							if semanticScrollBy == "page" then
								(peek(scrollWindowSize1D) or 0)
							elseif semanticScrollBy == "continuous" then
								(peek(scrollWindowSize1D) or 0) / 2
							elseif semanticScrollBy == "none" then
								0
							else
								semanticScrollBy :: number
				
						local scrollPosition = peek(scrollPosition)
						if scrollPosition ~= nil then
							local newPosition = scrollPosition + stepAxis * stepBy * pixelScrollBy
							local newPosition1D = stepAxis:Dot(newPosition)

							local magneticRadius = pixelScrollBy / 2
							local maxPosition1D = peek(scrollSize1D) :: number - peek(scrollWindowSize1D) :: number

							if newPosition1D - magneticRadius <= 0 then
								newPosition1D = 0
							elseif newPosition1D + magneticRadius >= maxPosition1D then
								newPosition1D = maxPosition1D
							end
							newPosition *= Vector2.one - stepAxis
							newPosition += stepAxis * newPosition1D
							scrollTo(newPosition)
						end
					end
					
					local function scrollSnapTo(
						position: number
					): ()
						local newScrollPos = peek(scrollPosition)
						if newScrollPos == nil then return end
						local stepAxis = if orientation == "horizontal" then Vector2.xAxis else Vector2.yAxis
						newScrollPos *= Vector2.one - stepAxis
						newScrollPos += stepAxis * position
						scrollPosition:set(newScrollPos)
					end

					return Fusion.Child {
						scope:Computed(function(use)
							local trackPosition = use(props.TrackPosition)

							if trackPosition == "overlay" or trackPosition == "aside" then
								return scope:ScrollTrack {
									Theme = themeParent,
									TrackPosition = trackPosition,
									TrackOrientation = orientation :: ScrollTrack.TrackOrientation,
			
									ScrollPosition = scrollPosition1D,
									ScrollSize = scrollSize1D,
									ScrollWindowSize = scrollWindowSize1D,
			
									Visible = directionScrollable,
			
									OnDrag = function(scope)
										currentlyDragging:set(true)
										table.insert(scope, function()
											currentlyDragging:set(false)
										end)
									end,
									OnStep = scrollStep,
									OnSnapTo = scrollSnapTo
								}
							elseif trackPosition == "carousel" then
								return scope:ScrollCarousel {
									Theme = themeParent,
									TrackOrientation = orientation :: ScrollCarousel.TrackOrientation,
			
									ScrollPosition = scrollPosition1D,
									ScrollSize = scrollSize1D,
									ScrollWindowSize = scrollWindowSize1D,
			
									Visible = directionScrollable,

									OnStep = scrollStep
								}
							else
								error("Invalid track position")
							end
						end),

						scope:New "Frame" {
							Name = "ScrollFadeArea",
							Size = scope:Computed(function(use)
								local size = UDim2.fromScale(1, 1)
								if use(props.TrackPosition) == "aside" then
									if orientation == "vertical" and use(props.ScrollByX) ~= "none" then
										size -= UDim2.fromOffset(0, 12)
									end
									if orientation == "horizontal" and use(props.ScrollByY) ~= "none" then
										size -= UDim2.fromOffset(12, 0)
									end
								end
								return size
							end),
							BackgroundTransparency = 1,
							ZIndex = 2,
	
							[Children] = scope:ForPairs({0, 1}, function(use, scope: typeof(scope), index, sideId)
								local displacement =
									if sideId == 0 then 
										scope:Computed(function(use)
											return use(scrollPosition1D) or 0
										end)
									else 
										scope:Computed(function(use)
											local scrollPosition = use(scrollPosition1D) or 0
											local scrollWindowSize = use(scrollWindowSize1D) or 0
											local scrollSize = use(scrollSize1D) or 0
											return scrollSize - scrollWindowSize - scrollPosition
										end)
								
								local MIN_WIDTH = 4
								local MAX_WIDTH = 16

								local width = scope:Computed(function(use)
									return math.clamp(MIN_WIDTH + use(displacement), 0, MAX_WIDTH)
								end)

								local oversize = scope:Computed(function(use)
									local cornerRadius = use(props.CornerRadius) :: UDim?
									if cornerRadius == nil then
										return 1
									else
										-- return 1
										return math.max(1, cornerRadius.Offset / use(width))
									end
								end)

								return index, scope:New "Frame" {
									Name = "ScrollFade",
									Position = if orientation == "horizontal" then UDim2.fromScale(sideId, 0) else UDim2.fromScale(0, sideId),
									AnchorPoint = if orientation == "horizontal" then Vector2.new(sideId, 0) else Vector2.new(0, sideId),
									Size = scope:Spring(
										scope:Computed(function(use)
											local width = use(width)

											return if orientation == "horizontal" then
												UDim2.new(0, use(oversize) * use(width), 1, 0)
											else
												UDim2.new(1, 0, 0, use(oversize) * use(width))
											
										end),
										50
									),
									BackgroundColor3 = themeParent.bg,
	
									Visible = directionScrollable,
				
									[Children] = Fusion.Child {
										scope:New "UIGradient" {
											Transparency = scope:Computed(function(use)
												return NumberSequence.new({
													NumberSequenceKeypoint.new(0, 0),
													NumberSequenceKeypoint.new(1 / use(oversize), 1),
													NumberSequenceKeypoint.new(1, 1),
												})
											end),
											Rotation = sideId * 180 + if orientation == "horizontal" then 0 else 90
										},

										if props.CornerRadius == nil then {} else
											scope:New "UICorner" {
												CornerRadius = props.CornerRadius
											}
									}
								}
							end)
						}
					}
				end
			),

			scope:New "ScrollingFrame" {
				Name = "ScrollingArea",
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Size = scope:Computed(function(use)
					local size = UDim2.fromScale(1, 1)
					if use(props.ScrollByX) ~= "none" then
						size -= UDim2.fromOffset(8, 0)
					end
					if use(props.ScrollByY) ~= "none" then
						size -= UDim2.fromOffset(0, 8)
					end
					return size
				end),
				BackgroundTransparency = 1,

				ScrollBarThickness = 0,
				ScrollingEnabled = scope:Computed(function(use)
					return not use(currentlyDragging)
				end),

				ClipsDescendants = false,

				CanvasSize = props.CanvasSize,
				CanvasPosition = scope:Computed(function(use)
					return use(scrollPosition) or Vector2.zero
				end),
				[Out "CanvasPosition"] = scrollPosition,
				[Out "AbsoluteCanvasSize"] = scrollSize,
				[Out "AbsoluteWindowSize"] = scrollWindowSize,

				[Children] = {
					scope:New "Frame" {
						Name = "Children",
						Size = scope:Computed(function(use)
							local size = UDim2.fromScale(1, 1)
							if use(props.TrackPosition) == "aside" then
								if use(props.ScrollByX) ~= "none" then
									size -= UDim2.fromOffset(0, 12)
								end
								if use(props.ScrollByY) ~= "none" then
									size -= UDim2.fromOffset(12, 0)
								end
							end
							return size
						end),
						BackgroundTransparency = 1,

						[Children] = props[Children]
					}
				}
			}
		}
	}
end

return Scroller