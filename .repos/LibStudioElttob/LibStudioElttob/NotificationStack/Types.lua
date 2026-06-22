--!strict
-- (c) Studio Elttob 2024. All rights reserved, seek permission before use.

local Package = script.Parent
local LibStudioElttob = Package.Parent
local LibOpen = LibStudioElttob.Parent.LibOpen

local ty = require(LibOpen.ty)
local Interposer = require(LibStudioElttob.Interposer)
local IconRamp = require(LibStudioElttob.IconRamp)

local Types = {}

export type ActionButtonSpec = {
	id: string,
	text: string,
	illuminated: boolean
}
Types.ActionButtonSpec = 
	ty.Struct({exhaustive = false}, {
		id = ty.String,
		text = ty.String,
		illuminated = ty.Boolean
	})
	:Nicknamed("ActionButtonSpec")

export type SoundStyle =
	"generic"
	| "subtle"
	| "attention"
	| "ask"
	| "success"
	| "fail"
Types.SoundStyle = 
	ty.Just "generic"
	:Or(ty.Just "subtle")
	:Or(ty.Just "attention")
	:Or(ty.Just "ask")
	:Or(ty.Just "success")
	:Or(ty.Just "fail")
	:Nicknamed("SoundStyle")

export type NotificationSpec  = {
	iconRamp: IconRamp.IconRamp?,
	text: string,
	actionButtons: {ActionButtonSpec},
	soundStyle: SoundStyle?,
	accentHue: number?
}
Types.NotificationSpec = 
	ty.Struct({exhaustive = false}, {
		iconRamp = IconRamp.Types.IconRamp:Optional(),
		text = ty.String,
		actionButtons = Types.ActionButtonSpec:IgnoreInvalid():Array(),
		soundStyle = Types.SoundStyle:Optional(),
		accentHue = ty.Number:Optional()
	})
	:Nicknamed("NotificationSpec")

export type Notification  = {
	id: string,
	fromPeer: Interposer.Peer,
	creationTime: number,
	spec: NotificationSpec
}
Types.Notification = 
	ty.Struct({exhaustive = false}, {
		id = ty.String,
		fromPeer = Interposer.Types.Peer,
		creationTime = ty.Number,
		spec = Types.NotificationSpec
	})
	:Nicknamed("Notification")

export type NotificationStackApi = {
	pushNotification: ({
		spec: NotificationSpec,
		actionHandler: ((id: string) -> ())?,
		popHandler: (() -> ())?
	}) -> ()
}

return Types