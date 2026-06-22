--!strict
-- (c) Studio Elttob 2024. All rights reserved, seek permission before use.

local Package = script.Parent.Parent
local LibStudioElttob = Package.Parent
local LibOpen = LibStudioElttob.Parent.LibOpen

local Fusion = require(LibOpen.Fusion)
local scoped, peek = Fusion.scoped, Fusion.peek
local Children, OnEvent = Fusion.Children, Fusion.OnEvent
local Theme = require(LibStudioElttob.RbxSensation.Theme)
local Text = require(LibStudioElttob.RbxSensation.Foundation.Text)
local Panel = require(LibStudioElttob.RbxSensation.Foundation.Panel)
local Button = require(LibStudioElttob.RbxSensation.Foundation.Button)
local Divider = require(LibStudioElttob.RbxSensation.Foundation.Divider)

export type OptionInfo<Option> = {
	Option: Option,
	Title: string,
	Icon: string
}

local function Modal<State>(
	outerScope: Fusion.Scope<{}>,
	props: {
		Theme: Theme.ThemeContext,
		State: Fusion.StateObject<State>,
		Icon: Fusion.UsedAs<string>?,
		Title: Fusion.UsedAs<string>,

		RequestClose: () -> (),

		OutRetainedState: Fusion.Value<State>?,

		[typeof(Children)]: Fusion.Child
	}
)
	local scope = scoped(Fusion, {
		Text = Text,
		Panel = Panel,
		Button = Button,
		Divider = Divider,
	})
	table.insert(outerScope, scope)

	local retainedState = scope:Value(peek(props.State))
	scope:Observer(props.State):onChange(function()
		local newState = peek(props.State)
		if newState ~= nil then
			retainedState:set(newState)
		end
	end)
	if props.OutRetainedState ~= nil then
		scope:Observer(retainedState):onBind(function()
			props.OutRetainedState:set(peek(retainedState))
		end)
	end

	local animShow = scope:Spring(scope:Computed(function(use)
		return if not use(props.State) then 0 else 1
	end), 25)
	local panelIsVisible = scope:Computed(function(use)
		return use(animShow) > 0.01
	end)
	scope:Observer(panelIsVisible):onChange(function()
		if not peek(panelIsVisible) then
			retainedState:set(if typeof(peek(retainedState)) == "boolean" then false else nil :: any)
		end
	end)

	local theme = props.Theme

	return scope:New "TextButton" {
		Name = "Modal",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = scope:Computed(function(use)
			return 1 - use(animShow) * 0.5
		end),
		Visible = panelIsVisible,
		ZIndex = 9999,

		[OnEvent "Activated"] = function()
			props.RequestClose()
		end,

		[Children] = scope:Panel {
			Theme = theme,

			Position = scope:Computed(function(use)
				return UDim2.new(0, 0, 0, 24 + (1 - use(animShow)) * 64)
			end),
			Size = UDim2.new(1, 0, 1, 0),
			Transparency = scope:Computed(function(use)
				return 1 - use(animShow)
			end),

			[Children] = scope:New "TextButton" {
				Name = "InteractionBlocker",
				Size = UDim2.new(1, 0, 1, -32),
				BackgroundTransparency = 1,

				[Children] = {
					scope:New "Frame" {
						Name = "Header",
						Position = UDim2.fromOffset(0, 8),
						Size = UDim2.new(1, 0, 0, 16),
						BackgroundTransparency = 1,

						[Children] = {
							scope:New "UIListLayout" {
								SortOrder = "LayoutOrder",
								FillDirection = "Horizontal",
								VerticalAlignment = "Center",
								Padding = UDim.new(0, 8)
							},

							scope:New "UIPadding" {
								PaddingLeft = UDim.new(0, 4),
								PaddingRight = UDim.new(0, 4)
							},

							scope:Button {
								LayoutOrder = 1,
								Theme = theme,
								Text = "Back",
								Icon = "arrowLeftSmall",
		
								Position = UDim2.new(0, 4, 0.5, 0),
								AnchorPoint = Vector2.new(0, 0.5),

								Activated = function()
									props.RequestClose()
								end
							} :: any,

							scope:Divider {
								LayoutOrder = 2,
								Theme = theme,
								Direction = "vertical"
							},
		
							if props.Icon == nil then {} :: any else scope:New "ImageLabel" {
								LayoutOrder = 3,
								Name = "Icon",
								Size = UDim2.fromOffset(16, 16),
								BackgroundTransparency = 1,
		
								Image = props.Icon,
								ImageColor3 = theme.fgAtopBg
							},

							scope:Text {
								LayoutOrder = 4,
								Theme = theme,
								Size = UDim2.new(0, 0, 0, 8),
								AutomaticSize = Enum.AutomaticSize.X,
								Align = {
									Y = "mid"
								},
								Text = props.Title
							},
						}
					},

					scope:New "Frame" {
						Name = "ContentArea",
						Position = UDim2.fromOffset(0, 28),
						Size = UDim2.new(1, 0, 1, -28),
						BackgroundTransparency = 1,

						[Children] = props[Children]
					}
				}
			}
		}
	}
end

return Modal