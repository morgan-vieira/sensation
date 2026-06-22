--!strict
-- (c) Studio Elttob 2024. All rights reserved, seek permission before use.

local Package = script.Parent
local LibStudioElttob = Package.Parent
local LibOpen = LibStudioElttob.Parent.LibOpen

local Event = require(LibOpen.Event)
local Fusion = require(LibOpen.Fusion)

local Types = {}

export type CreationInfo<MainViewData> = {
	title: string,
	zIndexBehaviour: Enum.ZIndexBehavior,
	info: DockWidgetPluginGuiInfo,
	mainView: (
		scope: Fusion.Scope<typeof(Fusion)>,
		props: {
			Widget: {
				BindToClose: (maybeCallback: (() -> ())?) -> (),
			},
			Data: MainViewData
		}
	) -> Fusion.Child
}

export type SharedWidgetApi = {
	onChangeVisible: Event.Connect<boolean>,
	setVisible: (boolean) -> ()
}

return Types