--!strict
-- (c) Studio Elttob 2024. All rights reserved, seek permission before use.

local plugin = script:FindFirstAncestorWhichIsA("Plugin") :: Plugin

local Package = script
local LibStudioElttob = Package.Parent
local LibOpen = LibStudioElttob.Parent.LibOpen

local Fusion = require(LibOpen.Fusion)
local scoped, doCleanup = Fusion.scoped, Fusion.doCleanup
local Event = require(LibOpen.Event)
local PushPull = require(LibOpen.PushPull)
local Permissioned = require(LibOpen.Permissioned)
local ProductDiscovery = require(LibStudioElttob.ProductDiscovery)
local TransientWidget = require(LibStudioElttob.TransientWidget)
local MainView = require(Package.MainView)

local ALWAYS_ASK_TO_GRANT = false

local PermissionFlow = {}

local function hasBeenGrantedBefore(
	productId: string,
	grantInfo: Permissioned.GrantInfo
): boolean
	return not ALWAYS_ASK_TO_GRANT and plugin:GetSetting(`perm/{productId}/{grantInfo.id}`) == true
end

local function setHasBeenGrantedBefore(
	productId: string,
	grantInfo: Permissioned.GrantInfo,
	isGranted: boolean
): ()
	plugin:SetSetting(`perm/{productId}/{grantInfo.id}`, isGranted)
end

function PermissionFlow.grantRequired(
	productId: string,
	productInfo: ProductDiscovery.ProductInfo
): Permissioned.Grant
	return function<Return>(grantInfo, invoke, ...): Return
		if hasBeenGrantedBefore(productId, grantInfo) then
			local attempt = invoke(...) :: any
			if attempt.allowed then
				return attempt.value
			end
		end
		setHasBeenGrantedBefore(productId, grantInfo, false)

		local argumentPack = table.pack(...)

		local scope = scoped(Fusion)
		plugin.Unloading:Connect(function()
			doCleanup(scope)
		end)

		local pushResult, pullResult: () -> Return = PushPull.yield()

		local onReject, doReject: () -> () = Event()
		local onAttemptRequest, doAttemptRequest: () -> () = Event()
		local onAttemptSkip, doAttemptSkip: () -> () = Event()

		
		local widget = TransientWidget.show(
			scope,
			{
				title = `{productInfo.displayName} needs permission`,
				info = DockWidgetPluginGuiInfo.new(
					Enum.InitialDockState.Float,
					true,
					true,
					300,
					350,
					224,
					200
				),
				zIndexBehaviour = Enum.ZIndexBehavior.Sibling,
				mainView = MainView
			},
			{
				ProductInfo = productInfo,
				GrantInfo = grantInfo,
				Required = true,
				RejectedEvent = onReject,
				AttemptSkipEvent = onAttemptSkip,
		
				OnRequestPermission = doAttemptRequest,
				OnSkip = doAttemptSkip
			}
		)

		table.insert(scope,
			{
				widget.onChangeVisible(function()
					widget.setVisible(true)
					doAttemptSkip()
				end),
				onAttemptRequest(function()
					local attemptResult = (invoke :: any)(table.unpack(argumentPack, 1, argumentPack.n)) :: Permissioned.Permissioned<Return>
					if attemptResult.allowed then
						pushResult(attemptResult.value)
					else
						doReject()
					end
				end)
			}
		)

		local result = pullResult()
		doCleanup(scope)
		setHasBeenGrantedBefore(productId, grantInfo, true)
		return result
	end
end

function PermissionFlow.grantOptional(
	productId: string,
	productInfo: ProductDiscovery.ProductInfo
): Permissioned.MaybeGrant
	return function<Return>(grantInfo, invoke, ...): Permissioned.Permissioned<Return>
		if hasBeenGrantedBefore(productId, grantInfo) then
			local attempt = invoke(...) :: any
			if attempt.allowed then
				return attempt.value
			end
		end
		setHasBeenGrantedBefore(productId, grantInfo, false)
		local argumentPack = table.pack(...)

		local scope = scoped(Fusion)
		plugin.Unloading:Connect(function()
			doCleanup(scope)
		end)

		local pushResult, pullResult: () -> Permissioned.Permissioned<Return> = PushPull.yield()

		local onReject, doReject: () -> () = Event()
		local onAttemptRequest, doAttemptRequest: () -> () = Event()
		local onAttemptSkip, doAttemptSkip: () -> () = Event()

		local widget = TransientWidget.show(
			scope,
			{
				title = `{productInfo.displayName} would like permission`,
				info = DockWidgetPluginGuiInfo.new(
					Enum.InitialDockState.Float,
					true,
					true,
					300,
					350,
					224,
					200
				),
				zIndexBehaviour = Enum.ZIndexBehavior.Sibling,
				mainView = MainView
			},
			{
				ProductInfo = productInfo,
				GrantInfo = grantInfo,
				Required = false,
				RejectedEvent = onReject,
				AttemptSkipEvent = onAttemptSkip,
		
				OnRequestPermission = doAttemptRequest,
				OnSkip = doAttemptSkip
			}
		)

		table.insert(scope,
			{
				widget.onChangeVisible(function()
					doAttemptSkip()
				end),
				onAttemptRequest(function()
					local attemptResult = (invoke :: any)(table.unpack(argumentPack, 1, argumentPack.n)) :: Permissioned.Permissioned<Return>
					if attemptResult.allowed then
						pushResult(attemptResult)
					else
						doReject()
					end
				end),
				onAttemptSkip(function()
					pushResult({allowed = false})
				end)
			}
		)

		local result = pullResult()
		doCleanup(scope)
		setHasBeenGrantedBefore(productId, grantInfo, result.allowed)
		return result
	end
end

return PermissionFlow