--!strict
--!nolint LocalShadow
-- (c) Studio Elttob 2024. All rights reserved, seek permission before use.

local Package = script
local LibStudioElttob = Package.Parent
local LibOpen = LibStudioElttob.Parent.LibOpen

local Event = require(LibOpen.Event)
local Fusion = require(LibOpen.Fusion)
local scoped, doCleanup, peek = Fusion.scoped, Fusion.doCleanup, Fusion.peek
local Maybe = require(LibOpen.Maybe)
local Permissioned = require(LibOpen.Permissioned)
local Log = require(LibStudioElttob.Log)
local Interposer = require(LibStudioElttob.Interposer)
local Leader = require(LibStudioElttob.Leader)
local ProductDiscovery = require(LibStudioElttob.ProductDiscovery)
local SharedToolbar = require(LibStudioElttob.SharedToolbar)
local SharedWidget = require(LibStudioElttob.SharedWidget)
local IconRamp = require(LibStudioElttob.IconRamp)
local NotificationStack = require(LibStudioElttob.NotificationStack)
local Types = require(Package.Types)
local Icons = require(Package.Icons)
local MainView = require(Package.WidgetUI.MainView)

type Scope = {unknown}

local ProductHub = {}

local HUB_WIDGET_ID = "SuiteProductHub"
local SHARED_TOOLBAR_ID = "ElttobSuite"

local TOOLBAR_TITLE = "Elttob Suite"

local logger = Log.create("ProductHub", false)

local function needsUpdate(
	use: Fusion.Use,
	productInfoPack: Types.ProductInfoPack
): boolean
	local offline = use(productInfoPack.Offline) :: ProductDiscovery.ProductInfo?
	local latest = use(productInfoPack.Latest) :: ProductDiscovery.ProductInfo?
	if offline == nil or latest == nil then
		return false
	end
	return
		latest.version.major > offline.version.major
		or latest.version.minor > offline.version.minor
		or latest.version.patch > offline.version.patch
end

function ProductHub.init(
	scope: Fusion.Scope<typeof(Fusion)>,
	interposer: Interposer.InterposerApi,
	leader: Leader.LeaderApi,
	productDiscovery: ProductDiscovery.ProductDiscoveryApi,
	notificationStack: NotificationStack.NotificationStackApi,
	runtimeOptions: {
		clickableWhenViewportHidden: boolean
	}
): Types.ProductHubApi
	local productHubIsOpen = scope:Value(false)

	local productInfoPacks = scope:Value({} :: {[string]: Types.ProductInfoPack})
	do
		local packs = peek(productInfoPacks)
		if productDiscovery.onlineProductInfos.some then
			for productId, latestInfo in productDiscovery.onlineProductInfos.value do
				local maybeOffline = productDiscovery.getOfflineProductInfo(productId)
				local scope = scoped(Fusion)
				local thisPack: Types.ProductInfoPack = {
					Scope = scope,
					Offline = scope:Value(if maybeOffline.some then maybeOffline.value else nil),
					Latest = scope:Value(latestInfo :: ProductDiscovery.ProductInfo?),
				}
				packs[productId] = thisPack
			end
		end
		for _, productId in productDiscovery.peerProductIds do
			if packs[productId] ~= nil then
				continue
			end
			local maybeOffline = productDiscovery.getOfflineProductInfo(productId)
			local scope = scoped(Fusion)
			local thisPack: Types.ProductInfoPack = {
				Scope = scope,
				Offline = scope:Value(if maybeOffline.some then maybeOffline.value else nil),
				Latest = scope:Value(nil :: ProductDiscovery.ProductInfo?),
			}
			packs[productId] = thisPack
		end
		productInfoPacks:set(packs)
	end
	productDiscovery.onProductDiscovered(
		function(_, productId)
			local packs = peek(productInfoPacks)
			local maybeOffline = productDiscovery.getOfflineProductInfo(productId)
			local maybeLatest = productDiscovery.getLatestProductInfo(productId)
			local thisPack = packs[productId]
			if thisPack == nil then
				local scope = scoped(Fusion)
				packs[productId] = {
					Scope = scope,
					Offline = scope:Value(if maybeOffline.some then maybeOffline.value else nil),
					Latest = scope:Value(if maybeLatest.some then maybeLatest.value else nil),
				}
				productInfoPacks:set(packs)
			else
				thisPack.Offline:set(if maybeOffline.some then maybeOffline.value else nil)
				thisPack.Latest:set(if maybeLatest.some then maybeLatest.value else nil)
			end
		end
	)
	productDiscovery.onProductForgotten(
		function(_, productId)
			local packs = peek(productInfoPacks)
			packs[productId] = nil
			productInfoPacks:set(packs)
		end
	)
	table.insert(scope, function()
		for _, pack in peek(productInfoPacks) do
			doCleanup(pack.Scope)
		end
	end)

	local enabledProducts = scope:Computed(function(use)
		local enabled = {}
		for productId, productInfoPack: Types.ProductInfoPack in use(productInfoPacks) do
			if use(productInfoPack.Offline) ~= nil then
				enabled[productId] = productInfoPack
			end
		end
		return enabled
	end)
	local disabledProducts = scope:Computed(function(use)
		local disabled = {}
		for productId, productInfoPack: Types.ProductInfoPack in use(productInfoPacks) do
			if use(productInfoPack.Offline) == nil and use(productInfoPack.Latest) ~= nil then
				disabled[productId] = productInfoPack
			end
		end
		return disabled
	end)
	local numUpdatesAvailable = scope:Computed(function(use)
		local count = 0
		for productId, productInfoPack: Types.ProductInfoPack in use(productInfoPacks) do
			if needsUpdate(use, productInfoPack) then
				count += 1
			end
		end
		return count
	end)

	scope:Observer(enabledProducts):onBind(function()
		local awareOf = {}
		for _, product in peek(enabledProducts) do
			table.insert(awareOf, (peek(product.Latest) or peek(product.Offline) or {displayName = "(unknown)"}).displayName)
		end
		logger.info(`[{interposer.selfPeer}] I am {productDiscovery.selfOfflineProductInfo.displayName}, I am{if leader.selfIsLeader() == true then "" elseif leader.selfIsLeader() == nil then " maybe" else " not" } the leader, and I am aware of {table.concat(awareOf, " and ")}`)
	end)

	local productHubIconRamp = scope:Computed(function(use)
		return if use(numUpdatesAvailable) > 0 then
			Icons.productHubNotifyRamp
		else
			Icons.productHubRamp
	end)

	local onInvokeProduct, doInvokeProduct: () -> () = Event()
	local selfProductInfo = productDiscovery.selfOfflineProductInfo
	local sharedToolbar = SharedToolbar.connect(
		scope,
		interposer,
		leader,
		SHARED_TOOLBAR_ID,
		TOOLBAR_TITLE,
		productDiscovery.selfProductId,
		{
			openProductHub = {
				creationOrder = -100,
				displayName = "Product Hub",
				toolTip = "Manage your Elttob Suite products.",
				iconRamp = peek(productHubIconRamp),
				clickableWhenViewportHidden = true
			}
		},
		{
			invokeProduct = {
				creationOrder = selfProductInfo.accentHue,
				displayName = selfProductInfo.displayName,
				toolTip = selfProductInfo.tagline,
				iconRamp = selfProductInfo.robloxIcons,
				clickableWhenViewportHidden = runtimeOptions.clickableWhenViewportHidden
			}
		}
	)

	local hubWidget = SharedWidget.connect(
		scope,
		interposer,
		leader,
		HUB_WIDGET_ID,
		{
			title = "Elttob Suite Product Hub",
			info = DockWidgetPluginGuiInfo.new(
				Enum.InitialDockState.Float,
				false,
				true,
				400,
				300,
				224,
				200
			),
			zIndexBehaviour = Enum.ZIndexBehavior.Sibling,
			mainView = MainView
		},
		{
			IsOpen = productHubIsOpen,
			EnabledProducts = enabledProducts,
			DisabledProducts = disabledProducts,
			NumUpdatesAvailable = numUpdatesAvailable,
			Launch = function(
				productId: string
			): ()
				for peer, peerProductId in productDiscovery.peerProductIds do
					if peerProductId == productId then
						sharedToolbar.trySendButtonClick(peer, "invokeProduct")
						return
					end
				end
				warn(`Couldn't launch {productId}`)
			end,
			FetchChangelogText = function(
				productId: string,
				version: ProductDiscovery.ProductVersion
			): Permissioned.Permissioned<Maybe.Maybe<string>>
				return Permissioned.grantToCompletion(
					Permissioned.placeholderGranter,
					productDiscovery.fetchChangelogText,
					productId,
					version
				)
			end
		}
	)

	table.insert(
		scope,
		{
			scope:Observer(productHubIsOpen):onBind(function()
				if leader.selfIsLeader() == true then
					sharedToolbar.setActive("openProductHub", peek(productHubIsOpen))
				end
				hubWidget.setVisible(peek(productHubIsOpen))
			end),
			scope:Observer(productHubIconRamp):onChange(function()
				sharedToolbar.setIconRamp("openProductHub", peek(productHubIconRamp))
			end),
			hubWidget.onChangeVisible(
				function(
					isVisible: boolean
				): ()
					productHubIsOpen:set(isVisible)
				end
			),
			sharedToolbar.onClick(
				function(
					buttonId: string
				): ()
					if buttonId == "openProductHub" then
						productHubIsOpen:set(not peek(productHubIsOpen))
					elseif buttonId == "invokeProduct" then
						productHubIsOpen:set(false)
						doInvokeProduct()
					end
				end
			)
		}
	)

	do
		local selfProductInfoPack = peek(productInfoPacks)[productDiscovery.selfProductId]
		if selfProductInfoPack ~= nil and needsUpdate(peek, selfProductInfoPack) then
			notificationStack.pushNotification({
				spec = {
					soundStyle = "generic",
					accentHue = productDiscovery.selfOfflineProductInfo.accentHue,
					iconRamp = productDiscovery.selfOfflineProductInfo.robloxIcons,
					text = `An update for {productDiscovery.selfOfflineProductInfo.displayName} is available`,
					actionButtons = {
						{
							id = "open",
							text = "Open Product Hub",
							illuminated = true
						}
					}
				},
				actionHandler = function(id)
					if id == "open" then
						productHubIsOpen:set(true)
					end
				end
			})
		end
	end

	local productHubApi = {}
	productHubApi.onInvokeProduct = onInvokeProduct

	function productHubApi.setActive(
		isActive: boolean
	): ()
		sharedToolbar.setActive("invokeProduct", isActive)
	end

	function productHubApi.setClickableWhenViewportHidden(
		clickableWhenViewportHidden: boolean
	): ()
		sharedToolbar.setClickableWhenViewportHidden("invokeProduct", clickableWhenViewportHidden)
	end

	function productHubApi.setIconRamp(
		iconRamp: IconRamp.IconRamp
	): ()
		sharedToolbar.setIconRamp("invokeProduct", iconRamp)
	end

	return productHubApi
end

return ProductHub