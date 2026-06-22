--!strict
-- (c) Studio Elttob 2024. All rights reserved, seek permission before use.

local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")

local Package = script.Parent.Parent
local LibStudioElttob = Package.Parent
local LibOpen = LibStudioElttob.Parent.LibOpen

local Fusion = require(LibOpen.Fusion)
local peek = Fusion.peek

local MouseTracker = {}

function MouseTracker.viewportRoot(
	scope: Fusion.Scope<typeof(Fusion)>,
	userActive: Fusion.UsedAs<boolean>
): Fusion.StateObject<Vector2>
	local guiActive = true--getRecursiveVisible(guiObject)
	local autoActive = scope:Computed(function(use): boolean
		return use(userActive) and use(guiActive) :: any
	end)
	local position = scope:Value(Vector2.zero)
	local function updatePosition()
		position:set(UserInputService:GetMouseLocation() - (GuiService:GetGuiInset()))
	end
	updatePosition()
	local conn: RBXScriptConnection?
	local function updateActive(
		isActive: boolean
	)
		if isActive then
			if conn ~= nil then return end
			conn = UserInputService.InputChanged:Connect(function(inputObject)
				if inputObject.UserInputType == Enum.UserInputType.MouseMovement then
					updatePosition()
				end
			end)
		else
			if conn == nil then return end
			conn:Disconnect()
			conn = nil
		end
	end
	updateActive(peek(autoActive))
	table.insert(
		scope,
		{
			function()
				updateActive(false)
			end :: any,
			if typeof(autoActive) == "boolean" then {} else {
				scope:Observer(autoActive):onChange(function()
					updateActive(peek(autoActive))
				end)
			}
		}
	)
	return position
end

function MouseTracker.widgetRoot(
	scope: Fusion.Scope<typeof(Fusion)>,
	widget: PluginGui,
	userActive: Fusion.UsedAs<boolean>
): Fusion.StateObject<Vector2>
	local guiActive = true--getRecursiveVisible(guiObject)
	local autoActive = scope:Computed(function(use): boolean
		return use(userActive) and use(guiActive) :: any
	end)
	local position = scope:Value(Vector2.zero)
	local function updatePosition()
		position:set(widget:GetRelativeMousePosition())
	end
	updatePosition()
	local conn: RBXScriptConnection?
	local function updateActive(
		isActive: boolean
	)
		if isActive then
			if conn ~= nil then return end
			-- FUTURE: There aren't currently efficient methods for listening to 
			-- mouse motion in a plugin widget. If/when those arrive, this code
			-- should be adapted to use them to reduce CPU load.
			conn = RunService.RenderStepped:Connect(function(inputObject)
				updatePosition()
			end)
		else
			if conn == nil then return end
			conn:Disconnect()
			conn = nil
		end
	end
	updateActive(peek(autoActive))
	table.insert(
		scope,
		{
			function()
				updateActive(false)
			end :: any,
			if typeof(autoActive) == "boolean" then {} else {
				scope:Observer(autoActive):onChange(function()
					updateActive(peek(autoActive))
				end)
			}
		}
	)
	return position
end

function MouseTracker.relative(
	scope: Fusion.Scope<typeof(Fusion)>,
	guiObject: GuiObject,
	userActive: Fusion.UsedAs<boolean>
): Fusion.StateObject<Vector2>
	local allTrackerScopes = scope:innerScope()
	local trackerScope = allTrackerScopes:innerScope()
	local trackerPtr: Fusion.Value<Fusion.UsedAs<Vector2>> = scope:Value(Vector2.zero) :: any
	local guiActive = true--getRecursiveVisible(guiObject)
	local autoActive = scope:Computed(function(use): boolean
		return use(userActive) and use(guiActive) :: any
	end)
	local function updateTrackerPtr()
		local oldTrackerScope = trackerScope
		trackerScope = allTrackerScopes:innerScope()
		local pluginGui = guiObject:FindFirstAncestorWhichIsA("PluginGui")
		if pluginGui ~= nil then
			trackerPtr:set(MouseTracker.widgetRoot(trackerScope, pluginGui, autoActive))
		else
			trackerPtr:set(MouseTracker.viewportRoot(trackerScope, autoActive))
		end
		oldTrackerScope:doCleanup()
	end
	updateTrackerPtr()
	table.insert(
		scope,
		guiObject.AncestryChanged:Connect(updateTrackerPtr)
	)
	local relativeTo = scope:Value(Vector2.zero)
	local function updateRelativeTo()
		relativeTo:set(guiObject.AbsolutePosition)
	end
	updateRelativeTo()
	table.insert(
		scope,
		guiObject:GetPropertyChangedSignal("AbsolutePosition"):Connect(updateRelativeTo)
	)
	return scope:Computed(function(use)
		return use(use(trackerPtr)) :: Vector2 - use(relativeTo)
	end)
end

return MouseTracker