--!strict
-- (c) Studio Elttob 2024. All rights reserved, seek permission before use.

local RunService = game:GetService("RunService")

local Package = script.Parent.Parent
local LibStudioElttob = Package.Parent
local LibOpen = LibStudioElttob.Parent.LibOpen

local Fusion = require(LibOpen.Fusion)
local peek = Fusion.peek
local Children, Out = Fusion.Children, Fusion.Out

local PIP_INDICES = {}
for index = 0, 5 do
	table.insert(PIP_INDICES, index / 8)
end

local function LoadingSpinner(
	scope: Fusion.Scope<typeof(Fusion)>,
	props: {
		AnchorPoint: Fusion.UsedAs<Vector2>?,
		Position: Fusion.UsedAs<UDim2>?,
		LayoutOrder: Fusion.UsedAs<number>?,
		ZIndex: Fusion.UsedAs<number>?,
		Size: Fusion.UsedAs<UDim2>?,
		Visible: Fusion.UsedAs<boolean>?,
		
		Colour: Fusion.UsedAs<Color3>?,
		Transparency: Fusion.UsedAs<number>?,
		PipRadius: Fusion.UsedAs<number>?
	}
)
	if props.Size == nil then
		props.Size = UDim2.fromOffset(24, 24)
	end
	if props.Visible == nil then
		props.Visible = true
	end

	local shouldAnimate = scope:Computed(function(use)
		return use(props.Visible) and use(props.Transparency or 0) < 0.99
	end)

	local clockTime = scope:Value(os.clock())
	table.insert(
		scope,
		RunService.RenderStepped:Connect(function()
			if peek(shouldAnimate) then
				clockTime:set(os.clock())
			end
		end)
	)
	
	local spinnerCamera = scope:New "Camera" {
		CFrame = CFrame.lookAt(Vector3.zAxis / (-2 * math.tan(math.rad(0.5))), Vector3.zero),
		FieldOfView = 1
	}
	
	local actualSize = scope:Value(nil :: Vector2?)
	
	local pipRadius = scope:Computed(function(use)
		local actualSize = use(actualSize) or Vector2.zero
		local clampedSize = math.clamp(actualSize.X, 16, 256)
		return (9 - math.log(clampedSize, 2)) / 32
	end)

	return scope:New "ViewportFrame" {
		AnchorPoint = props.AnchorPoint,
		Position = props.Position,
		LayoutOrder = props.LayoutOrder,
		ZIndex = props.ZIndex,
		Size = props.Size,
		Visible = props.Visible,
		
		[Out "AbsoluteSize"] = actualSize,

		BackgroundTransparency = 1,
		
		CurrentCamera = spinnerCamera,
		Ambient = Color3.new(1, 1, 1),
		LightColor = Color3.new(0, 0, 0),
		
		ImageTransparency = props.Transparency,
		ImageColor3 = props.Colour,
		BackgroundColor3 = props.Colour,

		[Children] = {
			spinnerCamera :: any, 

			scope:New "UIAspectRatioConstraint" {
				AspectRatio = 1
			},

			scope:ForPairs(PIP_INDICES, function(_, scope: typeof(scope), index, pipOffset)
				local progress = scope:Computed(function(use)
					local wholeAnimProgress = (use(clockTime) * 0.75) % 1
					local individualProgress = wholeAnimProgress - pipOffset
					return individualProgress % 1
				end)
				local angle = scope:Computed(function(use)
					local progress = use(progress)
					local kineticProgress = (2 * (progress - 0.5))^7 / 2 + 0.5
					local angle = (kineticProgress + progress) * math.pi
					return angle
				end)
				return index, scope:New "Part" {
					Size = scope:Computed(function(use)
						return Vector3.new(use(pipRadius), use(pipRadius), 0.01)
					end),
					CFrame = scope:Computed(function(use)
						local angle = math.clamp(use(angle), 0, 2 * math.pi) + math.pi/2
						local radius = 0.5 - use(pipRadius)/2
						local x = math.cos(angle) * radius
						local y = math.sin(angle) * radius
						return CFrame.new(-x, -y, 0.01/2)
					end),
					Transparency = 1,

					[Children] = scope:New "Decal" {
						Texture = ""
					}
				}
			end)
		}
	}
end

return LoadingSpinner