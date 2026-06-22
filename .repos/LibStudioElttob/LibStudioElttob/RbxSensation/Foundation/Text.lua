--!strict
-- (c) Studio Elttob 2024. All rights reserved, seek permission before use.

local Package = script.Parent.Parent
local LibStudioElttob = Package.Parent
local LibOpen = LibStudioElttob.Parent.LibOpen

local Fusion = require(LibOpen.Fusion)
local peek = Fusion.peek
local Children, Out = Fusion.Children, Fusion.Out
local Theme = require(Package.Theme)

export type Style = "normal" | "grey" | "heading" | "accent" | "atopAccent"

local function Text(
	scope: Fusion.Scope<typeof(Fusion)>,
	props: {
		Theme: Theme.ThemeContext,
	
		Position: Fusion.UsedAs<UDim2>?,
		AnchorPoint: Fusion.UsedAs<Vector2>?,
		Size: Fusion.UsedAs<UDim2>?,
		AutomaticSize: Fusion.UsedAs<Enum.AutomaticSize>?,
		LayoutOrder: Fusion.UsedAs<number>?,
		ZIndex: Fusion.UsedAs<number>?,
		Visible: Fusion.UsedAs<boolean>?,

		WrapBounds: Fusion.UsedAs<Vector2?>,
		OutSize: Fusion.Value<Vector2>?,
	
		Text: Fusion.UsedAs<string>,
		Style: Fusion.UsedAs<Style>?,
		RichText: Fusion.UsedAs<boolean>?,
		Align: {
			X: Fusion.UsedAs<"start" | "mid" | "end">?,
			Y: Fusion.UsedAs<"start" | "mid" | "end">?
		}?
	}
)
	if props.Size == nil then
		props.AutomaticSize = Enum.AutomaticSize.XY
	end

	local alignX = scope:Computed(function(use)
		local align = use(props.Align)
		if align ~= nil then
			local alignX = use(align.X)
			if alignX ~= nil then
				return alignX
			end
		end
		return "start"
	end)

	local alignY = scope:Computed(function(use)
		local align = use(props.Align)
		if align ~= nil then
			local alignY = use(align.Y)
			if alignY ~= nil then
				return alignY
			end
		end
		return "start"
	end)

	local textSize = scope:Computed(function(use)
		return if use(props.Style) == "heading" then 14 * 1.5 else 14
	end)

	local shouldWrap = scope:Computed(function(use)
		return use(props.WrapBounds) ~= nil or use(props.AutomaticSize) == Enum.AutomaticSize.Y
	end)

	if props.OutSize ~= nil then
		assert(props.WrapBounds ~= nil, "WrapBounds needed to measure text size accurately")
		local measuredTextSize = scope:Value(Vector2.zero)
		scope:New "TextLabel" {
			Name = "MeasurementLabel",
			Parent = scope:New "ScreenGui" {
				Name = "TextMeasurement",
				Parent = game:GetService("CoreGui")
			},

			AnchorPoint = Vector2.new(1, 1),
			Size = scope:Computed(function(use)
				local wrapBounds = use(props.WrapBounds) :: Vector2?
				return
					if wrapBounds == nil then
						UDim2.fromOffset(999999, 999999)
					else
						UDim2.fromOffset(wrapBounds.X - 2 - 2, 999999)
			end),
			BackgroundTransparency = 1,

			[Out "TextBounds"] = measuredTextSize,

			Text = props.Text,
			TextTransparency = 1,
			TextSize = textSize,
			TextWrapped = shouldWrap,
			RichText = props.RichText
		}
		scope:Observer(measuredTextSize):onBind(function()
			props.OutSize:set(peek(measuredTextSize))
		end)
	end

	return scope:New "TextLabel" {
		Name = props.Text,

		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		Size = scope:Computed(function(use)
			local userSize = use(props.Size) or UDim2.fromOffset(0, 0)
			if props.OutSize ~= nil then
				local wrapSize = use(props.OutSize) or Vector2.zero
				return UDim2.new(userSize.X, UDim.new(0, wrapSize.Y))
			else
				return userSize
			end
		end),
		AutomaticSize = props.AutomaticSize,
		LayoutOrder = props.LayoutOrder,
		ZIndex = props.ZIndex,
		Visible = props.Visible,

		BackgroundTransparency = 1,

		Text = props.Text,
		TextColor3 = scope:Computed(function(use)
			return if use(props.Style) == "accent" then 
				use(props.Theme.accentAtopBg)
			elseif use(props.Style) == "atopAccent" then 
				use(props.Theme.fgAtopAccentAtopBg) 
			elseif use(props.Style) == "grey" then 
				use(props.Theme.greyAtopBg) 
			else 
				use(props.Theme.fgAtopBg)
		end),
		TextSize = textSize,
		TextWrapped = shouldWrap,
		RichText = props.RichText,

		TextXAlignment = scope:Computed(function(use)
			local align = use(alignX)
			return
				if align == "start" then Enum.TextXAlignment.Left
				elseif align == "mid" then Enum.TextXAlignment.Center
				elseif align == "end" then Enum.TextXAlignment.Right
				else error(`Invalid text X alignment: {align}`)
		end),
		TextYAlignment = scope:Computed(function(use)
			local align = use(alignY)
			return
				if align == "start" then Enum.TextYAlignment.Top
				elseif align == "mid" then Enum.TextYAlignment.Center
				elseif align == "end" then Enum.TextYAlignment.Bottom
				else error(`Invalid text Y alignment: {align}`)
		end),

		[Children] = scope:New "UIPadding" {
			PaddingLeft = UDim.new(0, 2),
			PaddingRight = UDim.new(0, 2)
		}
	}
end

return Text