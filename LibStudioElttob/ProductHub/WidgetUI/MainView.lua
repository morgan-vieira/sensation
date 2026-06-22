--!strict
-- (c) Studio Elttob 2024. All rights reserved, seek permission before use.

local Package = script.Parent.Parent
local LibStudioElttob = Package.Parent
local LibOpen = LibStudioElttob.Parent.LibOpen

local Fusion = require(LibOpen.Fusion)
local scoped, peek = Fusion.scoped, Fusion.peek
local Children, Out = Fusion.Children, Fusion.Out
local Maybe = require(LibOpen.Maybe)
local Permissioned = require(LibOpen.Permissioned)
local ProductDiscovery = require(LibStudioElttob.ProductDiscovery)
local Theme = require(LibStudioElttob.RbxSensation.Theme)
local Text = require(LibStudioElttob.RbxSensation.Foundation.Text)
local Spacer = require(LibStudioElttob.RbxSensation.Foundation.Spacer)
local Scroller = require(LibStudioElttob.RbxSensation.Foundation.Scroller)
local Types = require(Package.Types)
local ProductPanel = require(Package.WidgetUI.ProductPanel)
local ChangelogOverlay = require(Package.WidgetUI.ChangelogOverlay)

local function MainView(
	outerScope: Fusion.Scope<{}>,
	props: {
		Widget: {
			BindToClose: (maybeCallback: (() -> ())?) -> ()
		},
		Data: {
			IsOpen: Fusion.StateObject<boolean>,
			EnabledProducts: Fusion.UsedAs<{[string]: Types.ProductInfoPack}>,
			DisabledProducts: Fusion.UsedAs<{[string]: Types.ProductInfoPack}>,
			NumUpdatesAvailable: Fusion.UsedAs<number>,
			Launch: (productId: string) -> (),
			FetchChangelogText: (
				productId: string,
				version: ProductDiscovery.ProductVersion
			) -> Permissioned.Permissioned<Maybe.Maybe<string>>
		}
	}
)
	local scope = scoped(Fusion, {
		Text = Text,
		Spacer = Spacer,
		Scroller = Scroller,
		ProductPanel = ProductPanel,
		ChangelogOverlay = ChangelogOverlay
	})
	table.insert(outerScope, scope)

	local theme = Theme.context.root(scope, Theme.palette.plugin(scope, 255 / 360))

	local scrollCanvasSize = scope:Value(Vector2.zero)
	local currentChangelog = scope:Value(nil :: ChangelogOverlay.CurrentChangelog?)
	local fetchChangelogTask = nil :: thread?
	table.insert(
		scope, 
		function()
			if fetchChangelogTask ~= nil then
				task.cancel(fetchChangelogTask)
				fetchChangelogTask = nil
			end
		end
	)

	-- It's good UX to close the modal when the user exits
	scope:Observer(props.Data.IsOpen):onChange(function()
		if not peek(props.Data.IsOpen) then
			currentChangelog:set(nil)
		end
	end)

	local function showChangelog(
		productId: string,
		productInfo: ProductDiscovery.ProductInfo
	): ()
		if fetchChangelogTask ~= nil then
			task.cancel(fetchChangelogTask)
		end
		local changelogText = scope:Value("pending" :: ChangelogOverlay.ChangelogTextResult)
		currentChangelog:set({
			productId = productId,
			productInfo = productInfo,
			changelogText = changelogText :: any
		} :: ChangelogOverlay.CurrentChangelog?)
		fetchChangelogTask = task.spawn(function()
			changelogText:set(props.Data.FetchChangelogText(productId, productInfo.version))
		end)
	end

	return scope:New "Frame" {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = theme.bg,

		[Children] = {
			scope:ChangelogOverlay {
				Theme = theme,
				CurrentChangelog = currentChangelog,

				CloseChangelog = function()
					currentChangelog:set(nil)
				end
			},
			scope:Scroller {
				Theme = theme,
				CanvasSize = scope:Computed(function(use)
					return UDim2.fromOffset(0, use(scrollCanvasSize).Y + 16)
				end),
				ScrollByY = "continuous",
				ScrollByX = "none",
				TrackPosition = "overlay",

				Size = UDim2.fromScale(1, 1),

				[Children] = {
					scope:New "UIListLayout" {
						SortOrder = "LayoutOrder",
						Padding = UDim.new(0, 8),
						[Out "AbsoluteContentSize"] = scrollCanvasSize
					} :: any,
					scope:New "UIPadding" {
						PaddingTop = UDim.new(0, 8),
						PaddingBottom = UDim.new(0, 8),
						PaddingLeft = UDim.new(0, 8),
						PaddingRight = UDim.new(0, 8)
					},
		
					scope:New "Frame" {
						LayoutOrder = 1,
						Name = "ActivatedProducts",
						BackgroundTransparency = 1,
						Size = UDim2.fromScale(1, 0),
						AutomaticSize = "Y",

						Visible = scope:Computed(function(use)
							return next(use(props.Data.EnabledProducts)) ~= nil
						end),
		
						[Children] = {
							scope:New "UIListLayout" {
								SortOrder = "LayoutOrder",
							} :: any,
							
							scope:Text {
								LayoutOrder = 1,
								Theme = theme,
								Text = "Your activated Suite products",
								Size = UDim2.fromScale(1, 0),
								AutomaticSize = Enum.AutomaticSize.Y
							},
				
							scope:Text {
								LayoutOrder = 2,
								Theme = theme,
								Style = "grey",
								Size = UDim2.fromScale(1, 0),
								AutomaticSize = Enum.AutomaticSize.Y,
								Text = scope:Computed(function(use)
									local numUpdatesAvailable = use(props.Data.NumUpdatesAvailable)
									if numUpdatesAvailable == 0 then
										return "Everything's up to date!"
									else
										local plural = numUpdatesAvailable > 1
										return 
											numUpdatesAvailable
											.. " " .. (if plural then "products need" else "product needs")
											.. " to be updated"
									end
								end)
							},
		
							scope:ForPairs(
								props.Data.EnabledProducts, 
								function(
									use: Fusion.Use, 
									scope: typeof(scope),
									productId: string,
									productInfoPack: Types.ProductInfoPack
								)
									local offlineInfo = use(productInfoPack.Offline) :: ProductDiscovery.ProductInfo
									if offlineInfo == nil then
										return productId, {}
									end
									return productId, {
										scope:Spacer {
											LayoutOrder = 3 + offlineInfo.accentHue*2,
											Spacing = 8,
											Visible = true
										} :: any,
										scope:ProductPanel {
											LayoutOrder = 3 + offlineInfo.accentHue*2 + 1,
											ProductInfo = offlineInfo,
											ActivatedData = {
												LatestInfo = productInfoPack.Latest,
												Launch = function()
													props.Data.Launch(productId)
												end,
												ShowUpdateInfo = function()
													local latestInfo = peek(productInfoPack.Latest)
													if latestInfo == nil then
														return
													end
													showChangelog(productId, latestInfo)
												end,
											}
										}
									}
								end
							)
						}
					},
		
					scope:New "Frame" {
						LayoutOrder = 2,
						Name = "NotActivatedProducts",
						BackgroundTransparency = 1,
						Size = UDim2.fromScale(1, 0),
						AutomaticSize = "Y",

						Visible = scope:Computed(function(use)
							return next(use(props.Data.DisabledProducts)) ~= nil
						end),
		
						[Children] = {
							scope:New "UIListLayout" {
								SortOrder = "LayoutOrder",
							} :: any,

							scope:Text {
								LayoutOrder = 1,
								Theme = theme,
								Text = "Not yet activated",
								Size = UDim2.fromScale(1, 0),
								AutomaticSize = Enum.AutomaticSize.Y
							} :: any,

							scope:ForPairs(
								props.Data.DisabledProducts, 
								function(
									use: Fusion.Use, 
									scope: typeof(scope),
									productId: string,
									productInfoPack: Types.ProductInfoPack
								)
									local latestInfo = use(productInfoPack.Latest) :: ProductDiscovery.ProductInfo?
									if latestInfo == nil then
										return productId, {}
									end
									return productId, {
										scope:Spacer {
											LayoutOrder = 2 + latestInfo.accentHue*2,
											Spacing = 8,
											Visible = true
										} :: any,
										scope:ProductPanel {
											LayoutOrder = 2 + latestInfo.accentHue*2 + 1,
											ProductInfo = latestInfo
										}
									}
								end
							)
						}
					},
		
					scope:Text {
						LayoutOrder = 3,
						Theme = theme,
						Style = "grey",
						Size = UDim2.fromScale(1, 0),
						AutomaticSize = Enum.AutomaticSize.Y,
						Text = 
							"Note: To continue receiving updates and changelogs, you’ll need to keep each product enabled for"
							.. " Product Hub to track them."
					}
				}
			}
		}
	}
end

return MainView