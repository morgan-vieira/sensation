--!strict
--!nolint LocalShadow
-- (c) Studio Elttob 2024. All rights reserved, seek permission before use.

local Package = script
local LibStudioElttob = Package.Parent
local LibOpen = LibStudioElttob.Parent.LibOpen

local Event = require(LibOpen.Event)
local ty = require(LibOpen.ty)
local Fusion = require(LibOpen.Fusion)
local sortingBy = require(LibOpen.sortingBy)
local FinallyTask = require(LibOpen.FinallyTask)
local PushPull = require(LibOpen.PushPull)
local Log = require(LibStudioElttob.Log)
local IconRamp = require(LibStudioElttob.IconRamp)
local Interposer = require(LibStudioElttob.Interposer)
local Leader = require(LibStudioElttob.Leader)
local OwnedToolbar = require(LibStudioElttob.OwnedToolbar)
local Types = require(Package.Types)

export type ButtonSpec = Types.ButtonSpec
export type ButtonState = Types.ButtonState
export type SharedToolbarApi = Types.SharedToolbarApi

type ButtonSpecWithId = {
	stableId: string,
	buttonId: string,
	spec: Types.ButtonSpec
}
local BUTTON_SORTER = sortingBy(
	function(
		button: ButtonSpecWithId
	)
		return {
			button.spec.creationOrder,
			button.stableId,
			button.spec.displayName
		}
	end
)

-- After discovering a button to add to the toolbar, wait this long for any
-- others to be added, so they can be sorted as a batch
local OWNED_BUTTON_BATCH_PERIOD = 0.5

local UNBOUND_BUTTON_ICON: IconRamp.IconRamp = {
	{
		size = 64,
		variants = {
			light = "",
			dark = "",
			mono = ""
		}
	},
	{
		size = 512,
		variants = {
			light = "",
			dark = "",
			mono = ""
		}
	}
}

local logger = Log.create("SharedToolbar", false)

local SharedToolbar = {}

function SharedToolbar.connect(
	toolbarScope: Fusion.Scope<typeof(Fusion)>,
	interposer: Interposer.InterposerApi,
	leader: Leader.LeaderApi,
	toolbarId: string,
	toolbarTitle: string,
	thisStableId: string,
	ourPrivateButtons: {[string]: Types.ButtonSpec},
	ourSharedButtons: {[string]: Types.ButtonSpec}
): Types.SharedToolbarApi
	for id in ourPrivateButtons do
		assert(ourSharedButtons[id] == nil, `Private and shared button share the same id: {id}`)
	end
	for id in ourSharedButtons do
		assert(ourPrivateButtons[id] == nil, `Private and shared button share the same id: {id}`)
	end

	local PROTOCOL: Interposer.ProtocolDef = {
		id = `@StudioElttob/SharedToolbar/{toolbarId}`,
		version = {major = 1, minor = 0, patch = 0},
		staticInfo = Types.ProtocolStaticInfo,
		events = {
			onSharedClick = {
				argumentType = ty.Struct({exhaustive = false}, {
					buttonId = ty.String
				})
			},
			setActive = {
				argumentType = ty.Struct({exhaustive = false}, {
					buttonId = ty.String,
					isActive = ty.Boolean
				})
			},
			setClickableWhenViewportHidden = {
				argumentType = ty.Struct({exhaustive = false}, {
					buttonId = ty.String,
					clickabeWhenViewportHidden = ty.Boolean
				})
			},
			setIconRamp = {
				argumentType = ty.Struct({exhaustive = false}, {
					buttonId = ty.String,
					iconRamp = IconRamp.Types.IconRamp
				})
			}
		},
		requests = {}
	}

	local onClick, doClick: (string) -> () = Event()
	local protocolApi: Interposer.ProtocolApi<Types.ProtocolStaticInfo>
	local currentOwnedToolbar: OwnedToolbar.OwnedToolbarApi? = nil

	local buttonScopes: {[string]: Fusion.Scope<typeof(Fusion)>} = {}

	local buttonStates: {[string]: Types.ButtonState} = {}

	local function peerFromStableId(
		stableId: string
	): Interposer.Peer?
		for peer, staticInfo in protocolApi.staticInfoMap do
			if staticInfo.info.stableId == stableId then
				return peer
			end
		end
		return nil
	end

	local function stableIdFromPeer(
		peer: Interposer.Peer
	): string?
		local staticInfo = protocolApi.staticInfoMap[peer]
		if staticInfo == nil then
			return nil
		end
		return staticInfo.info.stableId
	end

	local function sendButtonClick(
		stableId: string,
		buttonId: string
	): ()
		if stableId == thisStableId then
			doClick(buttonId)
		else
			local sendToPeer = peerFromStableId(stableId)
			if sendToPeer == nil then
				logger.warn(`Couldn't figure out who {stableId} is`)
			else
				protocolApi.sendEvent("onSharedClick", sendToPeer, {
					buttonId = buttonId,
				})
			end
		end
	end

	local function setButtonActive(
		stableId: string,
		buttonId: string,
		isActive: boolean,
		options: {
			broadcastChange: boolean
		}
	): ()
		local hybridId = `{stableId}/{buttonId}`
		local buttonState = buttonStates[hybridId]
		assert(buttonState ~= nil, `No button state for {hybridId}`)
		buttonState.active:set(isActive)
		if options.broadcastChange then
			local sendToPeer = peerFromStableId(stableId)
			if sendToPeer == nil then
				logger.warn(`Couldn't figure out who {stableId} is`)
			else
				protocolApi.sendEvent("setActive", sendToPeer, {
					buttonId = buttonId, 
					isActive = isActive
				})
			end
		end
	end

	local function setButtonClickableWhenViewportHidden(
		stableId: string,
		buttonId: string,
		clickableWhenViewportHidden: boolean,
		options: {
			broadcastChange: boolean
		}
	): ()
		local hybridId = `{stableId}/{buttonId}`
		local buttonState = buttonStates[hybridId]
		assert(buttonState ~= nil, `No button state for {hybridId}`)
		buttonState.clickableWhenViewportHidden:set(clickableWhenViewportHidden)
		if options.broadcastChange then
			local sendToPeer = peerFromStableId(stableId)
			if sendToPeer == nil then
				logger.warn(`Couldn't figure out who {stableId} is`)
			else
				protocolApi.sendEvent("setClickableWhenViewportHidden", sendToPeer, {
					buttonId = buttonId,
					clickableWhenViewportHidden = clickableWhenViewportHidden
				})
			end
		end
	end

	local function setButtonIconRamp(
		stableId: string,
		buttonId: string,
		iconRamp: IconRamp.IconRamp,
		options: {
			broadcastChange: boolean
		}
	): ()
		local hybridId = `{stableId}/{buttonId}`
		local buttonState = buttonStates[hybridId]
		assert(buttonState ~= nil, `No button state for {hybridId}`)
		buttonState.iconRamp:set(iconRamp)
		if options.broadcastChange then
			local sendToPeer = peerFromStableId(stableId)
			if sendToPeer == nil then
				logger.warn(`Couldn't figure out who {stableId} is`)
			else
				protocolApi.sendEvent("setIconRamp", sendToPeer, {
					buttonId = buttonId,
					iconRamp = iconRamp
				})
			end
		end
	end

	local ownedButtonCreationQueue: {ButtonSpecWithId} = {}
	local ownedButtonCreatorTask: thread? = nil
	table.insert(
		toolbarScope,
		function()
			if ownedButtonCreatorTask ~= nil then
				task.cancel(ownedButtonCreatorTask)
				ownedButtonCreatorTask = nil
			end
		end
	)

	local allButtonScopes = toolbarScope:innerScope()
	table.insert(
		toolbarScope,
		allButtonScopes
	)

	local function createOwnedButtonSoon(
		stableId: string,
		buttonId: string,
		spec: Types.ButtonSpec
	): ()
		table.insert(ownedButtonCreationQueue, {stableId = stableId, buttonId = buttonId, spec = spec})
		if ownedButtonCreatorTask == nil then
			ownedButtonCreatorTask = task.delay(
				OWNED_BUTTON_BATCH_PERIOD, 
				function()
					ownedButtonCreatorTask = nil
					assert(currentOwnedToolbar ~= nil, `Attempt to create owned buttons without an owned toolbar`)
					local thisQueue = ownedButtonCreationQueue
					ownedButtonCreationQueue = {}

					table.sort(thisQueue, BUTTON_SORTER)

					for _, queued in thisQueue do
						local queuedHybridId = `{queued.stableId}/{queued.buttonId}`
						logger.info(`[{interposer.selfPeer}] adding {queuedHybridId} button as an owned button`)
						local queuedButtonScope = buttonScopes[queuedHybridId]
						assert(queuedButtonScope ~= nil, `Attempt to create owned button for unknown {queuedHybridId}`)
						local queuedButtonState = buttonStates[queuedHybridId]
						local queuedOwnedButton = currentOwnedToolbar.initOrReuseButton(
							queuedHybridId,
							queuedButtonState.iconRamp,
							queued.spec.displayName,
							queued.spec.toolTip,
							queuedButtonState.active,
							queuedButtonState.clickableWhenViewportHidden
						)
						table.insert(
							queuedButtonScope, 
							{
								function()
									queuedButtonState.iconRamp:set(UNBOUND_BUTTON_ICON)
								end :: any,
								queuedOwnedButton.instance.Click:Connect(function()
									sendButtonClick(queued.stableId, queued.buttonId)
								end)
							}
						)
					end
				end
			)
		end
	end

	local function createOwnedToolbar()
		assert(currentOwnedToolbar == nil, "Attempt to double-create the owned toolbar")
		local ownedToolbar = OwnedToolbar.create(toolbarScope, toolbarTitle)
		currentOwnedToolbar = ownedToolbar

		for buttonId, spec in ourPrivateButtons do
			createOwnedButtonSoon(thisStableId, buttonId, spec)
		end
		for buttonId, spec in ourSharedButtons do
			createOwnedButtonSoon(thisStableId, buttonId, spec)
		end
		for peer, staticInfo in protocolApi.staticInfoMap do
			if peer ~= interposer.selfPeer then
				for buttonId, spec in staticInfo.info.buttonSpecs do
					createOwnedButtonSoon(staticInfo.info.stableId, buttonId, spec)
				end
			end
		end
	end

	local function discoverButton(
		stableId: string,
		buttonId: string,
		spec: Types.ButtonSpec
	): ()
		logger.info(`[{interposer.selfPeer}] adding {stableId}/{buttonId} button`)
		local hybridId = `{stableId}/{buttonId}`
		assert(buttonScopes[hybridId] == nil, `Attempt to double-discover button {hybridId}`)
		local buttonScope = allButtonScopes:innerScope()
		buttonScopes[hybridId] = buttonScope
		buttonStates[hybridId] = {
			active = buttonScope:Value(false),
			iconRamp = buttonScope:Value(spec.iconRamp),
			clickableWhenViewportHidden = buttonScope:Value(spec.clickableWhenViewportHidden)
		}
		table.insert(
			buttonScope, 
			function()
				buttonStates[hybridId] = nil
			end
		)
		if currentOwnedToolbar ~= nil then
			createOwnedButtonSoon(stableId, buttonId, spec)
		end
	end

	local function forgetButton(
		stableId: string,
		buttonId: string
	): ()
		local hybridId = `{stableId}/{buttonId}`
		local buttonScope = buttonScopes[hybridId]
		assert(buttonScope ~= nil, `No existing button {hybridId} to forget`)
		buttonScopes[hybridId] = nil
		buttonScope:doCleanup()
	end

	protocolApi = interposer.connectProtocol(
		toolbarScope,
		PROTOCOL,
		{
			stableId = thisStableId,
			buttonSpecs = ourSharedButtons,
		} :: Types.ProtocolStaticInfo,
		{
			events = {
				onSharedClick = function(
					fromPeer: Interposer.Peer,
					args: {
						buttonId: string
					}
				): ()
					if ourSharedButtons[args.buttonId] == nil then
						return
					end
					doClick(args.buttonId)
				end,
				setActive = function(
					fromPeer: Interposer.Peer,
					args: {
						buttonId: string,
						isActive: boolean
					}
				): ()
					local stableId = stableIdFromPeer(fromPeer)
					if stableId ~= nil then
						setButtonActive(
							stableId, 
							args.buttonId, 
							args.isActive, 
							{broadcastChange = false}
						)
					end
				end,
				setClickableWhenViewportHidden = function(
					fromPeer: Interposer.Peer,
					args: {
						buttonId: string,
						clickableWhenViewportHidden: boolean
					}
				): ()
					local stableId = stableIdFromPeer(fromPeer)
					if stableId ~= nil then
						setButtonClickableWhenViewportHidden(
							stableId, 
							args.buttonId, 
							args.clickableWhenViewportHidden,
							{broadcastChange = false}
						)
					end
				end,
				setIconRamp = function(
					fromPeer: Interposer.Peer,
					args: {
						buttonId: string,
						iconRamp: IconRamp.IconRamp
					}
				): ()
					local stableId = stableIdFromPeer(fromPeer)
					if stableId ~= nil then
						setButtonIconRamp(
							stableId, 
							args.buttonId, 
							args.iconRamp,
							{broadcastChange = false}
						)
					end
				end
			},
			requests = {}
		}
	)

	table.insert(
		toolbarScope,
		{
			protocolApi.onJoinedProtocol(
				function(
					joiningPeer: Interposer.Peer,
					staticInfo: Types.ProtocolStaticInfo
				): ()
					for buttonId, spec in staticInfo.buttonSpecs do
						discoverButton(staticInfo.stableId, buttonId, spec)
					end
				end
			),
			protocolApi.onLeavingProtocol(
				function(
					leavingPeer: Interposer.Peer,
					staticInfo: Types.ProtocolStaticInfo
				): ()
					for buttonId, spec in staticInfo.buttonSpecs do
						forgetButton(staticInfo.stableId, buttonId)
					end
				end
			)
		}
	)

	for buttonId, spec in ourPrivateButtons do
		discoverButton(thisStableId, buttonId, spec)
	end
	for buttonId, spec in ourSharedButtons do
		discoverButton(thisStableId, buttonId, spec)
	end
	for peer, staticInfo in protocolApi.staticInfoMap do
		if peer ~= interposer.selfPeer then
			for buttonId, spec in staticInfo.info.buttonSpecs do
				discoverButton(staticInfo.info.stableId, buttonId, spec)
			end
		end
	end

	table.insert(
		toolbarScope,
		FinallyTask(task.spawn, function(taskScope)
			task.wait(1) -- give other plugins an opportunity to load
			while true do
				local selfIsLeader = leader.selfIsLeader()
				if selfIsLeader == true then
					createOwnedToolbar()
					break
				else
					local push, pull = PushPull.yield()
					leader.onLeaderChanged(push)
					pull()
				end
			end
		end)
	)

	local sharedToolbarApi = {}
	sharedToolbarApi.onClick = onClick

	function sharedToolbarApi.setActive(
		buttonId: string,
		isActive: boolean
	): ()
		setButtonActive(
			thisStableId,
			buttonId,
			isActive,
			{broadcastChange = true}
		)
	end

	function sharedToolbarApi.setClickableWhenViewportHidden(
		buttonId: string,
		clickableWhenViewportHidden: boolean
	): ()
		setButtonClickableWhenViewportHidden(
			thisStableId,
			buttonId,
			clickableWhenViewportHidden,
			{broadcastChange = true}
		)
	end

	function sharedToolbarApi.setIconRamp(
		buttonId: string,
		iconRamp: IconRamp.IconRamp
	): ()
		setButtonIconRamp(
			thisStableId,
			buttonId,
			iconRamp,
			{broadcastChange = true}
		)
	end

	function sharedToolbarApi.trySendButtonClick(
		peer: Interposer.Peer,
		buttonId: string
	): ()
		local stableId = stableIdFromPeer(peer)
		if stableId ~= nil then
			sendButtonClick(stableId, buttonId)
		end
	end

	return sharedToolbarApi
end

return SharedToolbar