--!strict
-- (c) Studio Elttob 2024. All rights reserved, seek permission before use.

local HttpService = game:GetService("HttpService")

local Package = script
local LibStudioElttob = Package.Parent
local LibOpen = LibStudioElttob.Parent.LibOpen

local Maybe = require(LibOpen.Maybe)
local Event = require(LibOpen.Event)
local Permissioned = require(LibOpen.Permissioned)
local Log = require(LibStudioElttob.Log)
local Interposer = require(LibStudioElttob.Interposer)
local APILinks = require(LibStudioElttob.APILinks)
local Types = require(Package.Types)

export type ProductVersion = Types.ProductVersion
export type ProductLinkUrlType = Types.ProductLinkUrlType
export type ProductLinkUrl = Types.ProductLinkUrl
export type ProductLink = Types.ProductLink
export type ProductInfo = Types.ProductInfo
export type ProductsJSON = Types.ProductsJSON
export type ProductDiscoveryApi = Types.ProductDiscoveryApi

type Scope = {unknown}

local PROTOCOL = {
	id = "@StudioElttob/ProductDiscovery",
	version = {major = 1, minor = 0, patch = 0},
	staticInfo = Types.ProtocolStaticInfo,
	events = {},
	requests = {}
}

local PRODUCT_DISCOVERY_GRANT_INFO: Permissioned.GrantInfo = {
	id = "ProductDiscovery/download",
	askTo = "download up-to-date product information",
	usedTo = {
		"Notify you when new versions are available",
		"Show changelogs for updates"
	},
	notUsedTo = {},
	grantingWill = {
		"Securely connect to Studio Elttob's website",
		"Download static data about products"
	},
	grantingWont = {
		"Download or run any code packages"
	},
	disclaimers = {}
}

local logger = Log.create("ProductDiscovery", false)

local function fetchProductsJSON(
	grant: Permissioned.Grant
): Maybe.Maybe<Types.ProductsJSON>
	local maybeRaw = grant(
		PRODUCT_DISCOVERY_GRANT_INFO, 
		Permissioned.http.get, 
		`{APILinks.SUITE_API}/v1/products.json`
	) :: Maybe.Maybe<string>
	if not maybeRaw.some then
		return maybeRaw
	end
	local isJSON, jsonResult = pcall(HttpService.JSONDecode, HttpService, maybeRaw.value)
	if not isJSON then
		return Maybe.None(`Couldn't decode response as JSON: {jsonResult}`)
	end
	return Types.ProductsJSON:Cast(jsonResult) :: any
end

local function fetchChangelogText(
	grant: Permissioned.Grant,
	productId: string,
	version: Types.ProductVersion
): Maybe.Maybe<string>
	return grant(
		PRODUCT_DISCOVERY_GRANT_INFO, 
		Permissioned.http.get, 
		`{APILinks.SUITE_API}/v1/changelogs/{productId}/{version.major}.{version.minor}.{version.patch}.txt`
	) :: Maybe.Maybe<string>
end

local ProductDiscovery = {}
ProductDiscovery.Types = Types

function ProductDiscovery.init(
	scope: Scope,
	grant: Permissioned.Grant,
	interposer: Interposer.InterposerApi,
	selfProductId: string,
	offlineProductInfo: Types.ProductInfo
): Types.ProductDiscoveryApi
	local onlineProductInfos: Maybe.Maybe<{[string]: Types.ProductInfo}>
	do
		local productsJSON = fetchProductsJSON(grant)
		if productsJSON.some then
			onlineProductInfos = Maybe.Some(productsJSON.value.products)
		else
			onlineProductInfos = Maybe.None(`Failed to fetch products.json: {productsJSON.reason}`)
		end
	end

	local peerProductIds: {[Interposer.Peer]: string} = {[interposer.selfPeer] = selfProductId}
	local onProductDiscovered, doProductDiscovered: (Interposer.Peer, string) -> () = Event()
	local onProductForgotten, doProductForgotten: (Interposer.Peer, string) -> () = Event()

	local function onJoinedProtocol(
		peer: Interposer.Peer,
		staticInfo: Types.ProtocolStaticInfo
	): ()
		local existingId = peerProductIds[peer]
		if existingId ~= nil then
			if existingId ~= staticInfo.productId then
				logger.warn(`Conflicting peer {peer} / product id {staticInfo.productId} (existing: {peerProductIds[peer]}) - ignoring duplication`)
			end
			return
		end
		peerProductIds[peer] = staticInfo.productId
		doProductDiscovered(peer, staticInfo.productId)
	end

	local function onLeavingProtocol(
		peer: Interposer.Peer,
		staticInfo: Types.ProtocolStaticInfo
	): ()
		if peerProductIds[peer] == staticInfo.productId then
			doProductForgotten(peer, staticInfo.productId)
			peerProductIds[peer] = nil
		end
	end

	local protocolApi = interposer.connectProtocol(
		scope,
		PROTOCOL,
		{
			productId = selfProductId,
			offlineProductInfo = offlineProductInfo
		} :: Types.ProtocolStaticInfo,
		{
			events = {},
			requests = {}
		}
	)
	
	table.insert(scope, {
		protocolApi.onJoinedProtocol(onJoinedProtocol),
		protocolApi.onLeavingProtocol(onLeavingProtocol),

		onProductDiscovered(function()
			local awareOfOffline = {}
			local awareOfOnline = {}
			for peer, staticInfo in protocolApi.staticInfoMap do
				table.insert(awareOfOffline, staticInfo.info.offlineProductInfo.displayName)
			end
			if onlineProductInfos.some then
				for peer, staticInfo in protocolApi.staticInfoMap do
					local info = onlineProductInfos.value[staticInfo.info.productId]
					if info ~= nil then
						table.insert(awareOfOnline, info.displayName)
					end
				end
			end
			logger.info(`[{interposer.selfPeer}] I am {offlineProductInfo.displayName}, and I am aware of offline {table.concat(awareOfOffline, " and ")}, as well as online {table.concat(awareOfOnline, " and ")}`)
		end)
	})

	for peer, staticInfo in protocolApi.staticInfoMap do
		onJoinedProtocol(peer, staticInfo.info)
	end

	local productDiscoveryApi = {}
	productDiscoveryApi.selfProductId = selfProductId
	productDiscoveryApi.peerProductIds = peerProductIds
	productDiscoveryApi.onProductDiscovered = onProductDiscovered
	productDiscoveryApi.onProductForgotten = onProductForgotten
	productDiscoveryApi.selfOfflineProductInfo = offlineProductInfo
	productDiscoveryApi.onlineProductInfos = onlineProductInfos

	function productDiscoveryApi.getOfflineProductInfo(
		productId: string
	): Maybe.Maybe<ProductInfo>
		if productId == selfProductId then
			return Maybe.Some(offlineProductInfo)
		end
		for peer, staticInfo in protocolApi.staticInfoMap do
			if staticInfo.info.productId == productId then
				return Maybe.Some(staticInfo.info.offlineProductInfo)
			end
		end
		return Maybe.None(`Product {productId} is not currently connected`)
	end

	function productDiscoveryApi.getLatestProductInfo(
		productId: string
	): Maybe.Maybe<ProductInfo>
		if onlineProductInfos.some then
			local info = onlineProductInfos.value[productId]
			if info == nil then
				return Maybe.None(`Product {productId} not present on website`)
			else
				return Maybe.Some(info)
			end
		else
			return Maybe.None(`Online products not available: {onlineProductInfos.reason}`)
		end
	end

	function productDiscoveryApi.fetchChangelogText(
		grant: Permissioned.Grant,
		productId: string,
		version: Types.ProductVersion
	): Maybe.Maybe<string>
		return fetchChangelogText(grant, productId, version)
	end

	return productDiscoveryApi
end

return ProductDiscovery