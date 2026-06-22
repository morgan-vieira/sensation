--!strict
-- (c) Studio Elttob 2024. All rights reserved, seek permission before use.

local Package = script.Parent.Parent
local LibStudioElttob = Package.Parent
local LibOpen = LibStudioElttob.Parent.LibOpen

local Event = require(LibOpen.Event)
local Fusion = require(LibOpen.Fusion)
local scoped = Fusion.scoped
local Children, Out = Fusion.Children, Fusion.Out
local Theme = require(LibStudioElttob.RbxSensation.Theme)
local makeIconTheme = require(LibStudioElttob.RbxSensation.Theme.makeIconTheme)
local Text = require(LibStudioElttob.RbxSensation.Foundation.Text)
local IconPlayer = require(LibStudioElttob.RbxVanilla.IconPlayer)

local function Warning(
	outerScope: Fusion.Scope<{}>,
	props: {
		Theme: Theme.ThemeContext,
		Warning: Fusion.StateObject<string?>,
		AnimateEvent: Event.Connect<>,
	
		Position: Fusion.UsedAs<UDim2>?,
		AnchorPoint: Fusion.UsedAs<Vector2>?,
		LayoutOrder: Fusion.UsedAs<number>?
	}
)
	local scope = scoped(Fusion, {
		IconPlayer = IconPlayer,
		Text = Text
	})
	table.insert(outerScope, scope)

	local warningIconTheme = makeIconTheme(scope, props.Theme, {
		background = "bg",
		foreground = "accent",
		style = "trio"
	})

	local warningSize = scope:Value(Vector2.zero)
	local textBounds = scope:Value(Vector2.zero)

	local emphasisTransparency = scope:Spring(scope:Value(1.0), 10)
	table.insert(
		scope,
		props.AnimateEvent(function()
			emphasisTransparency:setVelocity(-7.0)
		end)
	)

	return scope:New "Frame" {
		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		LayoutOrder = props.LayoutOrder,

		Size = scope:Spring(scope:Computed(function(use)
			return 
				if use(props.Warning) == nil then 
					UDim2.new(1, 0, 0, 0)
				else
					UDim2.new(1, 0, 0, use(textBounds).Y + 1)
		end), 50),
		BackgroundTransparency = 1,

		[Out "AbsoluteSize"] = warningSize,
	
		[Children] = {
			scope:New "Frame" {
				Name = "Emphasis",
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Size = UDim2.new(1, 4, 1, 4),
				ZIndex = 9999,
				BackgroundColor3 = props.Theme.accentAtopBg,
				BackgroundTransparency = scope:Computed(function(use)
					return math.clamp(use(emphasisTransparency), 0.8, 1)
				end),
				[Children] = scope:New "UICorner" {
					CornerRadius = UDim.new(0, 4)
				}
			},

			scope:New "Frame" {
				Name = "Clip",
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				ClipsDescendants = true,

				[Children] = {
					scope:IconPlayer {
						Theme = warningIconTheme,
						Icon = "triangleExclaim",
						AnimateEvent = props.AnimateEvent,
						Position = UDim2.new(0, 0, 0.5, 0),
						AnchorPoint = Vector2.new(0, 0.5)
					},
					
					scope:Text {
						Theme = props.Theme,
						Position = UDim2.new(0, 20, 0, 0),
						Size = scope:Computed(function(use)
							return UDim2.new(1, -20, 0, use(textBounds).Y)
						end),
						Style = "accent",
						OutSize = textBounds,
						WrapBounds = scope:Computed(function(use)
							return Vector2.new(use(warningSize).X - 20, 99999)
						end),
						Text = scope:Computed(function(use)
							return use(props.Warning) or ""
						end)
					}
				}
			},
		}
	}
end

return Warning