--!strict
--!nolint LocalShadow
-- (c) Studio Elttob 2024. All rights reserved, seek permission before use.

local TextService = game:GetService("TextService")

local Package = script.Parent.Parent
local LibStudioElttob = Package.Parent
local LibOpen = LibStudioElttob.Parent.LibOpen

local Event = require(LibOpen.Event)
local Fusion = require(LibOpen.Fusion)
local peek = Fusion.peek
local Children = Fusion.Children
local IconPlayer = require(LibStudioElttob.RbxVanilla.IconPlayer)
local Bevel = require(Package.FX.Bevel)
local Text = require(Package.Foundation.Text)
local GestureSurface = require(Package.Input.GestureSurface)
local Theme = require(Package.Theme)
local makeIconTheme = require(Package.Theme.makeIconTheme)

local function Button<S>(
	scope: Fusion.Scope<S & typeof(Fusion)>,
	props: {
		Theme: Theme.ThemeContext,
	
		Name: Fusion.UsedAs<string>?,
		Position: Fusion.UsedAs<UDim2>?,
		AnchorPoint: Fusion.UsedAs<Vector2>?,
		Size: Fusion.UsedAs<UDim2>?,
		LayoutOrder: Fusion.UsedAs<number>?,
		ZIndex: Fusion.UsedAs<number>?,
		Visible: Fusion.UsedAs<boolean>?,
	
		Illuminated: Fusion.UsedAs<boolean>?,
		Flat: Fusion.UsedAs<boolean>?,
		Subtle: Fusion.UsedAs<boolean>?,
		Interruptible: Fusion.UsedAs<boolean>?,
		Text: Fusion.UsedAs<string?>,
		Align: Fusion.UsedAs<"left" | "centre">?,

		OutSize: Fusion.Value<Vector2>?,
		
		Icon: Fusion.UsedAs<string?>,
		RenderIcon: (
			(
				Fusion.Scope<S>,
				theme: Theme.ThemeContext,
				onAnimate: Event.Connect<()>
			) -> Fusion.Child
		)?,
	
		Activated: (() -> ())?
	}
): Fusion.Child
	local scope = scope:innerScope {
		Bevel = Bevel,
		GestureSurface = GestureSurface,
		Text = Text,
		IconPlayer = IconPlayer
	}

	local themeParent = props.Theme

	local isHovering = scope:Value(false)
	local isSubtle = scope:Computed(function(use)
		return use(props.Subtle) and not use(isHovering)
	end)

	local height = scope:Spring(scope:Computed(function(use)
		return if use(props.Flat) or use(isSubtle) then 0 else 1
	end), 50)
	local themeButton = Theme.context.withZOffset(scope, themeParent, height)
	local iconTheme = makeIconTheme(scope, themeButton, {
		background = scope:Computed(function(use)
			return if use(props.Illuminated) then "accentAtopBg" else "bg"
		end) :: any,
		foreground = scope:Computed(function(use)
			return if use(isSubtle) then "grey" else "fg"
		end) :: any,
		style = "trio"
	})

	local outerSize = scope:Computed(function(use)
		local text = use(props.Text) or ""
		local hasIcon = props.RenderIcon ~= nil or use(props.Icon) ~= nil
		local itemTotalWidths = 0
		local itemCount = 0
		if #text > 0 then
			local textBounds = TextService:GetTextSize(use(props.Text), 14, Enum.Font.SourceSans, Vector2.one * 9999)
			itemTotalWidths += 2 + textBounds.X + 2
			itemCount += 1
		end
		if hasIcon then
			itemTotalWidths += 16
			itemCount += 1
		end
		return Vector2.new(itemTotalWidths + 4 * math.max(2, itemCount + 1), 24)
	end)

	if props.OutSize ~= nil then
		scope:Observer(outerSize):onBind(function()
			props.OutSize:set(peek(outerSize))
		end)
	end
	
	local onAnimate, doAnimate: () -> () = Event()

	if typeof(props.Illuminated) == "table" then
		scope:Observer(props.Illuminated):onChange(function()
			if peek(props.Illuminated) then
				doAnimate()
			end
		end)
	end

	return scope:New "Frame" {
		Name = props.Name or "Button",

		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		LayoutOrder = props.LayoutOrder,
		ZIndex = props.ZIndex,
		Visible = props.Visible,

		BackgroundColor3 = iconTheme.background,
		Size = props.Size or scope:Computed(function(use)
			local outerSize = use(outerSize)
			return UDim2.fromOffset(outerSize.X, outerSize.Y)
		end),

		[Children] = {
			scope:New "UICorner" {
				CornerRadius = UDim.new(0, 4)
			},

			scope:Bevel {
				CornerRadius = UDim.new(0, 4),
				Height = height
			},
			scope:GestureSurface {
				Color = scope:Computed(function(use)
					return 
						if use(props.Illuminated) then 
							use(themeButton.pureAtopAccentAtopBg)
						else
							use(themeButton.pureAtopBg)
				end),
				CornerRadius = UDim.new(0, 4),
				Activated = function()
					doAnimate()
					if props.Activated ~= nil then
						props.Activated()
					end
				end,
				OnHover = function(
					scope: typeof(scope)
				)
					isHovering:set(true)
					table.insert(
						scope,
						function()
							isHovering:set(false)
						end
					)
				end
			},

			scope:New "Frame" {
				Name = "Contents",
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,

				[Children] = {
					scope:New "UIPadding" {
						PaddingLeft = UDim.new(0, 4),
						PaddingRight = UDim.new(0, 4)
					} :: any,
					scope:New "UIListLayout" {
						FillDirection = "Horizontal",
						VerticalAlignment = "Center",
						HorizontalAlignment = scope:Computed(function(use)
							local align = use(props.Align or "centre")
							return 
								if align == "left" then Enum.HorizontalAlignment.Left
								else Enum.HorizontalAlignment.Center
						end),
						SortOrder = "LayoutOrder",
						Padding = UDim.new(0, 4)
					},

					scope:Computed(function(use, scope: typeof(scope)): Fusion.Child
						if props.RenderIcon ~= nil then
							return scope:New "Frame" {
								Name = "IconArea",
								LayoutOrder = 1,
								Size = UDim2.fromOffset(16, 16),
								BackgroundTransparency = 1,

								[Children] = props.RenderIcon(scope, themeButton, onAnimate)
							}
						elseif use(props.Icon) ~= nil then
							return scope:IconPlayer {
								LayoutOrder = 1,
								Icon = use(props.Icon),
								Interruptible = props.Interruptible,
								Theme = iconTheme,
								AnimateEvent = onAnimate
							}
						else
							return {}
						end
					end),

					scope:Computed(function(use, scope: typeof(scope))
						local text = use(props.Text) or ""
						return if #text > 0 then {
							scope:Text {
								LayoutOrder = 2,
								Theme = themeButton,
								Text = text,

								Style = scope:Computed(function(use)
									return 
										if use(props.Illuminated) then "atopAccent"
										elseif use(isSubtle) then "grey"
										else "normal"
								end) :: any
							}
						} else {}
					end)
				}
			}
		}
	}
end

return Button