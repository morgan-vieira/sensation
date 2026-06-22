--!strict
--!nolint LocalShadow
-- (c) Studio Elttob 2024. All rights reserved, seek permission before use.

local CoreGui = game:GetService("CoreGui")

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
export type SharedScreenGuiApi = Types.SharedScreenGuiApi

local logger = Log.create("SharedScreenGui", false)

local SharedScreenGui = {}

function SharedScreenGui.connect<MainViewData>(
	screenGuiScope: Fusion.Scope<typeof(Fusion)>,
	interposer: Interposer.InterposerApi,
	leader: Leader.LeaderApi,
	screenGuiId: string,
	creationInfo: Types.CreationInfo<MainViewData>,
	mainViewData: MainViewData
): Types.SharedScreenGuiApi
	local onChangeVisible, doChangeVisible = Event()

	local PROTOCOL: Interposer.ProtocolDef = {
		id = `@StudioElttob/SharedScreenGui/{screenGuiId}`,
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
	local currentOwnedGui: ScreenGui? = nil

	local function createOwnedGui(): ()
		assert(currentOwnedGui == nil, "Attempt to double-create the owned screen GUI")
		logger.info(`{interposer.selfPeer} is creating the owned screen GUI`)
		currentOwnedGui = screenGuiScope:New "ScreenGui" {
			Parent = CoreGui,
			Name = creationInfo.title,
			DisplayOrder = creationInfo.displayOrder,
			ZIndexBehavior = creationInfo.zIndexBehaviour,
			[OnChange "Enabled"] = function(isVisible)
				doChangeVisible(isVisible)
				protocolApi.sendEvent("onChangeVisible", "everyone", {
					isVisible = isVisible
				})
			end,
			[Children] = creationInfo.mainView(screenGuiScope, {
				Data = mainViewData
			})
		} :: ScreenGui
		logger.info(`{interposer.selfPeer} has finished creating the owned screen GUI`)
	end

	protocolApi = interposer.connectProtocol(
		screenGuiScope,
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
					if currentOwnedGui ~= nil then
						logger.info(`Setting GUI enabled to {args.isVisible}`)
						currentOwnedGui.Enabled = args.isVisible
					end
				end
			},
			requests = {}
		}
	)

	table.insert(
		screenGuiScope,
		FinallyTask(task.spawn, function(taskScope)
			while true do
				local selfIsLeader = leader.selfIsLeader()
				if selfIsLeader == true then
					createOwnedGui()
					break
				else
					local push, pull = PushPull.yield()
					leader.onLeaderChanged(push)
					pull()
				end
			end
		end)
	)

	local sharedScreenGuiApi = {}
	sharedScreenGuiApi.onChangeVisible = onChangeVisible

	function sharedScreenGuiApi.setVisible(
		isVisible: boolean
	): ()
		if currentOwnedGui ~= nil then
			currentOwnedGui.Enabled = isVisible
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

	return sharedScreenGuiApi
end

return SharedScreenGui