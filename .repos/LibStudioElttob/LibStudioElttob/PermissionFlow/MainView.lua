--!strict
-- (c) Studio Elttob 2024. All rights reserved, seek permission before use.

local Package = script.Parent
local LibStudioElttob = Package.Parent
local LibOpen = LibStudioElttob.Parent.LibOpen

local Event = require(LibOpen.Event)
local Fusion = require(LibOpen.Fusion)
local scoped, peek = Fusion.scoped, Fusion.peek
local Children, Out = Fusion.Children, Fusion.Out
local Permissioned = require(LibOpen.Permissioned)
local ProductDiscovery = require(LibStudioElttob.ProductDiscovery)
local Theme = require(LibStudioElttob.RbxSensation.Theme)
local Panel = require(LibStudioElttob.RbxSensation.Foundation.Panel)
local Text = require(LibStudioElttob.RbxSensation.Foundation.Text)
local Button = require(LibStudioElttob.RbxSensation.Foundation.Button)
local Spacer = require(LibStudioElttob.RbxSensation.Foundation.Spacer)
local Divider = require(LibStudioElttob.RbxSensation.Foundation.Divider)
local Scroller = require(LibStudioElttob.RbxSensation.Foundation.Scroller)
local Expander = require(LibStudioElttob.RbxSensation.Foundation.Expander)
local Bullet = require(LibStudioElttob.RbxSensation.Foundation.Bullet)
local Warning = require(LibStudioElttob.RbxSensation.Compound.Warning)
local SensationSounds = require(LibStudioElttob.SensationSounds)
local IconPlayer = require(LibStudioElttob.RbxVanilla.IconPlayer)
local IconRamp = require(LibStudioElttob.IconRamp)
local PermissionGuide = require(Package.PermissionGuide)

local function MainView(
	outerScope: Fusion.Scope<{}>,
	props: {
		Data: {
			ProductInfo: ProductDiscovery.ProductInfo,
			GrantInfo: Permissioned.GrantInfo,
			Required: Fusion.UsedAs<boolean>,
			RejectedEvent: Event.Connect<>,
			AttemptSkipEvent: Event.Connect<>,

			OnRequestPermission: (() -> ())?,
			OnSkip: (() -> ())?
		}
	}
)
	local scope = scoped(Fusion, {
		Panel = Panel,
		Text = Text,
		Button = Button,
		Spacer = Spacer,
		Divider = Divider,
		Scroller = Scroller,
		Expander = Expander,
		Bullet = Bullet,
		IconPlayer = IconPlayer,
		Warning = Warning,
		PermissionGuide = PermissionGuide
	})
	table.insert(outerScope, scope)

	local windowSize = scope:Value(Vector2.zero)
	local isCompact = scope:Computed(function(use)
		return use(windowSize).X < 250
	end)
	local edgePadding = scope:Computed(function(use)
		return if use(isCompact) then 8 else 12
	end)

	local theme = Theme.context.root(scope, Theme.palette.plugin(scope, props.Data.ProductInfo.accentHue / 360))

	local canvasSize = scope:Value(Vector2.zero)
	local bottomBarInnerSize = scope:Value(Vector2.zero)

	local bottomBarSize = scope:Computed(function(use)
		return Vector2.new(use(bottomBarInnerSize).X, use(bottomBarInnerSize).Y + use(edgePadding))
	end)

	local failSoundRef = scope:Value(nil :: Sound?)

	local permissionsGuideShown = scope:Value(false)

	local numRejections = scope:Value(0)
	local currentWarning = scope:Value(nil :: string?)
	local onFlashWarning, doFlashWarning: () -> () = Event()
	table.insert(
		scope,
		{
			props.Data.RejectedEvent(function()
				numRejections:set(peek(numRejections) + 1)
				currentWarning:set("Permission was denied; please request permission again.")
				doFlashWarning()
				if peek(numRejections) >= 2 then
					permissionsGuideShown:set(true)
				end
			end),
			props.Data.AttemptSkipEvent(function()
				if props.Data.Required then
					currentWarning:set("This permission is required.")
					doFlashWarning()
				end
			end),
			onFlashWarning(function()
				local failSound = peek(failSoundRef)
				if failSound ~= nil then
					failSound:Play()
				end
			end)
		}
	)

	return scope:New "Frame" {
		BackgroundColor3 = theme.bg,
		Size = UDim2.fromScale(1, 1),
		ClipsDescendants = true,

		[Out "AbsoluteSize"] = windowSize,

		[Children] = {
			scope:New "Sound" {
				SoundId = SensationSounds.ask,
				Playing = true
			} :: any,

			failSoundRef:set(
				scope:New "Sound" {
					SoundId = SensationSounds.subtle,
				}
			),

			scope:PermissionGuide {
				Theme = theme,
				IsOpen = permissionsGuideShown,
				Close = function()
					permissionsGuideShown:set(false)
				end
			},
			scope:Scroller {
				Theme = theme,
				Size = scope:Computed(function(use)
					return UDim2.new(1, 0, 1, -use(bottomBarSize).Y)
				end),

				CanvasSize = scope:Computed(function(use)
					return UDim2.fromOffset(0, use(canvasSize).Y)
				end),
				ScrollByY = "continuous",
				ScrollByX = "none",
				TrackPosition = scope:Computed(function(use)
					return if use(isCompact) then "overlay" else "aside"
				end) :: any,

				[Children] = {
					scope:New "UIListLayout" {
						SortOrder = "LayoutOrder",
						FillDirection = "Vertical",
						HorizontalAlignment = "Center",
						VerticalAlignment = "Top",
						[Out "AbsoluteContentSize"] = canvasSize
					} :: any,
					scope:New "UIPadding" {
						PaddingLeft = scope:Computed(function(use)
							return UDim.new(0, use(edgePadding))
						end),
						PaddingRight = scope:Computed(function(use)
							return if use(isCompact) then UDim.new(0, use(edgePadding)) else UDim.new(0, 1)
						end),
					},
					scope:Spacer {
						Spacing = 8,
						Visible = true
					},
					scope:New "ImageLabel" {
						LayoutOrder = 2,
						Size = UDim2.fromOffset(32, 32),
						BackgroundTransparency = 1,

						Image = scope:Computed(function(use)
							local icon = IconRamp.selectNearestSize(props.Data.ProductInfo.robloxIcons, 32)
							if icon == nil then
								return ""
							else
								return icon.variants["mono" :: "mono"]
							end
						end),
						ImageColor3 = theme.accentAtopBg
					},
					scope:Spacer {
						LayoutOrder = 3,
						Spacing = edgePadding,
						Visible = true
					},
					scope:Text {
						LayoutOrder = 4,
						Theme = theme,
						Size = UDim2.fromScale(1, 0),
						AutomaticSize = Enum.AutomaticSize.Y,
						Text = scope:Computed(function(use)
							return
								if use(props.Data.Required) then
									`{props.Data.ProductInfo.displayName} needs to {props.Data.GrantInfo.askTo}.`
								else
									`{props.Data.ProductInfo.displayName} would like to {props.Data.GrantInfo.askTo}.`
						end)
					},
					scope:Spacer {
						LayoutOrder = 5,
						Spacing = 4,
						Visible = true
					},
					scope:Warning {
						LayoutOrder = 6,
						Theme = theme,
						Warning = currentWarning,
						AnimateEvent = onFlashWarning
					},

					if #props.Data.GrantInfo.usedTo == 0 and #props.Data.GrantInfo.notUsedTo == 0 then {} else {
						scope:Spacer {
							LayoutOrder = 10,
							Spacing = 8,
							Visible = true
						} :: any,
						(function()
							local expanded = scope:Value(true)
							local contentSize = scope:Value(Vector2.zero)
							return scope:Expander {
								LayoutOrder = 11,
								Theme = theme,
								Title = "How permission is used",
								Icon = "toggle",
	
								InnerSize = contentSize,
								IsExpanded = expanded,

								OnToggle = function()
									expanded:set(not peek(expanded))
								end,
								
								[Children] = {
									scope:New "UIPadding" {
										PaddingLeft = UDim.new(0, 4),
										PaddingRight = UDim.new(0, 4)
									} :: any,
									scope:New "UIListLayout" {
										SortOrder = "LayoutOrder",
										[Out "AbsoluteContentSize"] = contentSize
									},
									
									if #props.Data.GrantInfo.usedTo == 0 then {} else {
										scope:Text {
											LayoutOrder = 1,
											Theme = theme,
											Text = `{props.Data.ProductInfo.displayName} uses this to:`,
											Size = UDim2.fromScale(1, 0),
											AutomaticSize = Enum.AutomaticSize.Y
										} :: any,

										scope:Spacer {
											LayoutOrder = 2,
											Spacing = 4,
											Visible = true
										},

										scope:New "Frame" {
											LayoutOrder = 3,
											Name = "UsedTo",
											BackgroundTransparency = 1,
											Size = UDim2.fromScale(1, 0),
											AutomaticSize = Enum.AutomaticSize.Y,

											[Children] = {
												scope:New "UIListLayout" {
													SortOrder = "LayoutOrder",
													Padding = UDim.new(0, 4)
												} :: any,

												scope:ForPairs(
													props.Data.GrantInfo.usedTo,
													function(
														use: Fusion.Use,
														scope: typeof(scope),
														index: number,
														text: string
													): (number, Fusion.Child)
														local textSize = scope:Value(Vector2.zero)
														local wrapBounds = scope:Value(Vector2.zero)
														return index, scope:Bullet {
															LayoutOrder = index,
															Size = UDim2.fromScale(1, 0),
															AutomaticSize = Enum.AutomaticSize.Y,
															Theme = theme,
															[Children] = {
																scope:New "Frame" {
																	Name = "WidthMeasure",
																	Size = UDim2.fromScale(1, 0),
																	[Out "AbsoluteSize"] = wrapBounds
																},
																scope:Text {
																	Theme = theme,
																	Text = text,
																	Size = scope:Computed(function(use)
																		return UDim2.new(0, use(wrapBounds).X, 0, use(textSize).Y)
																	end),
																	WrapBounds = wrapBounds,
																	OutSize = textSize
																}
															}
														}
													end
												)
											}
										},
										scope:Spacer {
											LayoutOrder = 4,
											Spacing = 8,
											Visible = true
										}
									},

									if #props.Data.GrantInfo.notUsedTo == 0 then {} else {
										scope:Text {
											LayoutOrder = 4,
											Theme = theme,
											Text = `{props.Data.ProductInfo.displayName} does <b>not</b> use this to:`,
											RichText = true,
											Size = UDim2.fromScale(1, 0),
											AutomaticSize = Enum.AutomaticSize.Y
										} :: any,

										scope:Spacer {
											LayoutOrder = 5,
											Spacing = 4,
											Visible = true
										},

										scope:New "Frame" {
											LayoutOrder = 6,
											Name = "NotUsedTo",
											BackgroundTransparency = 1,
											Size = UDim2.fromScale(1, 0),
											AutomaticSize = Enum.AutomaticSize.Y,

											[Children] = {
												scope:New "UIListLayout" {
													SortOrder = "LayoutOrder",
													Padding = UDim.new(0, 4)
												} :: any,

												scope:ForPairs(
													props.Data.GrantInfo.notUsedTo,
													function(
														use: Fusion.Use,
														scope: typeof(scope),
														index: number,
														text: string
													): (number, Fusion.Child)
														local textSize = scope:Value(Vector2.zero)
														local wrapBounds = scope:Value(Vector2.zero)
														return index, scope:Bullet {
															LayoutOrder = index,
															Size = UDim2.fromScale(1, 0),
															AutomaticSize = Enum.AutomaticSize.Y,
															Theme = theme,
															[Children] = {
																scope:New "Frame" {
																	Name = "WidthMeasure",
																	Size = UDim2.fromScale(1, 0),
																	[Out "AbsoluteSize"] = wrapBounds
																},
																scope:Text {
																	Theme = theme,
																	Text = text,
																	Size = scope:Computed(function(use)
																		return UDim2.new(0, use(wrapBounds).X, 0, use(textSize).Y)
																	end),
																	WrapBounds = wrapBounds,
																	OutSize = textSize
																}
															}
														}
													end
												)
											}
										},

										scope:Spacer {
											LayoutOrder = 7,
											Spacing = 8,
											Visible = true
										}
									}
								}
							}
						end)()
					},

					if #props.Data.GrantInfo.grantingWill == 0 and #props.Data.GrantInfo.grantingWont == 0 then {} else {
						scope:Spacer {
							LayoutOrder = 20,
							Spacing = 8,
							Visible = true
						} :: any,
						(function()
							local expanded = scope:Value(false)
							local contentSize = scope:Value(Vector2.zero)
							return scope:Expander {
								LayoutOrder = 21,
								Theme = theme,
								Title = "Technical information",
								Icon = "cog",
	
								InnerSize = contentSize,
								IsExpanded = expanded,

								OnToggle = function()
									expanded:set(not peek(expanded))
								end,
								
								[Children] = {
									scope:New "UIPadding" {
										PaddingLeft = UDim.new(0, 4),
										PaddingRight = UDim.new(0, 4)
									} :: any,
									scope:New "UIListLayout" {
										SortOrder = "LayoutOrder",
										[Out "AbsoluteContentSize"] = contentSize
									},
									
									if #props.Data.GrantInfo.grantingWill == 0 then {} else {
										scope:Text {
											LayoutOrder = 1,
											Theme = theme,
											Text = `Once granted, {props.Data.ProductInfo.displayName} will:`,
											Size = UDim2.fromScale(1, 0),
											AutomaticSize = Enum.AutomaticSize.Y
										} :: any,

										scope:Spacer {
											LayoutOrder = 2,
											Spacing = 4,
											Visible = true
										},

										scope:New "Frame" {
											LayoutOrder = 3,
											Name = "GrantingWill",
											BackgroundTransparency = 1,
											Size = UDim2.fromScale(1, 0),
											AutomaticSize = Enum.AutomaticSize.Y,

											[Children] = {
												scope:New "UIListLayout" {
													SortOrder = "LayoutOrder",
													Padding = UDim.new(0, 4)
												} :: any,

												scope:ForPairs(
													props.Data.GrantInfo.grantingWill,
													function(
														use: Fusion.Use,
														scope: typeof(scope),
														index: number,
														text: string
													): (number, Fusion.Child)
														local textSize = scope:Value(Vector2.zero)
														local wrapBounds = scope:Value(Vector2.zero)
														return index, scope:Bullet {
															LayoutOrder = index,
															Size = UDim2.fromScale(1, 0),
															AutomaticSize = Enum.AutomaticSize.Y,
															Theme = theme,
															[Children] = {
																scope:New "Frame" {
																	Name = "WidthMeasure",
																	Size = UDim2.fromScale(1, 0),
																	[Out "AbsoluteSize"] = wrapBounds
																},
																scope:Text {
																	Theme = theme,
																	Text = text,
																	Size = scope:Computed(function(use)
																		return UDim2.new(0, use(wrapBounds).X, 0, use(textSize).Y)
																	end),
																	WrapBounds = wrapBounds,
																	OutSize = textSize
																}
															}
														}
													end
												)
											}
										},
										scope:Spacer {
											LayoutOrder = 4,
											Spacing = 8,
											Visible = true
										}
									},

									if #props.Data.GrantInfo.grantingWont == 0 then {} else {
										scope:Text {
											LayoutOrder = 4,
											Theme = theme,
											Text = `{props.Data.ProductInfo.displayName} will <b>not</b>:`,
											RichText = true,
											Size = UDim2.fromScale(1, 0),
											AutomaticSize = Enum.AutomaticSize.Y
										} :: any,

										scope:Spacer {
											LayoutOrder = 5,
											Spacing = 4,
											Visible = true
										},

										scope:New "Frame" {
											LayoutOrder = 6,
											Name = "NotUsedTo",
											BackgroundTransparency = 1,
											Size = UDim2.fromScale(1, 0),
											AutomaticSize = Enum.AutomaticSize.Y,

											[Children] = {
												scope:New "UIListLayout" {
													SortOrder = "LayoutOrder",
													Padding = UDim.new(0, 4)
												} :: any,

												scope:ForPairs(
													props.Data.GrantInfo.grantingWont,
													function(
														use: Fusion.Use,
														scope: typeof(scope),
														index: number,
														text: string
													): (number, Fusion.Child)
														local textSize = scope:Value(Vector2.zero)
														local wrapBounds = scope:Value(Vector2.zero)
														return index, scope:Bullet {
															LayoutOrder = index,
															Size = UDim2.fromScale(1, 0),
															AutomaticSize = Enum.AutomaticSize.Y,
															Theme = theme,
															[Children] = {
																scope:New "Frame" {
																	Name = "WidthMeasure",
																	Size = UDim2.fromScale(1, 0),
																	[Out "AbsoluteSize"] = wrapBounds
																},
																scope:Text {
																	Theme = theme,
																	Text = text,
																	Size = scope:Computed(function(use)
																		return UDim2.new(0, use(wrapBounds).X, 0, use(textSize).Y)
																	end),
																	WrapBounds = wrapBounds,
																	OutSize = textSize
																}
															}
														}
													end
												)
											}
										},

										scope:Spacer {
											LayoutOrder = 7,
											Spacing = 8,
											Visible = true
										}
									}
								}
							}
						end)()
					},

					if #props.Data.GrantInfo.disclaimers == 0 then {} else {
						scope:Spacer {
							LayoutOrder = 30,
							Spacing = 8,
							Visible = true
						} :: any,
						(function()
							local expanded = scope:Value(false)
							local contentSize = scope:Value(Vector2.zero)
							return scope:Expander {
								LayoutOrder = 31,
								Theme = theme,
								Title = "Disclaimers",
								Icon = "circleISerif",
	
								InnerSize = contentSize,
								IsExpanded = expanded,

								OnToggle = function()
									expanded:set(not peek(expanded))
								end,
								
								[Children] = {
									scope:New "UIPadding" {
										PaddingLeft = UDim.new(0, 4),
										PaddingRight = UDim.new(0, 4)
									} :: any,
									scope:New "UIListLayout" {
										SortOrder = "LayoutOrder",
										[Out "AbsoluteContentSize"] = contentSize
									},
									
									scope:ForPairs(
										props.Data.GrantInfo.disclaimers,
										function(
											use: Fusion.Use,
											scope: typeof(scope),
											index: number,
											text: string
										): (number, Fusion.Child)
											local textSize = scope:Value(Vector2.zero)
											local wrapBounds = scope:Value(Vector2.zero)
											return index, scope:Bullet {
												LayoutOrder = index,
												Size = UDim2.fromScale(1, 0),
												AutomaticSize = Enum.AutomaticSize.Y,
												Theme = theme,
												[Children] = {
													scope:New "Frame" {
														Name = "WidthMeasure",
														Size = UDim2.fromScale(1, 0),
														[Out "AbsoluteSize"] = wrapBounds
													},
													scope:Text {
														Theme = theme,
														Text = text,
														Size = scope:Computed(function(use)
															return UDim2.new(0, use(wrapBounds).X, 0, use(textSize).Y)
														end),
														WrapBounds = wrapBounds,
														OutSize = textSize
													}
												}
											}
										end
									),

									scope:Spacer {
										LayoutOrder = 9999,
										Spacing = 8,
										Visible = true
									}
								}
							}
						end)()
					},

					scope:Spacer {
						LayoutOrder = 9999,
						Spacing = scope:Computed(function(use)
							return use(edgePadding) - 4
						end),
						Visible = true
					},
				}
			} :: any,

			scope:New "Frame" {
				Name = "BottomBar",
				Position = UDim2.new(0, 0, 1, 0),
				Size = scope:Computed(function(use)
					return UDim2.new(1, 0, 0, use(bottomBarSize).Y)
				end),
				AnchorPoint = Vector2.new(0, 1),
				BackgroundTransparency = 1,

				[Children] = {
					scope:New "UIListLayout" {
						SortOrder = "LayoutOrder",
						FillDirection = "Horizontal",
						HorizontalAlignment = "Right",
						[Out "AbsoluteContentSize"] = bottomBarInnerSize
					} :: any,

					scope:New "UIPadding" {
						PaddingLeft = scope:Computed(function(use)
							return UDim.new(0, use(edgePadding))
						end),
						PaddingRight = scope:Computed(function(use)
							return UDim.new(0, use(edgePadding))
						end)
					},

					scope:Button {
						LayoutOrder = 3,
						Theme = theme,

						Size = scope:Computed(function(use)
							return 
								if use(props.Data.Required) then
									UDim2.new(1, 0, 0, 24)
								else
									UDim2.new(0.67, -2, 0, 24)
						end),
						Text = "Request permission",
						Illuminated = true,

						Activated = props.Data.OnRequestPermission
					},

					scope:Spacer {
						LayoutOrder = 2,
						Spacing = 4,
						Visible = scope:Computed(function(use)
							return not use(props.Data.Required)
						end)
					},
					
					scope:Button {
						LayoutOrder = 1,
						Theme = theme,
		
						Size = UDim2.new(0.33, -2, 0, 24),
						Text = "Skip",
						Illuminated = false,
						Visible = scope:Computed(function(use)
							return not use(props.Data.Required)
						end),

						Activated = props.Data.OnSkip
					}
				}
			}

			
		}
	}
end

return MainView