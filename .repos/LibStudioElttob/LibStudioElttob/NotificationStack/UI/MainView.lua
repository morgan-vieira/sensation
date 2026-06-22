--!strict
--!nolint LocalShadow
-- (c) Studio Elttob 2024. All rights reserved, seek permission before use.

local Package = script.Parent.Parent
local LibStudioElttob = Package.Parent
local LibOpen = LibStudioElttob.Parent.LibOpen

local Fusion = require(LibOpen.Fusion)
local peek = Fusion.peek
local Children, Out = Fusion.Children, Fusion.Out
local Theme = require(LibStudioElttob.RbxSensation.Theme)
local Panel = require(LibStudioElttob.RbxSensation.Foundation.Panel)
local Text = require(LibStudioElttob.RbxSensation.Foundation.Text)
local Button = require(LibStudioElttob.RbxSensation.Foundation.Button)
local Spacer = require(LibStudioElttob.RbxSensation.Foundation.Spacer)
local SensationSounds = require(LibStudioElttob.SensationSounds)
local IconRamp = require(LibStudioElttob.IconRamp)
local Types = require(Package.Types)

local MAX_LAYOUT_ORDER = 2147483647

local function ClearAllButton(
	scope: Fusion.Scope<typeof(Fusion)>,
	props: {
		Theme: Theme.ThemeContext,
		Show: Fusion.UsedAs<boolean>,
		ClearAllNotifications: () -> ()
	}
)
	local scope = scope:innerScope {
		Panel = Panel,
		Text = Text,
		Button = Button,
		Spacer = Spacer
	}

	local animShow = scope:Spring(scope:Computed(function(use)
		return if use(props.Show) then 1 else 0
	end), 25)
	local animPushUp = scope:Spring(scope:Computed(function(use)
		return math.clamp(use(animShow) * 3, 0, 1)
	end), 50)
	local animPanelSlide = scope:Spring(scope:Computed(function(use)
		return math.clamp(use(animShow) * 3 - 2, 0, 1)
	end), 50)

	local layoutSize = scope:Value(Vector2.zero)
	local panelSize = scope:Computed(function(use)
		local padded = use(layoutSize) + Vector2.new(8, 8)
		if padded.Y < 28 then
			padded = Vector2.new(padded.X, 28)
		end
		return padded
	end)

	return scope:New "Frame" {
		Name = "ClearAll",
		Size = scope:Computed(function(use)
			return UDim2.new(1, 0, 0, (use(panelSize).Y + 4) * use(animPushUp))
		end),
		BackgroundTransparency = 1,
		LayoutOrder = MAX_LAYOUT_ORDER,

		[Children] = {
			scope:Panel {
				Theme = props.Theme,

				Position = scope:Computed(function(use)
					return UDim2.new(1, -4 + 32 * (1 - use(animPanelSlide)), 1, -4)
				end),
				AnchorPoint = Vector2.new(1, 1),
				Size = scope:Computed(function(use)
					return UDim2.fromOffset(use(panelSize).X, use(panelSize).Y)
				end),

				Transparency = scope:Computed(function(use)
					return 1 - use(animPanelSlide)
				end),

				[Children] = {
					scope:New "UIListLayout" {
						SortOrder = "LayoutOrder",
						FillDirection = "Horizontal",
						VerticalAlignment = "Center",
						HorizontalAlignment = "Center",

						[Out "AbsoluteContentSize"] = layoutSize
					} :: any,

					scope:Button {
						Theme = props.Theme,
						Text = "Clear all notifications",
						Icon = "xSmall",

						Activated = function()
							props.ClearAllNotifications()
						end
					},
				}
			}
		}
	}
end

local function MainView(
	scope: Fusion.Scope<typeof(Fusion)>,
	props: {
		Data: {
			ActiveNotifications: Fusion.UsedAs<{[string]: Types.Notification}>,
			PopNotification: (string) -> (),
			InvokeAction: (string, string) -> (),
		}
	}
)
	local scope = scope:innerScope {
		Panel = Panel,
		Text = Text,
		Button = Button,
		Spacer = Spacer,
		ClearAllButton = ClearAllButton
	}

	local defaultTheme = Theme.context.root(
		scope, 
		Theme.palette.plugin(
			scope,
			255 / 360
		)
	)

	local canvasSize = scope:Value(Vector2.zero)

	-- We need integer LayoutOrder values for arranging notifications. To keep
	-- the numbers small, measure a minimum time that can be subtracted later.
	local epoch = os.clock()
	for _, notification in peek(props.Data.ActiveNotifications) do
		epoch = math.min(epoch, notification.creationTime)
	end

	local lastSoundPlayTime = 0

	local notificationUIs = scope:ForPairs(
		props.Data.ActiveNotifications, 
		function(
			use: Fusion.Use, 
			shorterScope: typeof(scope), 
			notificationId: string, 
			notification: Types.Notification
		)
			local scope = shorterScope:deriveScope()
			local show = scope:Value(false)
			table.insert(shorterScope, function()
				show:set(false)
			end)

			local animShow = scope:Spring(scope:Computed(function(use)
				return if use(show) then 1 else 0
			end), 25)
			local animPushUp = scope:Spring(scope:Computed(function(use)
				return math.clamp(use(animShow) * 3, 0, 1)
			end), 50)
			local animPanelSlide = scope:Spring(scope:Computed(function(use)
				return math.clamp(use(animShow) * 3 - 2, 0, 1)
			end), 50)

			scope:Observer(animShow):onChange(function()
				if not peek(show) and peek(animPushUp) < 0.01 and peek(animPanelSlide) < 0.01 then
					scope:doCleanup()
				end
			end)
			show:set(true)

			local layoutSize = scope:Value(Vector2.zero)
			local panelSize = scope:Computed(function(use)
				local padded = use(layoutSize) + Vector2.new(8, 8)
				if padded.Y < 28 then
					padded = Vector2.new(padded.X, 28)
				end
				return padded
			end)
			local theme = Theme.context.root(
				scope, 
				Theme.palette.plugin(
					scope,
					(notification.spec.accentHue or 255) / 360
				)
			)

			local playSound = os.clock() - lastSoundPlayTime > 0.5
			if playSound then
				lastSoundPlayTime = os.clock()
			end

			return notificationId, scope:New "Frame" {
				Size = scope:Computed(function(use)
					return UDim2.new(1, 0, 0, (use(panelSize).Y + 4) * use(animPushUp))
				end),
				BackgroundTransparency = 1,
				LayoutOrder = (notification.creationTime - epoch) * 100,

				[Children] = {
					scope:New "Sound" {
						SoundId = SensationSounds[notification.spec.soundStyle] or SensationSounds.subtle,
						Playing = playSound
					} :: any,
					
					scope:Panel {
						Theme = theme,

						Position = scope:Computed(function(use)
							return UDim2.new(1, -4 + 32 * (1 - use(animPanelSlide)), 1, -4)
						end),
						AnchorPoint = Vector2.new(1, 1),
						Size = scope:Computed(function(use)
							return UDim2.fromOffset(use(panelSize).X, use(panelSize).Y)
						end),

						Transparency = scope:Computed(function(use)
							return 1 - use(animPanelSlide)
						end),

						[Children] = {
							scope:New "UIListLayout" {
								SortOrder = "LayoutOrder",
								FillDirection = "Horizontal",
								VerticalAlignment = "Center",
								HorizontalAlignment = "Center",

								[Out "AbsoluteContentSize"] = layoutSize
							} :: any,

							scope:Spacer {
								LayoutOrder = 0,
								Spacing = 4,
								Visible = true
							},

							if notification.spec.iconRamp == nil then {} else {
								scope:New "ImageLabel" {
									LayoutOrder = 1,
									Size = UDim2.fromOffset(16, 16),
									BackgroundTransparency = 1,

									Image = scope:Computed(function(use)
										local icon = IconRamp.selectNearestSize(use(notification.spec.iconRamp), 16)
										return if icon == nil then "" else icon.variants["mono" :: "mono"]
									end),
									ImageColor3 = 
										if notification.spec.accentHue == nil then 
											theme.greyAtopBg 
										else 
											theme.accentAtopBg
								},

								scope:Spacer {
									LayoutOrder = 2,
									Spacing = 4,
									Visible = true
								},
							},
								
							scope:Text {
								LayoutOrder = 3,
								Theme = theme,
								AutomaticSize = Enum.AutomaticSize.XY,
								Text = notification.spec.text,
								Align = {X = "start", Y = "mid"}
							},

							scope:Spacer {
								LayoutOrder = 4,
								Spacing = 4,
								Visible = true
							},

							scope:ForPairs(
								notification.spec.actionButtons,
								function(
									use: Fusion.Use,
									scope: typeof(scope),
									index: number,
									button: Types.ActionButtonSpec
								)
									return index, {
										scope:Button {
											LayoutOrder = 5 + (index - 1) * 2,
											Theme = theme,
											Text = button.text,
											Illuminated = button.illuminated,

											Activated = function()
												props.Data.InvokeAction(notification.id, button.id)
											end
										} :: any,
										scope:Spacer {
											LayoutOrder = 6 + (index - 1) * 2,
											Spacing = 4,
											Visible = true
										},
									}
								end
							),

							scope:Button {
								LayoutOrder = 9999,
								Theme = theme,
								Icon = "xSmall",
								Flat = true,

								Activated = function()
									props.Data.PopNotification(notification.id)
								end
							},
						}
					}
				}
			}
		end
	)

	local notificationStack = scope:New "Frame" {
		Name = "NotificationStack",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,

		[Out "AbsoluteSize"] = canvasSize,

		[Children] = {
			scope:New "UIListLayout" {
				SortOrder = "LayoutOrder",
				HorizontalAlignment = "Right",
				VerticalAlignment = "Bottom"
			} :: any,

			scope:ClearAllButton {
				Theme = defaultTheme,
				Show = scope:Computed(function(use)
					local count = 0
					for _ in pairs(use(props.Data.ActiveNotifications)) do
						count += 1
						if count >= 3 then
							return true
						end
					end
					return false
				end),
				ClearAllNotifications = function()
					for id in peek(props.Data.ActiveNotifications) do
						props.Data.PopNotification(id)
					end
				end
			},

			notificationUIs
		}
	}

	return notificationStack
end

return MainView