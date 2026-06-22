--!strict
-- (c) Studio Elttob 2024. All rights reserved, seek permission before use.

local Package = script.Parent
local LibStudioElttob = Package.Parent
local LibOpen = LibStudioElttob.Parent.LibOpen

local Event = require(LibOpen.Event)
local Fusion = require(LibOpen.Fusion)
local ty = require(LibOpen.ty)
local Interposer = require(LibStudioElttob.Interposer)
local IconRamp = require(LibStudioElttob.IconRamp)

local Types = {}

export type ButtonSpec = {
	toolTip: string,
	iconRamp: IconRamp.IconRamp,
	displayName: string,
	clickableWhenViewportHidden: boolean,
	creationOrder: number
}
Types.ButtonSpec = ty.Struct({exhaustive = false}, {
	toolTip = ty.String,
	iconRamp = IconRamp.Types.IconRamp,
	displayName = ty.String,
	clickableWhenViewportHidden = ty.Boolean,
	creationOrder = ty.Number
})

export type ButtonState = {
	iconRamp: Fusion.Value<IconRamp.IconRamp>,
	clickableWhenViewportHidden: Fusion.Value<boolean>,
	active: Fusion.Value<boolean>
}

export type SharedToolbarApi = {
	onClick: Event.Connect<string>,
	setActive: (buttonId: string, boolean) -> (),
	setClickableWhenViewportHidden: (buttonId: string, boolean) -> (),
	setIconRamp: (buttonId: string, IconRamp.IconRamp) -> (),
	trySendButtonClick: (Interposer.Peer, buttonId: string) -> ()
}

export type ProtocolStaticInfo = {
	stableId: string,
	buttonSpecs: {[string]: ButtonSpec}
}
Types.ProtocolStaticInfo = ty.Struct({exhaustive = false}, {
	stableId = ty.String,
	buttonSpecs = ty.String:MapOf(Types.ButtonSpec)
})

return Types