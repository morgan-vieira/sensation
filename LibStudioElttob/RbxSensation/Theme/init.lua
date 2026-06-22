--!strict
-- (c) Studio Elttob 2024. All rights reserved, seek permission before use.

local Package = script.Parent
local LibStudioElttob = Package.Parent
local LibOpen = LibStudioElttob.Parent.LibOpen

local Fusion = require(LibOpen.Fusion)
local Oklab = require(LibOpen.Oklab)

export type ThemePalette = {
	bg: {[number]: Color3},
	fgAtopBg: {[number]: Color3},
	accentAtopBg: {[number]: Color3},
	greyAtopBg: {[number]: Color3},
	fgAtopAccentAtopBg: {[number]: Color3},
	accentAtopAccentAtopBg: {[number]: Color3},
	greyAtopAccentAtopBg: {[number]: Color3},
	fgAtopGreyAtopBg: {[number]: Color3},
	pureAtopBg: {[number]: Color3},
	pureAtopAccentAtopBg: {[number]: Color3},
	pureAtopGreyAtopBg: {[number]: Color3},

	shouldInvert: {[number]: boolean}
}

export type ThemeContext = {
	palette: Fusion.UsedAs<ThemePalette>,
	zDepth: Fusion.UsedAs<number>,

	bg: Fusion.UsedAs<Color3>,
	fgAtopBg: Fusion.UsedAs<Color3>,
	accentAtopBg: Fusion.UsedAs<Color3>,
	greyAtopBg: Fusion.UsedAs<Color3>,
	fgAtopAccentAtopBg: Fusion.UsedAs<Color3>,
	accentAtopAccentAtopBg: Fusion.UsedAs<Color3>,
	greyAtopAccentAtopBg: Fusion.UsedAs<Color3>,
	fgAtopGreyAtopBg: Fusion.UsedAs<Color3>,
	pureAtopBg: Fusion.UsedAs<Color3>,
	pureAtopAccentAtopBg: Fusion.UsedAs<Color3>,
	pureAtopGreyAtopBg: Fusion.UsedAs<Color3>,

	shouldInvert: Fusion.UsedAs<boolean>
}

-- To ensure sufficient contrast between foreground and background elements even
-- at small sizes, their Oklch luminances should remain this distance apart.
-- This is roughly set by the WCAG2 AAA contrast ratio.
local _LOW_CONTRAST_DISTANCE = 0.55
-- Ideally however, more contrast is desirable to make content more easily
-- readable. However, if too much contrast is used, then eye strain can occur.
-- To balance these factors, this sets a target distance that provides greater
-- contrast without going too far.
local HIGH_CONTRAST_DISTANCE = 0.7
-- At what lightness is dark text going to be more readable than light text?
local FG_SWITCH_POINT = 0.65

local MIN_Z_DEPTH = -10
local MAX_Z_DEPTH = 10

local function calcBackgroundOklch(
	baseLightness: number,
	zDepth: number
)
	local lightness = baseLightness + zDepth * 0.04
	while lightness < 0 or lightness > 1 do
		if lightness > 1 then
			lightness = 1.95 - lightness
		end
		if lightness < 0 then
			lightness = 0.05 - lightness
		end
	end
	return Vector3.new(lightness, 0, 0)
end

local function calcShouldInvert(
	backgroundOklch: Vector3
): boolean
	return backgroundOklch.X > FG_SWITCH_POINT
end

local function calcForegroundOklch(
	backgroundOklch: Vector3
): Vector3
	if calcShouldInvert(backgroundOklch) then
		return Vector3.new(math.max(0, backgroundOklch.X - HIGH_CONTRAST_DISTANCE), 0, 0)
	else
		return Vector3.new(math.min(1, backgroundOklch.X + HIGH_CONTRAST_DISTANCE), 0, 0)
	end
end

local function calcAccentOklch(
	backgroundOklch: Vector3,
	hue: number
): Vector3
	local baseLightness = backgroundOklch.X

	if baseLightness > FG_SWITCH_POINT then
		return Vector3.new(math.clamp(0.55 + (baseLightness - 0.94) / 2, 0, 1), 0.15, hue)
	else
		return Vector3.new(math.clamp(0.8 + (baseLightness - 0.24) / 2, 0, 1), 0.15, hue)
	end
end

local function calcGreyOklch(
	backgroundOklch: Vector3
): Vector3
	local baseLightness = backgroundOklch.X

	if baseLightness > FG_SWITCH_POINT then
		return Vector3.new(math.clamp(0.55 + (baseLightness - 0.94) / 2, 0, 1), 0, 0)
	else
		return Vector3.new(math.clamp(0.8 + (baseLightness - 0.24) / 2, 0, 1), 0, 0)
	end
end

local function calcPureOklch(
	backgroundOklch: Vector3
): Vector3
	if calcShouldInvert(backgroundOklch) then
		return Vector3.new(0.05, 0, 0)
	else
		return Vector3.new(1, 0, 0)
	end
end

local function oklchToColor3(
	oklch: Vector3
): Color3
	return Oklab.linear_srgb_to_color3(
		Oklab.oklab_to_linear_srgb(
			Oklab.oklch_to_oklab(
				oklch
			)
		)
	)
end

local Theme = {}

Theme.palette = {}

function Theme.palette.create(
	baseLightness: number,
	accentHue: number
): ThemePalette
	local palette = {
		bg = {},
		fgAtopBg = {},
		accentAtopBg = {},
		greyAtopBg = {},
		fgAtopAccentAtopBg = {},
		accentAtopAccentAtopBg = {},
		greyAtopAccentAtopBg = {},
		fgAtopGreyAtopBg = {},
		pureAtopBg = {},
		pureAtopAccentAtopBg = {},
		pureAtopGreyAtopBg = {},

		shouldInvert = {}
	}
	for zDepth = MIN_Z_DEPTH, MAX_Z_DEPTH do
		local bg = calcBackgroundOklch(baseLightness, zDepth)
		local fgAtopBg = calcForegroundOklch(bg)
		local accentAtopBg = calcAccentOklch(bg, accentHue)
		local greyAtopBg = calcGreyOklch(bg)
		local fgAtopAccentAtopBg = calcForegroundOklch(accentAtopBg)
		local accentAtopAccentAtopBg = calcAccentOklch(accentAtopBg, accentHue)
		local greyAtopAccentAtopBg = calcGreyOklch(accentAtopBg)
		local fgAtopGreyAtopBg = calcForegroundOklch(greyAtopBg)
		local pureAtopBg = calcPureOklch(bg)
		local pureAtopAccentAtopBg = calcPureOklch(accentAtopBg)
		local pureAtopGreyAtopBg = calcPureOklch(greyAtopBg)

		local shouldInvert = calcShouldInvert(bg)

		palette.bg[zDepth] = oklchToColor3(bg)
		palette.fgAtopBg[zDepth] = oklchToColor3(fgAtopBg)
		palette.accentAtopBg[zDepth] = oklchToColor3(accentAtopBg)
		palette.greyAtopBg[zDepth] = oklchToColor3(greyAtopBg)
		palette.fgAtopAccentAtopBg[zDepth] = oklchToColor3(fgAtopAccentAtopBg)
		palette.accentAtopAccentAtopBg[zDepth] = oklchToColor3(accentAtopAccentAtopBg)
		palette.greyAtopAccentAtopBg[zDepth] = oklchToColor3(greyAtopAccentAtopBg)
		palette.fgAtopGreyAtopBg[zDepth] = oklchToColor3(fgAtopGreyAtopBg)
		palette.pureAtopBg[zDepth] = oklchToColor3(pureAtopBg)
		palette.pureAtopAccentAtopBg[zDepth] = oklchToColor3(pureAtopAccentAtopBg)
		palette.pureAtopGreyAtopBg[zDepth] = oklchToColor3(pureAtopGreyAtopBg)

		palette.shouldInvert[zDepth] = shouldInvert
	end
	return palette
end

function Theme.palette.plugin(
	scope: Fusion.Scope<typeof(Fusion)>,
	accentHue: number
): Fusion.UsedAs<ThemePalette>
	local light = Theme.palette.create(0.92, accentHue)
	local dark = Theme.palette.create(0.3, accentHue)

	local currentPalette = scope:Value(light)
	local function updateCurrentPalette()
		local studioBG = settings().Studio.Theme:GetColor(Enum.StudioStyleGuideColor.MainBackground)
		local isDark = studioBG.R + studioBG.G + studioBG.B < 1.5
		currentPalette:set(if isDark then dark else light)
	end
	updateCurrentPalette()
	table.insert(
		scope,
		settings().Studio.ThemeChanged:Connect(updateCurrentPalette)
	)

	return scope:Computed(function(use)
		return use(currentPalette)
	end)
end

Theme.context = {}

function Theme.context.create(
	scope: Fusion.Scope<typeof(Fusion)>,
	palette: Fusion.UsedAs<ThemePalette>,
	zDepth: Fusion.UsedAs<number>
): ThemeContext
	return {
		palette = palette,
		zDepth = zDepth,

		bg = scope:Computed(function(use)
			return use(palette).bg[use(zDepth)]
		end),
		fgAtopBg = scope:Computed(function(use)
			return use(palette).fgAtopBg[use(zDepth)]
		end),
		accentAtopBg = scope:Computed(function(use)
			return use(palette).accentAtopBg[use(zDepth)]
		end),
		greyAtopBg = scope:Computed(function(use)
			return use(palette).greyAtopBg[use(zDepth)]
		end),
		fgAtopAccentAtopBg = scope:Computed(function(use)
			return use(palette).fgAtopAccentAtopBg[use(zDepth)]
		end),
		accentAtopAccentAtopBg = scope:Computed(function(use)
			return use(palette).accentAtopAccentAtopBg[use(zDepth)]
		end),
		greyAtopAccentAtopBg = scope:Computed(function(use)
			return use(palette).greyAtopAccentAtopBg[use(zDepth)]
		end),
		fgAtopGreyAtopBg = scope:Computed(function(use)
			return use(palette).fgAtopGreyAtopBg[use(zDepth)]
		end),
		pureAtopBg = scope:Computed(function(use)
			return use(palette).pureAtopBg[use(zDepth)]
		end),
		pureAtopAccentAtopBg = scope:Computed(function(use)
			return use(palette).pureAtopAccentAtopBg[use(zDepth)]
		end),
		pureAtopGreyAtopBg = scope:Computed(function(use)
			return use(palette).pureAtopGreyAtopBg[use(zDepth)]
		end),

		shouldInvert = scope:Computed(function(use)
			return use(palette).shouldInvert[use(zDepth)]
		end),
	}
end

function Theme.context.root(
	scope: Fusion.Scope<typeof(Fusion)>,
	palette: Fusion.UsedAs<ThemePalette>
): ThemeContext
	return Theme.context.create(scope, palette, 0)
end

function Theme.context.withZOffset(
	scope: Fusion.Scope<typeof(Fusion)>,
	context: ThemeContext,
	deltaZ: Fusion.UsedAs<number>
): ThemeContext
	return Theme.context.create(
		scope,
		context.palette, 
		scope:Computed(function(use)
			return math.clamp(math.floor(use(context.zDepth) :: number + use(deltaZ)), MIN_Z_DEPTH, MAX_Z_DEPTH)
		end)
	)
end

return Theme