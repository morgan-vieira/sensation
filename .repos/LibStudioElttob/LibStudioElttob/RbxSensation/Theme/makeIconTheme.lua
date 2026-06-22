--!strict
-- (c) Studio Elttob 2024. All rights reserved, seek permission before use.

local Package = script.Parent.Parent
local LibStudioElttob = Package.Parent
local LibOpen = LibStudioElttob.Parent.LibOpen

local Fusion = require(LibOpen.Fusion)
local Theme = require(Package.Theme)

export type Theme = {
	background: Fusion.UsedAs<Color3>,
	primary: Fusion.UsedAs<Color3>,
	secondary: Fusion.UsedAs<Color3>,
	overlay: Fusion.UsedAs<Color3>
}

local function makeIconTheme(
	scope: Fusion.Scope<typeof(Fusion)>,
	theme: Theme.ThemeContext,
	options: {
		background: Fusion.UsedAs<"bg" | "accentAtopBg">,
		foreground: Fusion.UsedAs<"fg" | "accent" | "grey">,
		style: Fusion.UsedAs<"trio" | "duo" | "mono">,
	}
): Theme
	local background = scope:Computed(function(use): Color3
		return 
			if use(options.background) == "bg" then 
				use(theme.bg)
			elseif use(options.background) == "accentAtopBg" then 
				use(theme.accentAtopBg)
			else 
				error("Invalid options.background") 
	end)
	local primary = scope:Computed(function(use): Color3
		return
			if use(options.background) == "bg" then 
				if use(options.foreground) == "fg" then
					use(theme.fgAtopBg)
				elseif use(options.foreground) == "accent" then
					use(theme.accentAtopBg)
				elseif use(options.foreground) == "grey" then
					use(theme.greyAtopBg)
				else
					error("Invalid options.foreground")
			elseif use(options.background) == "accentAtopBg" then 
				if use(options.foreground) == "fg" then
					use(theme.fgAtopAccentAtopBg)
				elseif use(options.foreground) == "accent" then
					use(theme.accentAtopAccentAtopBg)
				elseif use(options.foreground) == "grey" then
					use(theme.fgAtopAccentAtopBg)
				else
					error("Invalid options.foreground")
			else 
				error("Invalid options.background")
	end)
	local secondary = scope:Computed(function(use): Color3
		return
			if use(options.style) == "mono" then 
				use(primary)
			else 
				use(background):Lerp(use(primary), 0.6)
	end) 
	local overlay = scope:Computed(function(use): Color3
		return
			if use(options.style) ~= "trio" then 
				use(primary)
			elseif use(options.background) == "bg" then 
				if use(options.foreground) == "fg" then
					use(theme.accentAtopBg)
				elseif use(options.foreground) == "accent" then
					use(theme.fgAtopBg)
				elseif use(options.foreground) == "grey" then
					use(theme.accentAtopBg)
				else
					error("Invalid options.foreground")
			elseif use(options.background) == "accentAtopBg" then 
				if use(options.foreground) == "fg" then
					use(theme.accentAtopAccentAtopBg)
				elseif use(options.foreground) == "accent" then
					use(theme.fgAtopAccentAtopBg)
				elseif use(options.foreground) == "grey" then
					use(theme.fgAtopAccentAtopBg)
				else
					error("Invalid options.foreground")
			else 
				error("Invalid options.background")
	end)
	
	return {
		background = scope:Spring(background, 50),
		primary = scope:Spring(primary, 50),
		secondary = scope:Spring(secondary, 50),
		overlay = scope:Spring(overlay, 50)
	}
end

return makeIconTheme