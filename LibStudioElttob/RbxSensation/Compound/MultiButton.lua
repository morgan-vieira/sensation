--!strict
-- (c) Studio Elttob 2024. All rights reserved, seek permission before use.

local Package = script.Parent.Parent
local LibStudioElttob = Package.Parent
local LibOpen = LibStudioElttob.Parent.LibOpen

local Fusion = require(LibOpen.Fusion)
local scoped = Fusion.scoped
local Children = Fusion.Children
local Theme = require(LibStudioElttob.RbxSensation.Theme)
local Button = require(LibStudioElttob.RbxSensation.Foundation.Button)

export type OptionInfo<Option> = {
	Option: Option,
	Title: string,
	Icon: string
}

local function MultiButton<Option>(
	outerScope: Fusion.Scope<{}>,
	props: {
		Theme: Theme.ThemeContext,
	
		Position: Fusion.UsedAs<UDim2>?,
		AnchorPoint: Fusion.UsedAs<Vector2>?,
		LayoutOrder: Fusion.UsedAs<number>?,
	
		CurrentOption: Fusion.UsedAs<Option>,
		OptionPicked: (Option) -> (),
		Options: {OptionInfo<Option>}
	}
)
	local scope = scoped(Fusion, {
		Button = Button
	})
	table.insert(outerScope, scope)

	return scope:New "Frame" {
		Name = "MultiButton",

		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		LayoutOrder = props.LayoutOrder,

		Size = UDim2.fromOffset(0, 24),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
	
		[Children] = {
			scope:New "UIListLayout" {
				FillDirection = "Horizontal",
				HorizontalAlignment = "Right",
				SortOrder = "LayoutOrder",
				Padding = UDim.new(0, 4)
			} :: any,

			scope:ForPairs(props.Options, function(
				use: Fusion.Use, 
				scope: typeof(scope), 
				layoutOrder: number, 
				optionInfo: OptionInfo<Option>
			): (number, Fusion.Child)
				local isSelected = scope:Computed(function(use)
					return use(props.CurrentOption) == optionInfo.Option
				end)
				
				return layoutOrder, scope:Button {
					Theme = props.Theme,

					Name = "Button",
					LayoutOrder = layoutOrder,

					Illuminated = isSelected,
					Icon = optionInfo.Icon,
					Text = optionInfo.Title,

					Activated = function()
						props.OptionPicked(optionInfo.Option)
					end
				}
			end)
		}
	}
end

return MultiButton