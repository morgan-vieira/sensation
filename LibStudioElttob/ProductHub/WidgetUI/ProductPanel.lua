--!strict
--!nolint LocalShadow
-- (c) Studio Elttob 2024. All rights reserved, seek permission before use.

local plugin = script:FindFirstAncestorWhichIsA("Plugin") :: Plugin

local Package = script.Parent.Parent
local LibStudioElttob = Package.Parent
local LibOpen = LibStudioElttob.Parent.LibOpen

local Fusion = require(LibOpen.Fusion)
local scoped, peek = Fusion.scoped, Fusion.peek
local Children, Out = Fusion.Children, Fusion.Out
local Theme = require(LibStudioElttob.RbxSensation.Theme)
local Text = require(LibStudioElttob.RbxSensation.Foundation.Text)
local Button = require(LibStudioElttob.RbxSensation.Foundation.Button)
local Panel = require(LibStudioElttob.RbxSensation.Foundation.Panel)
local ProductDiscovery = require(LibStudioElttob.ProductDiscovery)
local IconRamp = require(LibStudioElttob.IconRamp)

local function ProductPanel(
	outerScope: Fusion.Scope<{}>,
	props: {
		LayoutOrder: Fusion.UsedAs<number>?,
		ProductInfo: ProductDiscovery.ProductInfo,
		ActivatedData: Fusion.UsedAs<{
			LatestInfo: Fusion.UsedAs<ProductDiscovery.ProductInfo?>,
			Launch: () -> (),
			ShowUpdateInfo: () -> ()
		}?>
	}
): Fusion.Child
	local scope = scoped(Fusion, {
		Text = Text,
		Panel = Panel,
		Button = Button
	})
	table.insert(outerScope, scope)

	local productTheme = Theme.context.root(scope, Theme.palette.plugin(scope, props.ProductInfo.accentHue / 360))
	local panelTheme = Theme.context.withZOffset(scope, productTheme, 1)

	local outOfDate = scope:Computed(function(use)
		local activatedData = use(props.ActivatedData)
		if activatedData == nil then
			return false
		end
		local latestInfo = use(activatedData.LatestInfo) :: ProductDiscovery.ProductInfo?
		if latestInfo == nil then
			return false
		end
		local currentVersion = props.ProductInfo.version
		local latestVersion = latestInfo.version
		return latestVersion ~= nil and (
			latestVersion.major > currentVersion.major
			or latestVersion.minor > currentVersion.minor
			or latestVersion.patch > currentVersion.patch
		)
	end)

	local wholePanelSize = scope:Value(Vector2.zero)
	local mainContentSize = scope:Value(Vector2.zero)
	local buttonPanelSize = scope:Value(Vector2.zero)
	local panelLayout = scope:Computed(function(use)
		return 
			if use(props.ActivatedData) == nil then 
				"nameOnly" 
			elseif use(wholePanelSize).X - use(buttonPanelSize).X < use(mainContentSize).X + 8 then
				"actionsNarrow"
			else
				"actionsWide"
	end)

	return scope:Panel {
		LayoutOrder = props.LayoutOrder,
		Theme = panelTheme,
		Size = scope:Computed(function(use)
			local panelLayout = use(panelLayout)
			if panelLayout == "nameOnly" then
				return UDim2.new(1, 0, 0, 32)
			elseif panelLayout == "actionsWide" then
				return UDim2.new(1, 0, 0, 40)
			elseif panelLayout == "actionsNarrow" then
				return UDim2.new(1, 0, 0, 40 + 28)
			else
				error("Invalid panel layout")
			end
		end),

		OutSize = wholePanelSize,

		[Children] = {
			scope:New "Frame" {
				Name = "MainContent",
				Size = scope:Computed(function(use)
					return 
						if use(panelLayout) == "actionsNarrow" then
							UDim2.new(0, 0, 1, -28)
						else
							UDim2.new(0, 0, 1, 0)
				end),
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundTransparency = 1,

				[Out "AbsoluteSize"] = mainContentSize,

				[Children] = {
					scope:New "Frame" {
						Size = UDim2.new(0, 32, 1, 0),
						BackgroundTransparency = 1,
		
						[Children] = {
							scope:New "ImageLabel" {
								Position = UDim2.fromScale(0.5, 0.5),
								AnchorPoint = Vector2.new(0.5, 0.5),
								Size = UDim2.fromOffset(16, 16),
								BackgroundTransparency = 1,
				
								Image = scope:Computed(function(use)
									local icon = IconRamp.selectNearestSize(use(props.ProductInfo.robloxIcons), 16)
									return if icon == nil then "" else icon.variants["mono" :: "mono"]
								end),
								ImageColor3 = panelTheme.accentAtopBg
							},
						}
					} :: any,
		
					scope:Text {
						Theme = panelTheme,
		
						Position = scope:Computed(function(use)
							local panelLayout = use(panelLayout)
							if panelLayout == "nameOnly" then
								return UDim2.fromOffset(32, 8)
							else
								return UDim2.fromOffset(32, 4)
							end
						end),
						Size = UDim2.new(0, 0, 0, 8),
						AutomaticSize = Enum.AutomaticSize.X,
		
						Text = props.ProductInfo.displayName
					},

					scope:Computed(function(use, scope: typeof(scope))
						local activatedData = use(props.ActivatedData)
						if activatedData == nil then
							return {}
						else
							return {
								scope:Text {
									Theme = panelTheme,
					
									Position = UDim2.fromOffset(32, 20),
									Size = UDim2.new(0, 0, 0, 8),
									AutomaticSize = Enum.AutomaticSize.X,
									Visible = scope:Computed(function(use)
										return use(panelLayout) ~= "nameOnly" 
									end),
					
									Style = "grey",
									Text = scope:Computed(function(use)
										local currentVersion = props.ProductInfo.version
										local currentVersionString = `{currentVersion.major}.{currentVersion.minor}.{currentVersion.patch}`
										local latestInfo = use(activatedData.LatestInfo)
										if latestInfo == nil then
											return `{currentVersionString} (offline only)`
										elseif use(outOfDate) then
											local latestVersion = use(latestInfo.version) :: ProductDiscovery.ProductVersion
											local latestVersionString = `{latestVersion.major}.{latestVersion.minor}.{latestVersion.patch}`
											return `Needs update: {currentVersionString} → {latestVersionString}`
										else
											return currentVersionString
										end
									end)
								}
							}
						end
					end)
				}
			},

			scope:New "Frame" {
				Name = "ButtonPanelWide",
				Position = UDim2.new(1, -8, 0, 4),
				AnchorPoint = Vector2.new(1, 0),
				Size = scope:Computed(function(use)
					return UDim2.new(0, use(buttonPanelSize).X, 1, -8)
				end),
				BackgroundTransparency = 1,

				Visible = scope:Computed(function(use)
					return use(panelLayout) == "actionsWide"
				end),

				[Children] = {
					scope:New "UIListLayout" {
						SortOrder = "LayoutOrder",
						FillDirection = "Horizontal",
						Padding = UDim.new(0, 4),
						VerticalAlignment = Enum.VerticalAlignment.Center,
						[Out "AbsoluteContentSize"] = buttonPanelSize
					} :: any,

					scope:Button {
						LayoutOrder = 2,
						Theme = panelTheme,
						Text = "Launch",
						Illuminated = true,

						Activated = function()
							local activatedData = peek(props.ActivatedData)
							if activatedData ~= nil then
								return activatedData.Launch()
							end
						end
					},

					scope:Button {
						LayoutOrder = 1,
						Theme = panelTheme,
						Text = "Release notes",
						Visible = outOfDate,

						Activated = function()
							local activatedData = peek(props.ActivatedData)
							if activatedData ~= nil then
								return activatedData.ShowUpdateInfo()
							end
						end
					}
				}
			},

			scope:New "Frame" {
				Name = "ButtonPanelNarrow",
				Position = UDim2.new(0, 4, 1, -4),
				AnchorPoint = Vector2.new(0, 1),
				Size = UDim2.new(1, -8, 0, 24),
				BackgroundTransparency = 1,

				Visible = scope:Computed(function(use)
					return use(panelLayout) == "actionsNarrow"
				end),

				[Children] = {
					scope:New "UIListLayout" {
						SortOrder = "LayoutOrder",
						FillDirection = "Horizontal",
						Padding = UDim.new(0, 4),
						HorizontalAlignment = Enum.HorizontalAlignment.Right,
						VerticalAlignment = Enum.VerticalAlignment.Top
					} :: any,

					scope:Button {
						LayoutOrder = 2,
						Theme = panelTheme,
						Text = "Launch",
						Illuminated = true,

						Activated = function()
							local activatedData = peek(props.ActivatedData)
							if activatedData ~= nil then
								return activatedData.Launch()
							end
						end
					},

					scope:Button {
						LayoutOrder = 1,
						Theme = panelTheme,
						Text = "Release notes",
						Visible = outOfDate,

						Activated = function()
							local activatedData = peek(props.ActivatedData)
							if activatedData ~= nil then
								return activatedData.ShowUpdateInfo()
							end
						end
					}
				}
			}
		}
	}
end

return ProductPanel