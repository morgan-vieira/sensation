--!strict
-- (c) Studio Elttob 2024. All rights reserved, seek permission before use.

local Package = script.Parent.Parent.Parent
local LibStudioElttob = Package.Parent
local LibOpen = LibStudioElttob.Parent.LibOpen

local Event = require(LibOpen.Event)
local Fusion = require(LibOpen.Fusion)
local peek = Fusion.peek

local function ManualTransition(
	creationProps: {
		TransitionCompleted: Event.Connect<()>,
		Shown: Fusion.Value<boolean>
	}
)
	return function(
		scope: Fusion.Scope<typeof(Fusion)>,
		props: {
			Content: Fusion.Child,
			Shown: Fusion.StateObject<boolean>,
			TransitionCompleted: () -> ()
		}
	)
		table.insert(scope, creationProps.TransitionCompleted(props.TransitionCompleted))
		scope:Observer(props.Shown):onBind(function()
			creationProps.Shown:set(peek(props.Shown))
		end)
		return props.Content
	end
end

return ManualTransition