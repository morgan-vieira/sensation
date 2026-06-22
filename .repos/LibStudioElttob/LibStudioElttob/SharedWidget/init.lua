--!strict
--!nolint LocalShadow
-- (c) Studio Elttob 2024. All rights reserved, seek permission before use.

local plugin = script:FindFirstAncestorWhichIsA("Plugin") :: Plugin

local Package = script
local LibStudioElttob = Package.Parent
local LibOpen = LibStudioElttob.Parent.LibOpen

local ty = require(LibOpen.ty)
local Event = require(LibOpen.Event)
local Fusion = require(LibOpen.Fusion)
local Children, OnChange = Fusion.Children, Fusion.OnChange
local PushPull = require(LibOpen.PushPull)
local FinallyTask = require(LibOpen.FinallyTask)
local Log = require(LibStudioElttob.Log)
local Interposer = require(LibStudioElttob.Interposer)
local Leader = require(LibStudioElttob.Leader)
local Types = require(Package.Types)

export type CreationInfo<MainViewData> = Types.CreationInfo<MainViewData>
export type SharedWidgetApi = Types.SharedWidgetApi

local logger = Log.create("SharedWidget", false)

local SharedWidget = {}

function SharedWidget.connect<MainViewData>(
	widgetScope: Fusion.Scope<typeof(Fusion)>,
	interposer: Interposer.InterposerApi,
	leader: Leader.LeaderApi,
	widgetId: string,
	creationInfo: Types.CreationInfo<MainViewData>,
	mainViewData: MainViewData
): Types.SharedWidgetApi
	local onChangeVisible, doChangeVisible = Event()

	local PROTOCOL: Interposer.ProtocolDef = {
		id = `@StudioElttob/SharedWidget/{widgetId}`,
		version = {major = 1, minor = 0, patch = 0},
		staticInfo = ty.Nil,
		events = {
			onChangeVisible = {
				argumentType = ty.Struct({exhaustive = false}, {
					isVisible = ty.Boolean
				})
			},

			setVisible = {
				argumentType = ty.Struct({exhaustive = false}, {
					isVisible = ty.Boolean
				})
			}
		},
		requests = {}
	}

	local protocolApi: Interposer.ProtocolApi<nil>
	local currentOwnedWidget: DockWidgetPluginGui? = nil

	local function createOwnedWidget(): ()
		assert(currentOwnedWidget == nil, "Attempt to double-create the owned widget")
		logger.info(`{interposer.selfPeer} is creating the owned widget`)
		local ownedWidget = plugin:CreateDockWidgetPluginGui(
			`SharedWidget{widgetId}`,
			creationInfo.info
		)
		currentOwnedWidget = ownedWidget
		ownedWidget.Name = creationInfo.title
		ownedWidget.Title = creationInfo.title
		ownedWidget.ZIndexBehavior = creationInfo.zIndexBehaviour

		widgetScope:Hydrate(ownedWidget) {
			[Children] = creationInfo.mainView(widgetScope, {
				Widget = {
					BindToClose = function(
						maybeCallback: (() -> ())?
					): ()
						ownedWidget:BindToClose(maybeCallback)
					end
				},
				Data = mainViewData
			}),
			[OnChange "Enabled"] = function(isVisible)
				doChangeVisible(isVisible)
				protocolApi.sendEvent("onChangeVisible", "everyone", {
					isVisible = isVisible
				})
			end
		}
		logger.info(`{interposer.selfPeer} has finished creating the owned widget`)
	end

	protocolApi = interposer.connectProtocol(
		widgetScope,
		PROTOCOL,
		nil,
		{
			events = {
				onChangeVisible = function(
					fromPeer: Interposer.Peer,
					args: {
						isVisible: boolean
					}
				): ()
					logger.info(`Received onChangeVisible from {fromPeer}`)
					if fromPeer ~= interposer.selfPeer then
						doChangeVisible(args.isVisible)
					end
				end,

				setVisible = function(
					fromPeer: Interposer.Peer,
					args: {
						isVisible: boolean
					}
				): ()
					if currentOwnedWidget ~= nil then
						logger.info(`Setting widget enabled to {args.isVisible}`)
						currentOwnedWidget.Enabled = args.isVisible
					end
				end
			},
			requests = {}
		}
	)

	table.insert(
		widgetScope,
		FinallyTask(task.spawn, function(taskScope)
			while true do
				local selfIsLeader = leader.selfIsLeader()
				if selfIsLeader == true then
					createOwnedWidget()
					break
				else
					local push, pull = PushPull.yield()
					leader.onLeaderChanged(push)
					pull()
				end
			end
		end)
	)

	local sharedWidgetApi = {}
	sharedWidgetApi.onChangeVisible = onChangeVisible

	function sharedWidgetApi.setVisible(
		isVisible: boolean
	): ()
		if currentOwnedWidget ~= nil then
			currentOwnedWidget.Enabled = isVisible
			doChangeVisible(isVisible)
			protocolApi.sendEvent("onChangeVisible", "everyone", {
				isVisible = isVisible
			})
		else
			protocolApi.sendEvent("setVisible", "everyone", {
				isVisible = isVisible
			})
		end
	end

	return sharedWidgetApi
end

return SharedWidget