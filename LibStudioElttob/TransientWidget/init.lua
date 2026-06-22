--!strict
--!nolint LocalShadow
-- (c) Studio Elttob 2024. All rights reserved, seek permission before use.

local plugin = script:FindFirstAncestorWhichIsA("Plugin") :: Plugin
local HttpService = game:GetService("HttpService")

local Package = script
local LibStudioElttob = Package.Parent
local LibOpen = LibStudioElttob.Parent.LibOpen

local Event = require(LibOpen.Event)
local Fusion = require(LibOpen.Fusion)
local Children, OnChange = Fusion.Children, Fusion.OnChange
local Types = require(Package.Types)

local TransientWidget = {}

function TransientWidget.show<MainViewData>(
	widgetScope: Fusion.Scope<typeof(Fusion)>,
	creationInfo: Types.CreationInfo<MainViewData>,
	mainViewData: MainViewData
): Types.TransientWidgetApi
	local onChangeVisible, doChangeVisible: (boolean) -> () = Event()

	local id = `temp_{HttpService:GenerateGUID()}`
	local widget = plugin:CreateDockWidgetPluginGui(
		id,
		creationInfo.info
	)
	widget.Name = creationInfo.title
	widget.Title = creationInfo.title
	widget.ZIndexBehavior = creationInfo.zIndexBehaviour

	widgetScope:Hydrate(widget) {
		[Children] = creationInfo.mainView(widgetScope, {
			Widget = {
				BindToClose = function(
					maybeCallback: (() -> ())?
				): ()
					widget:BindToClose(maybeCallback)
				end
			},
			Data = mainViewData
		}),
		[OnChange "Enabled"] = doChangeVisible
	}

	local transientWidgetApi = {}
	transientWidgetApi.onChangeVisible = onChangeVisible

	function transientWidgetApi.setVisible(
		isVisible: boolean
	): ()
		widget.Enabled = isVisible
	end

	return transientWidgetApi
end

return TransientWidget
