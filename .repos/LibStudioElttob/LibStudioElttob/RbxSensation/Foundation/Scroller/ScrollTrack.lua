--!strict
--!nolint LocalShadow
-- (c) Studio Elttob 2024. All rights reserved, seek permission before use.

local Package = script.Parent.Parent.Parent
local LibStudioElttob = Package.Parent
local LibOpen = LibStudioElttob.Parent.LibOpen

local Event = require(LibOpen.Event)
local Fusion = require(LibOpen.Fusion)
local peek = Fusion.peek
local Children, Out = Fusion.Children, Fusion.Out
local IconPlayer = require(LibStudioElttob.RbxVanilla.IconPlayer)
local GestureSurface = require(Package.Input.GestureSurface)
local MousePredictor = require(Package.Input.MousePredictor)
local OnHover = require(Package.Input.OnHover)
local Theme = require(Package.Theme)
local makeIconTheme = require(Package.Theme.makeIconTheme)

export type TrackPosition = "aside" | "overlay"
export type TrackOrientation = "horizontal" | "vertical"

local function ScrollTrack<S>(
	scope: Fusion.Scope<S & typeof(Fusion)>,
	props: {
		Theme: Theme.ThemeContext,
		
		ScrollPosition: Fusion.UsedAs<number?>,
		ScrollSize: Fusion.UsedAs<number?>,
		ScrollWindowSize: Fusion.UsedAs<number?>,

		TrackPosition: Fusion.UsedAs<TrackPosition>,
		TrackOrientation: TrackOrientation,

		Visible: Fusion.UsedAs<boolean>,

		OnDrag: (Fusion.Scope<S & typeof(Fusion)>) -> (),

		OnStep: (stepBy: number) -> (),
		OnSnapTo: (position: number) -> (),
	}
): Fusion.Child
	local scope = scope:innerScope {
		GestureSurface = GestureSurface,
		IconPlayer = IconPlayer
	}

	local themeParent = props.Theme
	local themeTrack = Theme.context.withZOffset(scope, themeParent, -1)
	local iconTheme = makeIconTheme(scope, themeParent, {
		background = "bg",
		foreground = "fg",
		style = "trio"
	})

	local isOverflowing = scope:Computed(function(use)
		local size = use(props.ScrollSize) :: number?
		local windowSize = use(props.ScrollWindowSize) :: number?
		if size == nil or windowSize == nil then
			return false
		else
			return size > windowSize
		end
	end)
	local animOverflowing = scope:Spring(scope:Computed(function(use)
		return if use(isOverflowing) then 1 else 0
	end), 25)
	
	local isHovering = scope:Value(false)
	local animHovering = scope:Spring(scope:Computed(function(use)
		return if use(isHovering) then 1 else 0
	end), 50)

	local trackSize = scope:Value(nil :: Vector2?)
	local isHoveringTrack = scope:Value(false)

	type CurrentDrag = {
		type: "thumb",
		-- 0 = cursor anchored to neg edge, 1 = cursor anchored to pos edge
		anchorPoint: number
	} | {
		type: "jump"
	}

	local currentDrag = scope:Value(nil :: CurrentDrag?)
	local animDragging = scope:Spring(scope:Computed(function(use)
		return if use(currentDrag) ~= nil then 1 else 0
	end), 50)
	local animDraggingThumb = scope:Spring(scope:Computed(function(use)
		local currentDrag = use(currentDrag)
		return if currentDrag ~= nil and currentDrag.type == "thumb" then 1 else 0
	end), 50)
	local animDraggingJump = scope:Spring(scope:Computed(function(use)
		local currentDrag = use(currentDrag)
		return if currentDrag ~= nil and currentDrag.type == "jump" then 1 else 0
	end), 25)

	local animThumbWidth = scope:Computed(function(use)
		return math.max(use(animDragging), use(animHovering))
	end)
	local thumbTransparency = scope:Computed(function(use)
		return math.max(1 - use(animOverflowing), (1 - use(animThumbWidth)) * 0.6)
	end)

	local animIconsTransparency = scope:Computed(function(use)
		return 1 - math.max(use(animDragging), use(animHovering)) * (use(animOverflowing) / 2 + 0.5)
	end)

	return scope:New "Frame" {
		Name = "ScrollTrack",

		Position = if props.TrackOrientation == "horizontal" then
				UDim2.new(0, 0, 1, 0)
			else
				UDim2.new(1, 0, 0, 0),
		AnchorPoint = if props.TrackOrientation == "horizontal" then
				Vector2.new(0, 1)
			else
				Vector2.new(1, 0),
		Size = scope:Computed(function(use)
			local width = 12
			if use(props.TrackPosition) == "overlay" then
				width = math.round(8 + use(animThumbWidth) * 4)
			end
			return if props.TrackOrientation == "horizontal" then
					UDim2.new(1, 0, 0, width)
				else
					UDim2.new(0, width, 1, 0)
		end),

		BackgroundColor3 = themeParent.bg,
		BackgroundTransparency = scope:Computed(function(use)
			return if use(props.TrackPosition) == "overlay" then
					1 - use(animThumbWidth)
				else
					0
		end),

		ZIndex = 3,
		Visible = props.Visible,

		[OnHover] = function(
			scope: typeof(scope)
		): ()
			isHovering:set(true)
			table.insert(scope, function()
				isHovering:set(false)
			end)
		end,

		[Children] = {
			scope:ForPairs({0, 1}, function(use, scope: typeof(scope), index, sideId)
				local onAnimate, doAnimate = Event()

				return index, scope:New "Frame" {
					Name = "ScrollButtonArea",

					Position = scope:Computed(function(use)
						local along = UDim.new(sideId, 0)
						local across = UDim.new(0, 0)
						if use(props.TrackPosition) == "overlay" then
							across += UDim.new(1 - use(animThumbWidth), 0)
						end
						return if props.TrackOrientation == "horizontal" then
							UDim2.new(along, across)
						else
							UDim2.new(across, along)

					end),
					AnchorPoint = if props.TrackOrientation == "horizontal" then
							Vector2.new(sideId, 0)
						else
							Vector2.new(0, sideId),
					Size = if props.TrackOrientation == "horizontal" then
							UDim2.fromOffset(20, 12)
						else
							UDim2.fromOffset(12, 20),

					BackgroundTransparency = 1,

					ClipsDescendants = true,

					[Children] = {
						scope:GestureSurface {
							Color = themeTrack.pureAtopBg,
							CornerRadius = UDim.new(0, 4),
							Activated = function()
								doAnimate()
								if sideId == 0 then
									props.OnStep(-1)
								else
									props.OnStep(1)
								end
							end
						},

						scope:IconPlayer {
							Theme = iconTheme,
							Icon = if props.TrackOrientation == "horizontal" then
								if sideId == 0 then "arrowLeftSmall" else "arrowRightSmall"
							else
								if sideId == 0 then "arrowUpSmall" else "arrowDownSmall",
							Transparency = animIconsTransparency,
							AnimateEvent = onAnimate,
							Interruptible = true,

							Position = UDim2.fromScale(0.5, 0.5),
							AnchorPoint = Vector2.new(0.5, 0.5)
						}
					}
				}
			end) :: any,

			scope:New "Frame" {
				Name = "TrackArea",

				Position = if props.TrackOrientation == "horizontal" then
						UDim2.new(0, 20, 0, 0)
					else
						UDim2.new(0, 0, 0, 20),
				Size = if props.TrackOrientation == "horizontal" then
						UDim2.new(1, -40, 1, 0)
					else
						UDim2.new(1, 0, 1, -40),
				
				BackgroundTransparency = 1,
				
				[Out "AbsoluteSize"] = trackSize,

				[OnHover] = function(
					scope: typeof(scope)
				): ()
					isHoveringTrack:set(true)
					table.insert(scope, function()
						isHoveringTrack:set(false)
					end)
				end,

				[Children] = {
					scope:GestureSurface {
						Color = themeTrack.pureAtopBg,
						CornerRadius = UDim.new(1, 0),

						OnDrag = function(
							scope: typeof(scope),
							predictor: MousePredictor.Predictor
						): ()
							local mousePos = predictor.predict(scope, 0)
							do
								local scrollPosition = peek(props.ScrollPosition) :: number?
								local scrollSize = peek(props.ScrollSize) :: number?
								local scrollWindowSize = peek(props.ScrollWindowSize) :: number?
								local trackSize = peek(trackSize) :: Vector2?
								if 
									scrollPosition == nil or 
									scrollSize == nil or 
									scrollWindowSize == nil or 
									trackSize == nil
								then
									return
								end
								local trackSize = if props.TrackOrientation == "horizontal" then 
										trackSize.X 
									else 
										trackSize.Y
								local mousePos = if props.TrackOrientation == "horizontal" then 
										peek(mousePos).X 
									else 
										peek(mousePos).Y
								
								local thumbStart = scrollPosition / scrollSize * trackSize
								local thumbEnd = thumbStart + scrollWindowSize / scrollSize * trackSize
								local draggingThumb = mousePos >= thumbStart and mousePos <= thumbEnd
								
								if draggingThumb then
									currentDrag:set({
										type = "thumb",
										anchorPoint = (mousePos - thumbStart) / (thumbEnd - thumbStart)
									})
								else
									currentDrag:set({
										type = "jump"
									})
								end
								table.insert(scope, function()
									currentDrag:set(nil)
								end)
								props.OnDrag(scope)
							end
							scope:Observer(mousePos):onBind(function()
								local mousePos = peek(mousePos) :: Vector2
								local currentDrag = peek(currentDrag) :: CurrentDrag?
								local scrollSize = peek(props.ScrollSize) :: number?
								local scrollWindowSize = peek(props.ScrollWindowSize) :: number?
								local trackSize = peek(trackSize) :: Vector2?
								if
									currentDrag == nil or
									scrollSize == nil or 
									scrollWindowSize == nil or 
									trackSize == nil
								then
									return
								end
								local trackSize = if props.TrackOrientation == "horizontal" then 
										trackSize.X 
									else 
										trackSize.Y
								local mousePos = if props.TrackOrientation == "horizontal" then 
										peek(mousePos).X 
									else 
										peek(mousePos).Y
								
								if currentDrag.type == "thumb" then
									local posScale = mousePos / trackSize
									local thumbLengthScale = scrollWindowSize / scrollSize
									local thumbStartScale = posScale - thumbLengthScale * currentDrag.anchorPoint
									local newScrollPos = math.clamp(thumbStartScale * scrollSize, 0, scrollSize - scrollWindowSize)
									props.OnSnapTo(newScrollPos)
								elseif currentDrag.type == "jump" then
									local scrollTo = mousePos / trackSize * scrollSize
									local newScrollPos = math.clamp(scrollTo - scrollWindowSize // 2, 0, scrollSize - scrollWindowSize)
									props.OnSnapTo(newScrollPos)
								end
							end)
						end
					},

					scope:New "Frame" {
						Name = "TrackThumb",
						Position = scope:Computed(function(use)
							local scrollPosition = use(props.ScrollPosition) or 0
							local scrollSize = use(props.ScrollSize) or 0
							local scrollWindowSize = use(props.ScrollWindowSize) or 0
							return if props.TrackOrientation == "horizontal" then
									UDim2.fromScale((scrollPosition + 0.5 * scrollWindowSize) / scrollSize, 0.5)
								else
									UDim2.fromScale(0.5, (scrollPosition + 0.5 * scrollWindowSize) / scrollSize)
						end),
						AnchorPoint = Vector2.new(0.5, 0.5),
						Size = scope:Computed(function(use)
							local scrollSize = use(props.ScrollSize) or 0
							local scrollWindowSize = use(props.ScrollWindowSize) or 0
							local size = if props.TrackOrientation == "horizontal" then
									UDim2.new(scrollWindowSize / scrollSize, 0, 0, use(animThumbWidth) * 10 + 2)
								else
									UDim2.new(0, use(animThumbWidth) * 10 + 2, scrollWindowSize / scrollSize, 0)
							return size - UDim2.fromOffset(6 * use(animDraggingThumb), 6 * use(animDraggingThumb))
						end),
						BackgroundColor3 = themeTrack.fgAtopBg,
						BackgroundTransparency = scope:Computed(function(use)
							local transparency = use(thumbTransparency)
							transparency = 1 - (1 - transparency) * (1 - use(animDraggingJump))
							return transparency
						end),

						[Children] = {
							scope:New "UICorner" {
								CornerRadius = UDim.new(1, 0)
							},

							scope:New "Frame" {
								Name = "JumpStroke",
								Position = UDim2.new(0, 2, 0, 2),
								Size = UDim2.new(1, -4, 1, -4),
								BackgroundTransparency = 1,
								Visible = scope:Computed(function(use)
									return use(animDraggingJump) > 0.01
								end),

								[Children] = {
									scope:New "UICorner" {
										CornerRadius = UDim.new(1, 0)
									},
									scope:New "UIStroke" {
										Transparency = scope:Computed(function(use)
											return use(thumbTransparency) * 0.6 + 0.4
										end),
										Thickness = 2,
										Color = themeTrack.fgAtopBg
									}
								}
							}
						}
					}
				}
			}
		}
	}
end

return ScrollTrack