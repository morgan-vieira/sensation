--!strict
-- (c) Studio Elttob 2024. All rights reserved, seek permission before use.

local Package = script.Parent
local LibStudioElttob = Package.Parent
local LibOpen = LibStudioElttob.Parent.LibOpen

local Event = require(LibOpen.Event)
local Fusion = require(LibOpen.Fusion)
local IconRamp = require(LibStudioElttob.IconRamp)
local ProductDiscovery = require(LibStudioElttob.ProductDiscovery)

local Types = {}

export type ProductInfoPack = {
	Scope: Fusion.Scope<unknown>,
	Offline: Fusion.Value<ProductDiscovery.ProductInfo?>,
	Latest: Fusion.Value<ProductDiscovery.ProductInfo?>
}

export type ProductHubApi = {
	onInvokeProduct: Event.Connect<>,

	setActive: (
		isActive: boolean
	) -> (),

	setClickableWhenViewportHidden: (
		clickableWhenViewportHidden: boolean
	) -> (),

	setIconRamp: (
		iconRamp: IconRamp.IconRamp
	) -> ()
}

return Types