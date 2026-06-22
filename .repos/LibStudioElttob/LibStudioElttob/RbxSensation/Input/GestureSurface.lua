--!strict
-- (c) Studio Elttob 2024. All rights reserved, seek permission before use.

local Package = script.Parent.Parent
local LibStudioElttob = Package.Parent
local LibOpen = LibStudioElttob.Parent.LibOpen

local Fusion = require(LibOpen.Fusion)
local peek = Fusion.peek
local Children, OnEvent, Out = Fusion.Children, Fusion.OnEvent, Fusion.Out
local Images = require(Package.Assets.Images)
local OnDrag = require(Package.Input.OnDrag)
local OnHover = require(Package.Input.OnHover)
local MousePredictor = require(Package.Input.MousePredictor)

local function GestureSurface<Methods>(
	scope: Fusion.Scope<typeof(Fusion) & Methods>,
	props: {
		Color: Fusion.UsedAs<Color3>,
		CornerRadius: Fusion.UsedAs<UDim>?,
		Enabled: Fusion.UsedAs<boolean>?,
		Activated: (
			() -> ()
		)?,
		OnHover: (
			(
				scope: Fusion.Scope<typeof(Fusion) & Methods>,
				relativePos: MousePredictor.Predictor
			) -> ()
		)?,
		OnDrag: (
			(
				scope: Fusion.Scope<typeof(Fusion) & Methods>,
				relativePos: MousePredictor.Predictor
			) -> ()
		)?,
	}
)
	local relativeHoverPos = scope:Value(Vector2.zero)
	local mouseIsHovering = scope:Value(false)
	local mouseIsPressed = scope:Value(false)
	local animMouseIsHovering = scope:Spring(scope:Computed(function(use)
		return if use(props.Enabled) ~= false and use(mouseIsHovering) then 1 else 0
	end), 50)
	local animMouseIsPressed = scope:Spring(scope:Computed(function(use)
		return if use(props.Enabled) ~= false and use(mouseIsPressed) then 1 else 0
	end), 50)
	local transparency = scope:Computed(function(use)
		local animMouseIsHovering = use(animMouseIsHovering) :: number
		local animMouseIsPressed = use(animMouseIsPressed) :: number
		local intensity = 0.5
		return 1 - (animMouseIsHovering - animMouseIsPressed ^ 2) * intensity
	end)

	local absPosition = scope:Value(nil :: Vector2?)
	local absSize = scope:Value(nil :: Vector2?)

	return scope:New "ImageButton" {
		Size = UDim2.fromScale(1, 1),
		ZIndex = 1000,
		Visible = scope:Computed(function(use)
			return use(props.Enabled) or use(transparency) > 0.01
		end),

		BackgroundTransparency = 1,

		[Out "AbsolutePosition"] = absPosition,
		[Out "AbsoluteSize"] = absSize,

		[OnHover] = function(
			scope: typeof(scope),
			predictor: MousePredictor.Predictor
		): ()
			mouseIsHovering:set(true)
			table.insert(scope, function()
				mouseIsHovering:set(false)
			end)
			local relativePos = predictor.predict(scope, 1 / 60)
			scope:Observer(relativePos):onBind(function()
				relativeHoverPos:set(peek(relativePos))
			end)
			if props.OnHover ~= nil then
				props.OnHover(scope, predictor)
			end
		end,

		[OnDrag] = function(
			scope: typeof(scope),
			predictor: MousePredictor.Predictor
		): ()
			mouseIsPressed:set(true)
			table.insert(scope, function()
				mouseIsPressed:set(false)
			end)
			if props.OnDrag ~= nil then
				props.OnDrag(scope, predictor)
			end
		end,

		[OnEvent "Activated"] = props.Activated,

		[Children] = {
			if props.CornerRadius ~= nil then {
				scope:New "UICorner" {
					CornerRadius = props.CornerRadius
				}
			} else {} :: any,

			scope:New "ViewportFrame" {
				Name = "Clip",
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
				Visible = scope:Computed(function(use)
					return use(animMouseIsHovering) > 0.01
				end),

				ImageTransparency = transparency,

				CurrentCamera = scope:New "Camera" {
					CFrame = CFrame.new(0, 0, 0.5),
					FieldOfView = 90
				},
				Ambient = Color3.new(1, 1, 1),
				LightColor = Color3.new(0, 0, 0),

				[Children] = {
					if props.CornerRadius ~= nil then {
						scope:New "UICorner" {
							CornerRadius = props.CornerRadius
						}
					} else {} :: any,

					scope:New "Part" {
						Transparency = 1,
						CFrame = scope:Computed(function(use)
							local relativeHoverPos = use(relativeHoverPos) :: Vector2
							local clipSize = use(absSize) or Vector2.zero
							local centre = (relativeHoverPos - clipSize / 2) / clipSize.Y
							return CFrame.new(centre.X, -centre.Y, -0.005)
						end),
						Size = scope:Computed(function(use)
							local animMouseIsPressed = use(animMouseIsPressed) :: number
							local clipSize = use(absSize) or Vector2.zero
							local longestSide = math.max(clipSize.X, clipSize.Y)
							local radius = longestSide * 4 * (1 - (animMouseIsPressed ^ (1/2))) / clipSize.Y
							return Vector3.new(radius, radius, 0.01)
						end),
			
						[Children] = scope:New "Decal" {
							Face = "Back",
							Color3 = scope:Computed(function(use)
								local color = use(props.Color) :: Color3
								local isDark = color.R + color.G + color.B < 1.5
								return if isDark then Color3.new(0, 0, 0) else Color3.new(1, 1, 1)
							end),
							Texture = Images.sheen
						}
					}
				}
			}
		}
	}
end

return GestureSurface