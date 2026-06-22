--!strict
-- (c) Studio Elttob 2024. All rights reserved, seek permission before use.

local Package = script.Parent.Parent
local LibStudioElttob = Package.Parent
local LibOpen = LibStudioElttob.Parent.LibOpen

-- LibOpen
local Fusion = require(LibOpen.Fusion)
local peek = Fusion.peek
local Children = Fusion.Children

local PASSTHROUGH_TRANSPARENCY = 1/255

local function LightweightCanvas(
	scope: Fusion.Scope<typeof(Fusion)>,
	props: {
		Name: Fusion.UsedAs<string>?,
		Visible: Fusion.UsedAs<boolean>?,
		Position: Fusion.UsedAs<UDim2>?,
		AnchorPoint: Fusion.UsedAs<Vector2>?,
		Size: Fusion.UsedAs<UDim2>?,
		ZIndex: Fusion.UsedAs<number>?,
		LayoutOrder: Fusion.UsedAs<number>?,
	
		GroupTransparency: Fusion.UsedAs<number>?,
	
		CanvasOnlyChildren: any,
		PersistentChildren: any,
	}
)

	local persistent = scope:New "Frame" {
		Name = "Persistent",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		[Children] = props.PersistentChildren
	}

	local canvas = scope:New "CanvasGroup" {
		Name = "InternalCanvas",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		GroupTransparency = props.GroupTransparency,
		[Children] = props.CanvasOnlyChildren
	}

	local container = scope:New "Frame" {
		BackgroundTransparency = 1,
		Name = props.Name or "LightweightCanvas",
		Visible = props.Visible,
		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		Size = props.Size,
		ZIndex = props.ZIndex,
		LayoutOrder = props.LayoutOrder,
	}

	local displayMode = scope:Computed(function(use)
		if use(props.Visible) == false or use(props.GroupTransparency) > 0.9999 then
			return "none"
		elseif props.PersistentChildren == nil or use(props.GroupTransparency) > PASSTHROUGH_TRANSPARENCY then
			return "canvas"
		else
			return "direct"
		end
	end)
	
	scope:Observer(displayMode):onBind(function()
		if peek(displayMode) == "none" then
			persistent.Parent = nil
			canvas.Parent = nil
		elseif peek(displayMode) == "canvas" then
			canvas.Parent = container
			if props.PersistentChildren ~= nil then
				-- Because the canvas group takes a frame to render, delay
				-- the actual switch for a frame while priming the canvas
				-- with fake children to render into its texture.
				local impostor = persistent:Clone()
				impostor.Parent = canvas
				task.wait()
				-- It's possible that everything's been destroyed by now.
				pcall(function()
					if peek(displayMode) == "canvas" then
						persistent.Parent = canvas
					end
					impostor:Destroy()
				end)
			end
		elseif peek(displayMode) == "direct" then
			persistent.Parent = container
			canvas.Parent = nil
		end
	end)

	return container
end

return LightweightCanvas