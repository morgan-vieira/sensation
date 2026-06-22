--!strict
--!nolint LocalShadow
-- (c) Studio Elttob 2024. All rights reserved, seek permission before use.

local HttpService = game:GetService("HttpService")

local Package = script
local LibStudioElttob = Package.Parent
local LibOpen = LibStudioElttob.Parent.LibOpen

local ty = require(LibOpen.ty)
local Event = require(LibOpen.Event)
local Fusion = require(LibOpen.Fusion)
local peek = Fusion.peek
local Interposer = require(LibStudioElttob.Interposer)
local Leader = require(LibStudioElttob.Leader)
local SharedScreenGui = require(LibStudioElttob.SharedScreenGui)
local Types = require(Package.Types)
local MainView = require(Package.UI.MainView)

export type ActionButtonSpec = Types.ActionButtonSpec
export type SoundStyle = Types.SoundStyle
export type NotificationSpec = Types.NotificationSpec
export type NotificationStackApi = Types.NotificationStackApi

local PROTOCOL: Interposer.ProtocolDef = {
	id = `@StudioElttob/NotificationStack`,
	version = {major = 1, minor = 0, patch = 0},
	staticInfo = ty.Nil,
	events = {
		onPushNotification = {
			argumentType = ty.Struct({ exhaustive = false }, {
				notification = Types.Notification
			})
		},
		onPopNotification = {
			argumentType = ty.Struct({ exhaustive = false }, {
				notificationId = ty.String
			})
		},
		onActionInvoked = {
			argumentType = ty.Struct({ exhaustive = false }, {
				notificationId = ty.String,
				actionId = ty.String
			})
		}
	},
	requests = {}
}

local NotificationStack = {}

function NotificationStack.connect<MainViewData>(
	scope: Fusion.Scope<typeof(Fusion)>,
	interposer: Interposer.InterposerApi,
	leader: Leader.LeaderApi
): Types.NotificationStackApi
	local onNotificationPopped, doNotificationPopped: (string) -> () = Event()
	local onActionInvoked, doActionInvoked: (string) -> () = Event()

	local protocolApi: Interposer.ProtocolApi<nil>

	local activeNotifications = scope:Value({})

	local function tryPushNotification(
		notification: Types.Notification,
		options: {
			broadcastChange: boolean
		}
	): boolean
		local notifications = peek(activeNotifications)
		if notifications[notification.id] ~= nil then
			return false
		end
		notifications[notification.id] = notification
		activeNotifications:set(notifications)
		if options.broadcastChange then
			protocolApi.sendEvent("onPushNotification", "everyone", {
				notification = notification
			})
		end
		return true
	end

	local function tryPopNotification(
		notificationId: string,
		options: {
			broadcastChange: boolean
		}
	): boolean
		local notifications = peek(activeNotifications)
		if notifications[notificationId] == nil then
			return false
		end
		notifications[notificationId] = nil
		activeNotifications:set(notifications)
		doNotificationPopped(notificationId)
		if options.broadcastChange then
			protocolApi.sendEvent("onPopNotification", "everyone", {
				notificationId = notificationId
			})
		end
		return true
	end

	local function tryInvokeAction(
		notificationId: string,
		actionId: string,
		invokeRemotely: boolean
	): boolean
		local notifications = peek(activeNotifications)
		local notification = notifications[notificationId]
		if notification == nil then
			return false
		end
		if notification.fromPeer == interposer.selfPeer then
			for _, button in notification.spec.actionButtons do
				if button.id == actionId then
					doActionInvoked(button.id)
				end
			end
			return true
		elseif invokeRemotely then
			protocolApi.sendEvent("onActionInvoked", notification.fromPeer, {
				notificationId = notificationId,
				actionId = actionId
			})
			return true
		else
			return false
		end
	end

	protocolApi = interposer.connectProtocol(
		scope,
		PROTOCOL,
		nil,
		{
			events = {
				onPushNotification = function(
					fromPeer: Interposer.Peer,
					args: {
						notification: Types.Notification
					}
				): ()
					tryPushNotification(args.notification, {
						broadcastChange = false
					})
				end,
				onPopNotification = function(
					fromPeer: Interposer.Peer,
					args: {
						notificationId: string
					}
				): ()
					tryPopNotification(args.notificationId, {
						broadcastChange = false
					})
				end,
				onActionInvoked = function(
					fromPeer: Interposer.Peer,
					args: {
						notificationId: string,
						actionId: string
					}
				): ()
					tryInvokeAction(args.notificationId, args.actionId, false)
				end
			},
			requests = {}
		}
	)

	SharedScreenGui.connect(
		scope,
		interposer,
		leader,
		"NotificationStack",
		{
			title = "Elttob Suite Notification Stack",
			displayOrder = 2147483647,
			zIndexBehaviour = Enum.ZIndexBehavior.Sibling,
			mainView = MainView
		},
		{
			ActiveNotifications = activeNotifications,
			PopNotification = function(notificationId)
				tryPopNotification(notificationId, {
					broadcastChange = true
				})
			end,
			InvokeAction = function(notificationId, actionId)
				tryInvokeAction(notificationId, actionId, true)
			end
		}
	)

	local notificationStackApi = {}

	function notificationStackApi.pushNotification(
		props: {
			spec: NotificationSpec,
			actionHandler: ((id: string) -> ())?,
			popHandler: (() -> ())?
		}
	): ()
		local notification: Types.Notification = {
			id = HttpService:GenerateGUID(),
			fromPeer = interposer.selfPeer,
			creationTime = os.clock(),
			spec = props.spec
		}

		local handlerScope = scope:innerScope()
		table.insert(
			handlerScope,
			onNotificationPopped(function(poppedId)
				if poppedId == notification.id then
					if props.popHandler ~= nil then
						props.popHandler()
					end
					handlerScope:doCleanup()
				end
			end)
		)

		if props.actionHandler ~= nil then
			table.insert(handlerScope, onActionInvoked(props.actionHandler))
		end

		tryPushNotification(notification, {
			broadcastChange = true
		})
	end

	return notificationStackApi
end

return NotificationStack