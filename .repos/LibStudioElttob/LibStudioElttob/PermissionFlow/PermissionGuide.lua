--!strict
--!nolint LocalShadow
-- (c) Studio Elttob 2024. All rights reserved, seek permission before use.

local Package = script.Parent
local LibStudioElttob = Package.Parent
local LibOpen = LibStudioElttob.Parent.LibOpen

local Fusion = require(LibOpen.Fusion)
local scoped, peek = Fusion.scoped, Fusion.peek
local Children, OnEvent, Out = Fusion.Children, Fusion.OnEvent, Fusion.Out
local Theme = require(LibStudioElttob.RbxSensation.Theme)
local Panel = require(LibStudioElttob.RbxSensation.Foundation.Panel)
local Text = require(LibStudioElttob.RbxSensation.Foundation.Text)
local Button = require(LibStudioElttob.RbxSensation.Foundation.Button)
local Scroller = require(LibStudioElttob.RbxSensation.Foundation.Scroller)
local makeIconTheme = require(LibStudioElttob.RbxSensation.Theme.makeIconTheme)
local Expander = require(LibStudioElttob.RbxSensation.Foundation.Expander)
local Spacer = require(LibStudioElttob.RbxSensation.Foundation.Spacer)
local IconPlayer = require(LibStudioElttob.RbxVanilla.IconPlayer)

local function PermissionGuide(
	outerScope: Fusion.Scope<{}>,
	props: {
		Theme: Theme.ThemeContext,
		IsOpen: Fusion.StateObject<boolean>,
		Close: () -> ()
	}
): Fusion.Child
	local scope = scoped(Fusion, {
		Panel = Panel,
		Text = Text,
		Button = Button,
		IconPlayer = IconPlayer,
		Scroller = Scroller,
		Expander = Expander,
		Spacer = Spacer
	})
	table.insert(outerScope, scope)

	local animShown = scope:Spring(scope:Computed(function(use)
		return if use(props.IsOpen) then 1 else 0
	end), 25)
	local panelIsVisible = scope:Computed(function(use)
		return use(animShown) > 0.01
	end)

	local theme = props.Theme
	local iconTheme = makeIconTheme(scope, theme, {
		background = "bg",
		foreground = "accent",
		style = "mono"
	})

	local windowSize = scope:Value(Vector2.zero)
	local contentSize = scope:Value(Vector2.zero)

	local topInset = scope:Spring(scope:Computed(function(use)
		return math.max(32, use(windowSize).Y - use(contentSize).Y - 40)
	end), 25)
	
	return scope:New "TextButton" {
		Name = "PermissionGuide",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = scope:Computed(function(use)
			return 1 - use(animShown) * 0.5
		end),
		Visible = panelIsVisible,
		ZIndex = 9999,

		[Out "AbsoluteSize"] = windowSize,

		[OnEvent "Activated"] = function()
			props.Close()
		end,

		[Children] = scope:Panel {
			Theme = theme,

			Position = scope:Computed(function(use)
				return UDim2.new(0, 0, 0, use(topInset) + (1 - use(animShown)) * 64)
			end),
			Size = UDim2.new(1, 0, 1, 0),
			Transparency = scope:Computed(function(use)
				return 1 - use(animShown)
			end),

			[Children] = scope:New "TextButton" {
				Name = "InteractionBlocker",
				Size = scope:Computed(function(use)
					return UDim2.new(1, 0, 1, -use(topInset))
				end),
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
								PaddingLeft = UDim.new(0, 8),
								PaddingRight = UDim.new(0, 8)
							},
		
							scope:IconPlayer {
								LayoutOrder = 1,
								Theme = iconTheme,
								Size = UDim2.fromOffset(16, 16),
								BackgroundTransparency = 1,
		
								Icon = "triangleExclaim"
							},

							scope:Text {
								LayoutOrder = 2,
								Theme = theme,
								Size = UDim2.new(0, 0, 0, 8),
								AutomaticSize = Enum.AutomaticSize.X,
								Align = {
									Y = "mid"
								},
								Text = "Roblox might be misconfigured",
								Style = "accent"
							},
						}
					},

					scope:New "Frame" {
						Name = "ContentArea",
						Position = UDim2.fromOffset(0, 28),
						Size = UDim2.new(1, 0, 1, -28),
						BackgroundTransparency = 1,

						[Children] = scope:Scroller {
							Theme = theme,
							CanvasSize = scope:Computed(function(use)
								return UDim2.fromOffset(0, use(contentSize).Y + 4)
							end),
							ScrollByY = "continuous",
							ScrollByX = "none",
							TrackPosition = "aside",
							Size = UDim2.fromScale(1, 1),

							[Children] = {
								scope:New "UIListLayout" {
									SortOrder = "LayoutOrder",
									Padding = UDim.new(0, 8),
									[Out "AbsoluteContentSize"] = contentSize
								} :: any,

								scope:New "UIPadding" {
									PaddingLeft = UDim.new(0, 8),
									PaddingRight = UDim.new(0, 1),
								},

								scope:Text {
									LayoutOrder = 1,
									Theme = theme,
									Size = UDim2.fromScale(1, 0),
									AutomaticSize = Enum.AutomaticSize.Y,
									Text = "It looks like Roblox is preventing these permission requests. Before you can continue, you'll have to configure Roblox to allow these permission requests."
								},
								
								(function()
									local expanded = scope:Value(false)
									local contentSize = scope:Value(Vector2.zero)
									return scope:Expander {
										LayoutOrder = 3,
										Theme = theme,

										Title = "How to allow permissions",
										Icon = "circleISerif",
										IsExpanded = expanded,
										InnerSize = contentSize,
										OnToggle = function()
											expanded:set(not peek(expanded))
										end,

										[Children] = {
											scope:New "UIListLayout" {
												SortOrder = "LayoutOrder",
												Padding = UDim.new(0, 8),
												[Out "AbsoluteContentSize"] = contentSize
											} :: any,

											scope:New "UIPadding" {
												PaddingLeft = UDim.new(0, 4),
												PaddingRight = UDim.new(0, 4),
											},

											scope:New "ImageLabel" {
												LayoutOrder = 1,
												Size = scope:Computed(function(use)
													local contentSize = use(contentSize)
													return UDim2.fromOffset(contentSize.X, contentSize.X / 504 * 141)
												end),
												AutomaticSize = Enum.AutomaticSize.Y,

												Image = ""
											},

											scope:Text {
												LayoutOrder = 2,
												Theme = theme,
												Size = UDim2.fromScale(1, 0),
												AutomaticSize = Enum.AutomaticSize.Y,
												Text = "Navigate to the 'Plugins' tab, and click on the 'Manage Plugins' button."
											},

											scope:New "ImageLabel" {
												LayoutOrder = 3,
												Size = scope:Computed(function(use)
													local contentSize = use(contentSize)
													return UDim2.fromOffset(contentSize.X, contentSize.X / 405 * 62)
												end),
												AutomaticSize = Enum.AutomaticSize.Y,

												Image = ""
											},
			
											scope:Text {
												LayoutOrder = 4,
												Theme = theme,
												Size = UDim2.fromScale(1, 0),
												AutomaticSize = Enum.AutomaticSize.Y,
												RichText = true,
												Text = "See if there are any Studio Elttob products with <b>denied permissions</b>. For example, you might see an 'x' symbol for 'HTTP Requests', or 'Script Injection Denied', or similar."
											},
			
											scope:Text {
												LayoutOrder = 6,
												Theme = theme,
												Size = UDim2.fromScale(1, 0),
												AutomaticSize = Enum.AutomaticSize.Y,
												Text = "Click there to go to the plugin permissions page."
											},

											scope:New "ImageLabel" {
												LayoutOrder = 7,
												Size = scope:Computed(function(use)
													local contentSize = use(contentSize)
													return UDim2.fromOffset(contentSize.X, contentSize.X / 421 * 248)
												end),
												AutomaticSize = Enum.AutomaticSize.Y,

												Image = ""
											},
			
											scope:Text {
												LayoutOrder = 8,
												Theme = theme,
												Size = UDim2.fromScale(1, 0),
												AutomaticSize = Enum.AutomaticSize.Y,
												Text = "Enable any options on the page that were previously disabled."
											},

											scope:Spacer {
												LayoutOrder = 9999,
												Spacing = 0,
												Visible = true
											}
										}
									}
								end)(),

								scope:Button {
									LayoutOrder = 7,
									Theme = theme,
									Size = UDim2.new(1, 0, 0, 24),
									Text = "Dismiss tips",
									Activated = props.Close
								},
							}
						}
					}
				}
			}
		}
	}
end

return PermissionGuide