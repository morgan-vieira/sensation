--!strict
-- (c) Studio Elttob 2024. All rights reserved, seek permission before use.

local Package = script.Parent.Parent
local LibStudioElttob = Package.Parent
local LibOpen = LibStudioElttob.Parent.LibOpen

local Event = require(LibOpen.Event)
local Fusion = require(LibOpen.Fusion)
local peek = Fusion.peek
local Children, Out = Fusion.Children, Fusion.Out

local function TransitionBox<State, Key, ScopeMethods>(
	scope: Fusion.Scope<ScopeMethods & typeof(Fusion)>,
	props: {
		Name: Fusion.UsedAs<string?>,
		Position: Fusion.UsedAs<UDim2>?,
		AnchorPoint: Fusion.UsedAs<Vector2>?,
		Size: Fusion.UsedAs<UDim2>?,
		LayoutOrder: Fusion.UsedAs<number>?,
		ZIndex: Fusion.UsedAs<number>?,
		Visible: Fusion.UsedAs<boolean>?,

		Transition: (
			Fusion.Scope<ScopeMethods>,
			{
				Content: Fusion.Child,
				Shown: Fusion.StateObject<boolean>,
				TransitionCompleted: () -> ()
			}
		) -> Fusion.Child,

		State: Fusion.StateObject<State>,
		Key: Fusion.StateObject<Key>?,
		Render: (
			Fusion.Scope<ScopeMethods>, 
			State
		) -> Fusion.Child,
	}
)
	local keyState = props.Key or props.State

	type RenderedContent = {
		scope: Fusion.Scope<ScopeMethods & typeof(Fusion)>,
		content: Instance
	}

	local transitionBoxSize = scope:Value(Vector2.zero)
	local transitionBox = scope:New "Frame" {
		Name = props.Name or "TransitionBox",
		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		Size = props.Size,
		LayoutOrder = props.LayoutOrder,
		ZIndex = props.ZIndex,
		Visible = props.Visible,

		BackgroundTransparency = 1,
		ClipsDescendants = true,

		[Out "AbsoluteSize"] = transitionBoxSize
	}

	local contentShown = scope:Value(true)
	local onTransitionCompleted, doTransitionCompleted: () -> () = Event()
	local function renderContent(): RenderedContent
		local contentScope = scope:innerScope()
		return {
			scope = contentScope,
			content = Fusion.New(contentScope, "Frame") {
				Name = "Content",
				Parent = transitionBox,
				Size = Fusion.Computed(contentScope, function(use)
					return UDim2.fromOffset(use(transitionBoxSize).X, use(transitionBoxSize).Y)
				end),
				BackgroundTransparency = 1,
	
				[Children] = props.Transition(
					contentScope,
					{
						Content = props.Render(contentScope, peek(props.State)),
						Shown = contentShown,
						TransitionCompleted = doTransitionCompleted
					}
				)
			}
		}
	end
	local currentContent: RenderedContent = renderContent()
	local transitionDebounce = true
	table.insert(
		scope,
		{
			onTransitionCompleted(function()
				if transitionDebounce and not peek(contentShown) then
					currentContent.scope:doCleanup()
					transitionDebounce = false
					currentContent = renderContent()
					transitionDebounce = true
					contentShown:set(true)
				end
			end)
		}
	)
	scope:Observer(keyState):onChange(function()
		contentShown:set(false)
	end)
	return transitionBox
end

return TransitionBox