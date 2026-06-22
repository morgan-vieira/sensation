--!strict
--!nolint LocalShadow
-- (c) Studio Elttob 2024. All rights reserved, seek permission before use.

local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")

local Package = script.Parent.Parent
local LibStudioElttob = Package.Parent
local LibOpen = LibStudioElttob.Parent.LibOpen

local Event = require(LibOpen.Event)
local Fusion = require(LibOpen.Fusion)
local peek = Fusion.peek
local Children, OnEvent, OnChange, Out = Fusion.Children, Fusion.OnEvent, Fusion.OnChange, Fusion.Out
local IconPlayer = require(LibStudioElttob.RbxVanilla.IconPlayer)
local Bevel = require(Package.FX.Bevel)
local GestureSurface = require(Package.Input.GestureSurface)
local Halo = require(Package.FX.Halo)
local Theme = require(Package.Theme)

local function TextField<S>(
	scope: Fusion.Scope<S & typeof(Fusion)>,
	props: {
		Theme: Theme.ThemeContext,
	
		Position: Fusion.UsedAs<UDim2>?,
		AnchorPoint: Fusion.UsedAs<Vector2>?,
		Size: Fusion.UsedAs<UDim2>?,
		LayoutOrder: Fusion.UsedAs<number>?,
		ZIndex: Fusion.UsedAs<number>?,
		Visible: Fusion.UsedAs<boolean>?,
	
		Text: Fusion.UsedAs<string>,
		PlaceholderText: Fusion.UsedAs<string>?,

		Jumbo: Fusion.UsedAs<boolean>?,
		
		OnManualFocus: Event.Connect<()>?,

		RenderIcon: (
			(
				Fusion.Scope<S>,
				theme: Theme.ThemeContext,
				onAnimate: Event.Connect<()>
			) -> Fusion.Child
		)?,
	
		OnTextChanged: ((string) -> ())?,
		OnFocus: () -> ()?,
		OnUnfocus: (submitted: boolean) -> ()?
	}
)
	local scope = scope:innerScope {
		Bevel = Bevel,
		GestureSurface = GestureSurface,
		Halo = Halo,
		IconPlayer = IconPlayer
	}

	local themeParent = props.Theme
	local themeField = Theme.context.withZOffset(scope, themeParent, -1)

	local inputBox = scope:Value(nil :: TextBox?)
	local isFocused = scope:Value(false)
	local cursorPosition = scope:Value(nil :: number?)

	local onAnimate, doAnimate = Event()

	local scrollPosition = scope:Value(nil :: Vector2?)
	local scrollSize = scope:Value(nil :: Vector2?)
	local scrollWindowSize = scope:Value(nil :: Vector2?)

	local textSize = scope:Computed(function(use)
		return if use(props.Jumbo) then 16 else 14
	end)

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
	local lastScrollToCursor = 0
	local function scrollToCursor()
		local inputBox = peek(inputBox) :: TextBox?
		local scrollPosition = peek(scrollPosition) :: Vector2?
		local scrollSize = peek(scrollSize) :: Vector2?
		local scrollWindowSize = peek(scrollWindowSize) :: Vector2?
		if 
			inputBox == nil
			or inputBox.CursorPosition == -1
			or scrollPosition == nil
			or scrollSize == nil
			or scrollWindowSize == nil 
		then
			return
		end

		-- debounce so you can select things with the mouse easily
		if inputBox.SelectionStart ~= -1 and os.clock() - lastScrollToCursor < 0.5 then
			return
		end
		lastScrollToCursor = os.clock()

		local textBefore = string.sub(inputBox.Text, 1, inputBox.CursorPosition - 1)
		local textBeforeSize = TextService:GetTextSize(textBefore, inputBox.TextSize, inputBox.Font, Vector2.one * math.huge)

		local minX = scrollPosition.X + 32 
		local maxX = scrollPosition.X + scrollWindowSize.X - 32
		if minX > maxX or textBeforeSize.X < minX or textBeforeSize.X > maxX then
			scrollTo(Vector2.xAxis * (textBeforeSize.X - scrollWindowSize.X // 2))
		end
	end

	scope:Observer(scrollPosition):onChange(function()
		if canCancelScrollTo then
			idealScrollTo = nil
		end
	end)
	scope:Observer(isFocused):onChange(function()
		if peek(isFocused) then
			doAnimate()
			scrollToCursor()
		end
	end)
	scope:Observer(cursorPosition):onChange(function()
		if peek(isFocused) then
			scrollToCursor()
		end
	end)

	if props.OnManualFocus ~= nil then
		table.insert(
			scope,
			props.OnManualFocus(function()
				local inputBox = peek(inputBox)
				if inputBox ~= nil then
					inputBox:CaptureFocus()
				end
			end)
		)
	end

	return scope:New "Frame" {
		Name = "TextField",

		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		LayoutOrder = props.LayoutOrder,
		ZIndex = props.ZIndex,
		Visible = props.Visible,

		BackgroundColor3 = themeField.bg,
		Size = props.Size or scope:Computed(function(use)
			return UDim2.new(1, 0, 0, if use(props.Jumbo) then 32 else 24)
		end),

		[Children] = {
			scope:New "UICorner" {
				CornerRadius = UDim.new(0, 4)
			},

			scope:Bevel {
				CornerRadius = UDim.new(0, 4),
				Height = -1
			},
			
			scope:GestureSurface {
				Color = themeField.pureAtopBg,
				CornerRadius = UDim.new(0, 4),
				Enabled = scope:Computed(function(use)
					return not use(isFocused)
				end),
				Activated = function()
					local textBox = peek(inputBox)
					if textBox ~= nil then
						textBox:CaptureFocus()
					end
				end,
			},

			scope:Halo {
				Color = themeParent.accentAtopBg,
				CornerRadius = UDim.new(0, 4),
				Enabled = isFocused
			},

			scope:New "Frame" {
				Name = "Contents",
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,

				[Children] = {
					scope:New "UIListLayout" {
						FillDirection = "Horizontal",
						VerticalAlignment = "Center",
						SortOrder = "LayoutOrder"
					} :: any,

					scope:Computed(function(use, scope: typeof(scope))
						return if props.RenderIcon ~= nil then {
							scope:New "Frame" {
								Name = "Spacer",
								LayoutOrder = 0,
								Size = scope:Computed(function(use)
									return if use(props.Jumbo) then UDim2.fromOffset(8, 8) else UDim2.fromOffset(4, 4)
								end),
								BackgroundTransparency = 1
							},
							scope:New "Frame" {
								Name = "IconArea",
								LayoutOrder = 1,
								Size = UDim2.fromOffset(16, 16),
								BackgroundTransparency = 1,

								[Children] = props.RenderIcon(scope, themeField, onAnimate)
							},
							scope:New "Frame" {
								Name = "Spacer",
								LayoutOrder = 2,
								Size = scope:Computed(function(use)
									return if use(props.Jumbo) then UDim2.fromOffset(4, 4) else UDim2.fromOffset(0, 0)
								end),
								BackgroundTransparency = 1
							},
						} else {}
					end),

					scope:New "Frame" {
						Name = "TextArea",
						Size = UDim2.fromScale(0, 1),
						BackgroundTransparency = 1,
						LayoutOrder = 3,

						[Children] = {
							scope:New "UIFlexItem" {
								FlexMode = "Fill"
							} :: any,

							scope:New "TextLabel" {
								Name = "PlaceholderText",
								Position = scope:Spring(scope:Computed(function(use)
									return UDim2.fromOffset(6 + if use(props.Text) == "" then 0 else 16, 0)
								end), 25),
								Size = UDim2.new(1, -12, 1, 0),
								BackgroundTransparency = 1,
								ZIndex = 20,

								Font = Enum.Font.SourceSansItalic,
								Text = props.PlaceholderText,
								TextSize = textSize,
								TextColor3 = themeField.fgAtopBg,
								TextTransparency = scope:Spring(scope:Computed(function(use)
									return 
										if use(props.Text) == "" then (
											if use(isFocused) then 0.5 else 0
										) else 1
								end), 40),
								TextXAlignment = "Left",
								TextTruncate = "AtEnd",
							},

							scope:ForPairs({0, 1}, function(_, scope: typeof(scope), index, alignment)
								local displacement = 
									if alignment == 0 then 
										scope:Computed(function(use)
											local scrollPosition = use(scrollPosition)
											if scrollPosition == nil then
												return 0
											else
												return scrollPosition.X
											end
										end)
									else 
										scope:Computed(function(use)
											local scrollPosition = use(scrollPosition) :: Vector2?
											local scrollSize = use(scrollSize) :: Vector2?
											local scrollWindowSize = use(scrollWindowSize) :: Vector2?
											if scrollPosition == nil or scrollSize == nil or scrollWindowSize == nil then
												return 0
											else
												return scrollSize.X - scrollWindowSize.X - scrollPosition.X
											end
										end)
								return index, scope:New "Frame" {
									Name = "ScrollFade",
									Position = UDim2.fromScale(alignment, 0),
									AnchorPoint = Vector2.new(alignment, 0),
									Size = scope:Computed(function(use)
										return UDim2.new(0, math.min(32, (6 + use(displacement)) * 2), 1, 0)
									end),
									BackgroundColor3 = themeField.bg,
									ZIndex = 10,

									[Children] = {
										scope:New "UIGradient" {
											Transparency = NumberSequence.new({
												NumberSequenceKeypoint.new(0, 0),
												NumberSequenceKeypoint.new(0.5, 1),
												NumberSequenceKeypoint.new(1, 1)
											}),
											Rotation = alignment * 180
										},
										scope:New "UICorner" {
											CornerRadius = UDim.new(0, 4)
										}
									}
								}
							end),

							scope:New "ScrollingFrame" {
								Name = "TextScroller",

								Size = UDim2.fromScale(1, 1),
								BackgroundTransparency = 1,

								CanvasPosition = scope:Computed(function(use)
									return use(scrollPosition) or Vector2.zero
								end),
								[Out "CanvasPosition"] = scrollPosition,

								CanvasSize = UDim2.fromScale(0, 0),
								AutomaticCanvasSize = "X",
								[Out "AbsoluteCanvasSize"] = scrollSize,
								[Out "AbsoluteWindowSize"] = scrollWindowSize,

								ScrollBarThickness = 0,

								[Children] = {
									inputBox:set(
										scope:New "TextBox" {
											Name = "InputBox",
											Size = UDim2.fromScale(0, 1),
											AutomaticSize = "X",
											BackgroundTransparency = 1,
			
											Text = props.Text,
											[OnChange "Text"] = props.OnTextChanged,
			
											TextSize = textSize,
											TextColor3 = themeField.fgAtopBg,
											TextTransparency = 0,
											TextXAlignment = "Left",
			
											[OnEvent "Focused"] = function()
												isFocused:set(true)
												if props.OnFocus ~= nil then
													props.OnFocus()
												end
											end,
											[OnEvent "FocusLost"] = function(enterPressed)
												isFocused:set(false)
												if props.OnUnfocus ~= nil then
													props.OnUnfocus(enterPressed)
												end
											end,
	
											[Out "CursorPosition"] = cursorPosition,
	
											[Children] = scope:New "UIPadding" {
												PaddingLeft = UDim.new(0, 6),
												PaddingRight = UDim.new(0, 6)
											}
										}
									)
								}
							}
						}
					}
				}
			}
		}
	}
end

return TextField