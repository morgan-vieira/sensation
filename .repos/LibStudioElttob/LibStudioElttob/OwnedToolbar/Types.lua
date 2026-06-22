--!strict
-- (c) Studio Elttob 2024. All rights reserved, seek permission before use.

local Package = script.Parent
local LibStudioElttob = Package.Parent
local LibOpen = LibStudioElttob.Parent.LibOpen

local Fusion = require(LibOpen.Fusion)
local IconRamp = require(LibStudioElttob.IconRamp)

local Types = {}

type StateObjectPtr<T> = Fusion.Value<Fusion.StateObject<T>>

export type ToolbarButton = {
	instance: PluginToolbarButton,
	iconRampState: StateObjectPtr<IconRamp.IconRamp>,
	activeState: StateObjectPtr<boolean>,
	clickableWhenViewportHiddenState: StateObjectPtr<boolean>
}

export type OwnedToolbarApi = {
	buttons: {[string]: ToolbarButton},

	initOrReuseButton: (
		id: string,
		newIconRamp: Fusion.StateObject<IconRamp.IconRamp>,
		displayNameFirstTimeOnly: string,
		toolTipFirstTimeOnly: string,
		newActive: Fusion.StateObject<boolean>,
		newClickableWhenViewportHidden: Fusion.StateObject<boolean>
	) -> (ToolbarButton, boolean)
}

return Types