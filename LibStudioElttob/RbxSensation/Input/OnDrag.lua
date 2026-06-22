--!strict
-- (c) Studio Elttob 2024. All rights reserved, seek permission before use.

local Package = script.Parent.Parent
local LibStudioElttob = Package.Parent
local LibOpen = LibStudioElttob.Parent.LibOpen

local Fusion = require(LibOpen.Fusion)
local MouseTracker = require(Package.Input.MouseTracker)
local MousePredictor = require(Package.Input.MousePredictor)

local OnDrag = {}
OnDrag.type = "SpecialKey"
OnDrag.kind = "OnDrag"
OnDrag.stage = "observer"

local function applyImpl(
	scope: Fusion.Scope<typeof(Fusion)>,
	callback: (
		dragScope: Fusion.Scope<typeof(Fusion)>,
		predictor: MousePredictor.Predictor
	) -> (),
	relativeTo: GuiObject
): ()
	local maybeDragScope: typeof(scope)? = nil

	table.insert(
		scope, 
		relativeTo.InputBegan:Connect(function(inputObject: InputObject)
			if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
				local dragScope = scope:innerScope()
				local rawMousePos = MouseTracker.relative(
					dragScope,
					relativeTo,
					true
				)
				local predictor = MousePredictor.predict(
					dragScope,
					rawMousePos,
					MousePredictor.DEFAULT_PARAMS
				)
				table.insert(
					dragScope,
					inputObject:GetPropertyChangedSignal("UserInputState"):Connect(function()
						if
							inputObject.UserInputState == Enum.UserInputState.End or
							inputObject.UserInputState == Enum.UserInputState.Cancel
						then
							dragScope:doCleanup()
							if maybeDragScope == dragScope then
								maybeDragScope = nil
							end
						end
					end)
				)
				callback(dragScope, predictor)
			end
		end)
	)
end

function OnDrag:apply(
	scope: Fusion.Scope<typeof(Fusion)>,
	callback: any,
	applyTo: Instance
): ()
	assert(typeof(callback) == "function")
	assert(applyTo:IsA("GuiObject"))
	applyImpl(scope, callback, applyTo)
end

return OnDrag :: any