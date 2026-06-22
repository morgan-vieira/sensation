--!strict
-- (c) Studio Elttob 2024. All rights reserved, seek permission before use.

local Package = script.Parent.Parent
local LibStudioElttob = Package.Parent
local LibOpen = LibStudioElttob.Parent.LibOpen

local Fusion = require(LibOpen.Fusion)
local peek = Fusion.peek
local MouseTracker = require(Package.Input.MouseTracker)
local MousePredictor = require(Package.Input.MousePredictor)

local OnHover = {}
OnHover.type = "SpecialKey"
OnHover.kind = "OnHover"
OnHover.stage = "observer"

local function applyImpl(
	scope: Fusion.Scope<typeof(Fusion)>,
	callback: (
		hoverScope: Fusion.Scope<typeof(Fusion)>,
		predictor: MousePredictor.Predictor
	) -> (),
	relativeTo: GuiObject
): ()
	local absSize = scope:Value(relativeTo.AbsoluteSize)
	table.insert(
		scope, 
		relativeTo:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			absSize:set(relativeTo.AbsoluteSize)
		end)
	)

	local rawMousePos = MouseTracker.relative(
		scope,
		relativeTo,
		true
	)
	local predictor = MousePredictor.predict(
		scope,
		rawMousePos,
		MousePredictor.DEFAULT_PARAMS
	)
	local mousePos = predictor.predict(scope, 0)
	local isHovering = scope:Computed(function(use)
		local mousePos = use(mousePos)
		local absSize = use(absSize)
		return mousePos.X >= 0 and mousePos.Y >= 0 and mousePos.X < absSize.X and mousePos.Y < absSize.Y
	end)

	local maybeHoverScope: typeof(scope)? = nil
	scope:Observer(isHovering):onBind(function()
		local isHovering = peek(isHovering)
		if isHovering then
			if maybeHoverScope ~= nil then return end
			local hoverScope = scope:innerScope()
			maybeHoverScope = hoverScope
			callback(hoverScope, predictor)
		else
			if maybeHoverScope == nil then return end
			maybeHoverScope:doCleanup()
			maybeHoverScope = nil
		end
	end)
end

function OnHover:apply(
	scope: Fusion.Scope<typeof(Fusion)>,
	callback: any,
	applyTo: Instance
): ()
	assert(typeof(callback) == "function")
	assert(applyTo:IsA("GuiObject"))
	applyImpl(scope, callback, applyTo)
end

return OnHover :: any