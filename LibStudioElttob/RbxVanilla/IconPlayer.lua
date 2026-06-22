--!strict
-- (c) Studio Elttob 2024. All rights reserved, seek permission before use.

local ContentProvider = game:GetService("ContentProvider")
local RunService = game:GetService("RunService")

local Package = script.Parent
local LibStudioElttob = Package.Parent
local LibOpen = LibStudioElttob.Parent.LibOpen

local Event = require(LibOpen.Event)
local Fusion = require(LibOpen.Fusion)
local peek = Fusion.peek
local Children = Fusion.Children
local AnimatedIcons = require(Package.AnimatedIcons)

local TAU = 2 * math.pi

local motionActions = {
	meet = {
		oneShot = function(x: number)
			return x^2 * (6 + x*(3*x - 8))
		end,
		looping = function(x: number)
			return x
		end	
	},
	boomerang = {
		oneShot = function(x: number)
			return (1 - x)^5 * (x^2 - x^3) / 0.011124
		end,
		looping = function(x: number)
			return 1 - (math.cos(TAU * x) + 1) / 2
		end	
	},
	shake = {
		oneShot = function(x: number)
			local y = x ^ 0.7
			return math.sin(TAU * y) * math.sin(TAU/2 * y)
		end,
		looping = function(x: number)
			return math.sin(TAU * x)
		end	
	}
}

local function IconPlayer(
	scope: Fusion.Scope<typeof(Fusion)>,
	props: {
		Position: Fusion.UsedAs<UDim2>?,
		AnchorPoint: Fusion.UsedAs<Vector2>?,
		LayoutOrder: Fusion.UsedAs<number>?,
		ZIndex: Fusion.UsedAs<number>?,
		Visible: Fusion.UsedAs<boolean>?,
	
		Icon: string,
		Theme: {
			background: Fusion.UsedAs<Color3>,
			primary: Fusion.UsedAs<Color3>,
			secondary: Fusion.UsedAs<Color3>,
			overlay: Fusion.UsedAs<Color3>
		},
		Transparency: Fusion.UsedAs<number>?,
		Interruptible: Fusion.UsedAs<boolean>?,
		Looping: boolean?,
	
		AnimateEvent: Event.Connect<>?,
		Scale: Fusion.UsedAs<number>?
	}
)
	local isVisible = scope:Computed(function(use)
		if use(props.Visible) == false then
			return false
		end
		return use(props.Transparency or 0) < 0.99
	end)

	local iconData = AnimatedIcons[props.Icon] :: AnimatedIcons.AnimatedIcon
	assert(iconData ~= nil, "Animated icon data not found for " .. props.Icon)

	local progress = scope:Value(0)
	local showFallback = scope:Computed(function(use)
		return use(progress) <= 0 or use(progress) >= 1
	end)
	local isRunning = false

	if props.AnimateEvent ~= nil then
		table.insert(
			scope,
			props.AnimateEvent(function()
				if props.Looping then
					return
				end
				if isRunning then
					if peek(props.Interruptible) then
						progress:set(0)
					end
				else
					isRunning = true
					task.spawn(function()
						RunService.RenderStepped:Wait()
						while isRunning do
							local deltaTime = RunService.RenderStepped:Wait()
							local newValue = peek(progress) + deltaTime / iconData.duration
							if newValue > 1 then
								progress:set(0)
								isRunning = false
								break
							else
								progress:set(newValue)
							end
						end
					end)
				end
			end)
		)
	end

	if props.Looping then
		isRunning = true
		task.spawn(function()
			while isRunning do
				local deltaTime = RunService.RenderStepped:Wait()
				local newValue = peek(progress) + deltaTime / iconData.duration
				progress:set(newValue % 1)
			end
		end)
	end

	table.insert(
		scope, 
		function()
			isRunning = false
		end
	)

	return scope:New "Frame" {
		Name = "IconPlayer",

		Position = props.Position,
        AnchorPoint = props.AnchorPoint,
        LayoutOrder = props.LayoutOrder,
        ZIndex = props.ZIndex,
        Visible = props.Visible,

		Size = scope:Computed(function(use)
            local scale = use(props.Scale or 16)
            return UDim2.fromOffset(scale, scale)
        end),
		BackgroundTransparency = 1,

		[Children] = {
			scope:ForPairs({"secondary", "primary", "overlay"}, function(
				use: Fusion.Use, 
				scope: typeof(scope), 
				zIndex, 
				themeColour
			)
				local fallbackUrl = iconData.fallbackUrls[themeColour :: any]
				if fallbackUrl == nil then
					return zIndex, {} :: any
				else
					return zIndex, scope:New "ImageLabel" {
						Name = "FallbackIcon_" .. themeColour,
						Size = UDim2.fromScale(1, 1),
						BackgroundTransparency = 1,
						ZIndex = zIndex,
						Visible = isVisible,
		
						Image = fallbackUrl,
						ImageColor3 = props.Theme[themeColour]
					}
				end
				
			end) :: any,

			scope:New "Frame" {
				Name = "Transparency",
				BackgroundTransparency = scope:Computed(function(use)
					return 1 - use(props.Transparency or 0)
				end),
				BackgroundColor3 = props.Theme.background,
				Size = UDim2.fromScale(1, 1),
				ZIndex = 20,
			},

			if props.AnimateEvent == nil and props.Looping ~= true then {} else {
				scope:New "ViewportFrame" {
					Name = "AnimationView",
					Size = UDim2.fromScale(1, 1),
					BackgroundColor3 = props.Theme.background,
					Visible = scope:Computed(function(use)
						return use(isVisible) and not use(showFallback)
					end),
					ZIndex = 10,
			
					CurrentCamera = scope:New "Camera" {
						CFrame = CFrame.new(0, 0, 0.5),
						FieldOfView = 90
					},
					Ambient = Color3.new(1, 1, 1),
					LightColor = Color3.new(0, 0, 0),
			
					[Children] = scope:ForPairs(
						iconData.layers, 
						function(
							use: Fusion.Use, 
							scope: typeof(scope), 
							zIndex, 
							layerData
						)
							local currentTransform = scope:Computed(function(use)
								local motion = layerData.motion
								if motion == nil then
									return layerData.restTransform
								elseif motion.type == "simple" then
									local rest = layerData.restTransform
									local goal = motion.goalTransform
									local curves = motionActions[motion.action]
									local curve = curves[if props.Looping then "looping" else "oneShot"]
									local ratio = curve(use(progress))
									local centre = rest.centre:Lerp(goal.centre, ratio)
									local size = rest.size:Lerp(goal.size, ratio)
									local angle = (goal.angle - rest.angle) * ratio + rest.angle
									return {
										centre = centre,
										size = size,
										angle = angle
									}
								else
									error("Invalid motion type: " .. motion.type)
								end
							end)
	
							task.spawn(ContentProvider.PreloadAsync, ContentProvider, {layerData.imageUrl})
					
							return zIndex, scope:New "Part" {
								Transparency = 1,
								CFrame = scope:Computed(function(use)
									local transform = use(currentTransform)
									return CFrame.new(transform.centre.X, -transform.centre.Y, -0.005 + zIndex/1000) * CFrame.Angles(0, 0, transform.angle)
								end),
								Size = scope:Computed(function(use)
									local transform = use(currentTransform)
									return Vector3.new(transform.size.X, transform.size.Y, 0.01)
								end),
					
								[Children] = scope:New "Decal" {
									Face = "Back",
									Color3 = props.Theme[layerData.colour],
									Texture = layerData.imageUrl
								}
							}
						end
					)
				}
			}
		}
	}
end

return IconPlayer