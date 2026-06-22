--!strict
-- (c) Studio Elttob 2024. All rights reserved, seek permission before use.

local Package = script.Parent
local LibStudioElttob = Package.Parent
local LibOpen = LibStudioElttob.Parent.LibOpen

local Event = require(LibOpen.Event)
local ty = require(LibOpen.ty)
local Maybe = require(LibOpen.Maybe)
local Permissioned = require(LibOpen.Permissioned)
local Interposer = require(LibStudioElttob.Interposer)
local IconRamp = require(LibStudioElttob.IconRamp)

local Types = {}

export type ProductVersion = {major: number, minor: number, patch: number}
Types.ProductVersion = 
	ty.Struct({exhaustive = false}, {
		major = ty.Number,
		minor = ty.Number,
		patch = ty.Number
	})
	:Nicknamed("ProductVersion")

export type ProductLinkUrlType = "roblox" | "itch" | "website" | "robloxDevforum"
Types.ProductLinkUrlType = 
	ty.Just "roblox"
	:Or(ty.Just "itch")
	:Or(ty.Just "website")
	:Or(ty.Just "robloxDevforum")
	:Nicknamed("ProductLinkUrlType")

export type ProductLinkUrl = {
	type: ProductLinkUrlType,
	url: string
}
Types.ProductLinkUrl = 
	ty.Struct({exhaustive = false}, {
		type = Types.ProductLinkUrlType,
		url = ty.String
	})
	:Nicknamed("ProductLinkUrl")

export type ProductLink = {
	displayName: string,
	urls: {ProductLinkUrl}
}
Types.ProductLink = 
	ty.Struct({exhaustive = false}, {
		displayName = ty.String,
		urls = Types.ProductLinkUrl:Array()
	})
	:Nicknamed("ProductLink")

export type ProductInfo = {
	version: ProductVersion,
	displayName: string,
	tagline: string,
	robloxIcons: IconRamp.IconRamp,
	accentHue: number,
	links: {ProductLink}
}
Types.ProductInfo = 
	ty.Struct({exhaustive = false}, {
		version = Types.ProductVersion,
		displayName = ty.String,
		tagline = ty.String,
		robloxIcons = IconRamp.Types.IconRamp,
		accentHue = ty.Number,
		links = Types.ProductLink:IgnoreInvalid():Array()
	})
	:Nicknamed("ProductInfo")

export type ProductsJSON = {
	formatVersion: number,
	products: {[string]: ProductInfo}
}
Types.ProductsJSON =
	ty.Struct({exhaustive = false}, {
		formatVersion = ty.Number:And(ty.Predicate(function(x: any) return x >= 1 end)),
		products = ty.String:MapOf(Types.ProductInfo:IgnoreInvalid())
	})
	:Nicknamed("ProductsJSON")

export type ProductDiscoveryApi = {
	selfProductId: string,
	peerProductIds: {[Interposer.Peer]: string},
	onProductDiscovered: Event.Connect<Interposer.Peer, string>,
	onProductForgotten: Event.Connect<Interposer.Peer, string>,

	selfOfflineProductInfo: ProductInfo,
	getOfflineProductInfo: (productId: string) -> Maybe.Maybe<ProductInfo>,
	getLatestProductInfo: (productId: string) -> Maybe.Maybe<ProductInfo>,
	onlineProductInfos: Maybe.Maybe<{[string]: ProductInfo}>,

	fetchChangelogText: (
		Permissioned.Grant,
		productId: string,
		ProductVersion
	) -> Maybe.Maybe<string>
}

export type ProtocolStaticInfo = {
	productId: string,
	offlineProductInfo: ProductInfo
}
Types.ProtocolStaticInfo = ty.Struct({exhaustive = false}, {
	productId = ty.String,
	offlineProductInfo = Types.ProductInfo
})

return Types