--!strict
-- (c) Studio Elttob 2024. All rights reserved, seek permission before use.

local Package = script.Parent.Parent
local LibStudioElttob = Package.Parent
local LibOpen = LibStudioElttob.Parent.LibOpen

local Event = require(LibOpen.Event)
local Fusion = require(LibOpen.Fusion)
local scoped = Fusion.scoped
local Children = Fusion.Children
local IconPlayer = require(LibStudioElttob.RbxVanilla.IconPlayer)
local Theme = require(Package.Theme)
local makeIconTheme = require(Package.Theme.makeIconTheme)
local Panel = require(Package.Foundation.Panel)
local Text = require(Package.Foundation.Text)
local GestureSurface = require(Package.Input.GestureSurface)

local function Expander(
	outerScope: Fusion.Scope<typeof(Fusion)>,
	props: {
		LayoutOrder: number,
		Theme: Theme.ThemeContext,
		Icon: string,
		Title: Fusion.UsedAs<string>,
		InnerSize: Fusion.UsedAs<Vector2>?,
		IsExpanded: Fusion.UsedAs<boolean>?,
		OnToggle: () -> (),

		[typeof(Children)]: Fusion.Child
	}
): Fusion.Child
	local scope = scoped(Fusion, {
		Panel = Panel,
		Text = Text,
		GestureSurface = GestureSurface,
		IconPlayer = IconPlayer
	})
	table.insert(outerScope, scope)

	local onAnimate, doAnimate: () -> () = Event()

	local themePanel = Theme.context.withZOffset(scope, props.Theme, 1)

	local titleIconTheme = makeIconTheme(scope, themePanel, {
		background = "bg",
		foreground = "accent",
		style = "trio"
	})

	local animExpanded = scope:Spring(scope:Computed(function(use)
		return if use(props.IsExpanded) then 1 else 0
	end), 25)

	local panelSize = scope:Computed(function(use)
		return (use(props.InnerSize) or Vector2.zero) * use(animExpanded) + Vector2.new(16, 32)
	end)

	return scope:Panel {
		LayoutOrder = props.LayoutOrder,
		Theme = themePanel,
		Size = scope:Computed(function(use)
			return UDim2.new(1, 0, 0, use(panelSize).Y)
		end),

		[Children] = {
			scope:New "Frame" {
				Name = "Title",
				Position = UDim2.fromOffset(4, 4),
				Size = UDim2.new(1, -8, 0, 24),
				BackgroundTransparency = 1,

				[Children] = {
					scope:GestureSurface {
						Color = themePanel.pureAtopBg,
						CornerRadius = UDim.new(0, 4),

						Activated = function()
							doAnimate()
							props.OnToggle()
						end
					},

					scope:IconPlayer {
						Theme = titleIconTheme,
						Icon = props.Icon,
						Interruptible = true,
						Position = UDim2.fromOffset(4, 4),
						AnimateEvent = onAnimate
					},

					scope:Text {
						Theme = themePanel,
						Text = props.Title,
						Position = UDim2.new(0, 24, 0.5, 0),
						Size = UDim2.new(1, -28, 0, 8),
						AutomaticSize = Enum.AutomaticSize.Y,
						AnchorPoint = Vector2.new(0, 0.5),
						Style = "accent"
					}
				}
			},

			scope:New "Frame" {
				Name = "Content",
				Position = UDim2.fromScale(0, 1),
				AnchorPoint = Vector2.new(0, 1),
				Size = UDim2.new(1, 0, 1, -32),
				BackgroundTransparency = 1,
				ClipsDescendants = true,

				[Children] = props[Children]
			}
		}
	}
end

return Expander