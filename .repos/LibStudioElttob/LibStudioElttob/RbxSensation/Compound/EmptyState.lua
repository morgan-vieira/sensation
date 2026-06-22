--!strict
--!nolint LocalShadow
-- (c) Studio Elttob 2024. All rights reserved, seek permission before use.

local Package = script.Parent.Parent
local LibStudioElttob = Package.Parent
local LibOpen = LibStudioElttob.Parent.LibOpen

local Fusion = require(LibOpen.Fusion)
local Children, Out = Fusion.Children, Fusion.Out
local Event = require(LibOpen.Event)
local Log = require(LibStudioElttob.Log)
local Theme = require(LibStudioElttob.RbxSensation.Theme)
local Text = require(LibStudioElttob.RbxSensation.Foundation.Text)
local Button = require(LibStudioElttob.RbxSensation.Foundation.Button)
local GestureSurface = require(LibStudioElttob.RbxSensation.Input.GestureSurface)
local makeIconTheme = require(LibStudioElttob.RbxSensation.Theme.makeIconTheme)
local IconPlayer = require(LibStudioElttob.RbxVanilla.IconPlayer)

export type OptionInfo<Option> = {
	Option: Option,
	Title: string,
	Icon: string
}

local logger = Log.create("EmptyState", true)

local function EmptyState(
	scope: Fusion.Scope<typeof(Fusion)>,
	props: {
		Theme: Theme.ThemeContext,

		Icon: string?,
		Looping: boolean?,
		Text: Fusion.UsedAs<string>,
		Tip: Fusion.UsedAs<string>,

		OutSize: Fusion.Value<Vector2>?,

		AnimateEvent: nil | Event.Connect<()>,
		DoAnimate: nil | () -> (),

		Options: Fusion.UsedAs<{string}>?,
		OnOptionSelected: nil | (
			option: string
		) -> ()
	}
)
	local scope = scope:innerScope {
		IconPlayer = IconPlayer,
		Text = Text,
		GestureSurface = GestureSurface,
		Button = Button
	}

	local clickCounter = 0
	local lastClick = 0

	local iconFrame = scope:Value(nil :: Frame?)

	local theme = props.Theme
	local iconTheme = makeIconTheme(scope, theme, {
		background = "bg",
		foreground = "fg",
		style = "mono"
	})

	local wrapBounds = scope:Value(nil :: Vector2?)

	local options: Fusion.UsedAs<{string}> = props.Options or {}
	local optionsSize = scope:Value(Vector2.zero)

	if props.Icon ~= nil and not props.Looping and props.DoAnimate == nil then
		logger.warn("Empty states with non-looping icons should have animation callbacks")
	end

	return scope:New "Frame" {
		Name = "EmptyState",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,

		[Out "AbsoluteSize"] = wrapBounds,

		[Children] = {
			scope:New "UIListLayout" {
				Padding = UDim.new(0, 4),
				HorizontalAlignment = "Center",
				VerticalAlignment = "Center",
				SortOrder = "LayoutOrder",

				[Out "AbsoluteContentSize"] = props.OutSize
			},
	
			if props.Icon == nil then 
				{} :: any 
			else 
				iconFrame:set(
					scope:New "Frame" {
						Name = "Icon",
						Size = UDim2.fromOffset(48, 48),
						BackgroundTransparency = 1,
			
						[Children] = {
							scope:IconPlayer {
								Position = UDim2.fromScale(0.5, 0.5),
								AnchorPoint = Vector2.new(0.5, 0.5),
								Theme = iconTheme,
								Icon = props.Icon,
								Looping = props.Looping,
								Scale = 32,
								AnimateEvent = props.AnimateEvent,
								Interruptible = true
							} :: any,
			
							if props.Looping then {} else scope:GestureSurface {
								CornerRadius = UDim.new(0, 4),
								Color = theme.pureAtopBg,
								Activated = function()
									if os.clock() - lastClick > 2 then
										clickCounter = 1
										lastClick = os.clock()
									else
										clickCounter += 1
										lastClick = os.clock()
									end
									if props.DoAnimate ~= nil then
										props.DoAnimate()
									end
									if clickCounter > 25 then
										local QUIPS = {
											"Ouch!", "Oof!", "Hey!", "That tickles!", "That's a lot!",
											"Heh!", "Haha!", "Stop!", "Watch it!"
										}
										local animate = scope:Value(false)
										local fade = scope:Value(false)
										local angle = math.random() * math.pi
										local quipScope = scope:innerScope()
										quipScope:New "TextLabel" {
											Parent = iconFrame,
											Position = quipScope:Spring(quipScope:Computed(function(use)
												if not use(animate) then
													return UDim2.fromScale(0.5, 0.5)
												else
													return UDim2.fromScale(
														0.5 + math.cos(angle),
														0.5 - math.sin(angle)
													)
												end
											end), 50),
											AnchorPoint = Vector2.new(0.5, 0.5),
											AutomaticSize = "XY",
											BackgroundTransparency = 1,
			
											TextColor3 = theme.fgAtopBg,
											Text = QUIPS[math.random(#QUIPS)],
											TextTransparency = quipScope:Spring(quipScope:Computed(function(use)
												return if use(fade) then 0 else 1
											end), 50)
										}
										animate:set(true)
										fade:set(true)
										task.wait(0.5)
										fade:set(false)
										task.wait(0.5)
										quipScope:doCleanup()
									end
								end
							}
						}
					}
				),
	
			scope:Text {
				Theme = theme,
				Text = props.Text,
				AutomaticSize = Enum.AutomaticSize.XY,
				WrapBounds = wrapBounds,
				Align = {
					X = "mid"
				}
			},
	
			scope:Text {
				Theme = theme,
				Text = props.Tip,
				Style = "grey",
				AutomaticSize = Enum.AutomaticSize.XY,
				WrapBounds = wrapBounds,
				Align = {
					X = "mid"
				}
			},

			scope:New "Frame" {
				Name = "ButtonRow",
				Size = scope:Computed(function(use)
					return UDim2.fromOffset(use(optionsSize).X, use(optionsSize).Y)
				end),
				BackgroundTransparency = 1,

				Visible = scope:Computed(function(use)
					return #use(options) >= 1
				end),

				[Children] = {
					scope:New "UIListLayout" {
						SortOrder = "LayoutOrder",
						Padding = UDim.new(0, 4),
						FillDirection = "Horizontal",

						[Out "AbsoluteContentSize"] = optionsSize
					} :: any,

					scope:New "UIPadding" {
						PaddingTop = UDim.new(0, 4)
					},

					scope:ForPairs(
						options,
						function(
							_,
							scope: typeof(scope),
							index,
							optionName
						)
							return index, scope:Button {
								Theme = props.Theme,
								Text = optionName,
								Illuminated = index == 1,

								Activated = function()
									if props.OnOptionSelected ~= nil then
										props.OnOptionSelected(optionName)
									end
								end
							}
						end
					)
				}
			}
		}
	}
end

return EmptyState