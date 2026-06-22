--!strict
--!nolint LocalShadow
-- (c) Studio Elttob 2024. All rights reserved, seek permission before use.

local plugin = script:FindFirstAncestorWhichIsA("Plugin") :: Plugin

local Package = script
local LibStudioElttob = Package.Parent
local LibOpen = LibStudioElttob.Parent.LibOpen

local Fusion = require(LibOpen.Fusion)
local peek = Fusion.peek
local IsLocalDev = require(LibStudioElttob.IsLocalDev)
local IconRamp = require(LibStudioElttob.IconRamp)
local Types = require(Package.Types)

export type ToolbarButton = Types.ToolbarButton
export type OwnedToolbarApi = Types.OwnedToolbarApi

local OwnedToolbar = {}

function OwnedToolbar.create(
	toolbarScope: Fusion.Scope<typeof(Fusion)>,
	toolbarTitle: string
): Types.OwnedToolbarApi
	local toolbar = plugin:CreateToolbar(toolbarTitle)
	table.insert(toolbarScope, toolbar)

	if IsLocalDev then
		toolbar:CreateButton("Dev", "This toolbar originated from a plugin running in the local development environment", "", " ")
	end

	local buttons: {[string]: Types.ToolbarButton} = {}

	local function calcRibbonIconVariant(): IconRamp.IconVariant
		local ribbonBg = settings().Studio.Theme:GetColor(Enum.StudioStyleGuideColor.MainBackground)
		local isDark = ribbonBg.R + ribbonBg.G + ribbonBg.B < 1.5
		return if isDark then "dark" else "light"
	end
	local ribbonIconVariant = toolbarScope:Value(calcRibbonIconVariant())

	table.insert(toolbarScope, {
		settings().Studio.ThemeChanged:Connect(function()
			ribbonIconVariant:set(calcRibbonIconVariant())
		end)
	})

	local ownedToolbarApi = {}
	ownedToolbarApi.buttons = buttons

	function ownedToolbarApi.initOrReuseButton(
		id: string,
		newIconRamp: Fusion.StateObject<IconRamp.IconRamp>,
		displayNameFirstTimeOnly: string,
		toolTipFirstTimeOnly: string,
		newActive: Fusion.StateObject<boolean>,
		newClickableWhenViewportHidden: Fusion.StateObject<boolean>
	): (Types.ToolbarButton, boolean)
		local existingButton = buttons[id]
		if existingButton == nil then
			local iconRampState = toolbarScope:Value(newIconRamp)
			local activeState = toolbarScope:Value(newActive)
			local clickableWhenViewportHiddenState = toolbarScope:Value(newClickableWhenViewportHidden)
			
			local iconRampNow = toolbarScope:Computed(function(use)
				return use(use(iconRampState))
			end)
			local activeNow = toolbarScope:Computed(function(use)
				return use(use(activeState))
			end)
			local clickableWhenViewportHiddenNow = toolbarScope:Computed(function(use)
				return use(use(clickableWhenViewportHiddenState))
			end)
			local iconAssetIdNow = toolbarScope:Computed(function(use)
				local TARGET_SIZE = 64 -- 32x32 at 200% scaling
				local ramp = use(iconRampNow)
				local icon = IconRamp.selectNearestSize(ramp, TARGET_SIZE)
				assert(icon ~= nil, `No matching icon for toolbar button {id}`)
				local variant = icon.variants[use(ribbonIconVariant) :: any]
				assert(variant ~= nil, `No matching variant for toolbar button {id}`)
				return variant
			end)

			local instance = toolbar:CreateButton(
				id,
				toolTipFirstTimeOnly,
				peek(iconAssetIdNow),
				displayNameFirstTimeOnly
			)
			toolbarScope:Observer(iconAssetIdNow):onChange(function()
				instance.Icon = peek(iconAssetIdNow)
			end)
			toolbarScope:Observer(clickableWhenViewportHiddenNow):onBind(function()
				instance.ClickableWhenViewportHidden = peek(clickableWhenViewportHiddenNow)
			end)
			toolbarScope:Observer(activeNow):onBind(function()
				instance:SetActive(peek(activeNow))
			end)

			local newButton: Types.ToolbarButton = {
				instance = instance,
				iconRampState = iconRampState,
				activeState = activeState,
				clickableWhenViewportHiddenState = clickableWhenViewportHiddenState
			}
			buttons[id] = newButton
			return newButton, true
		else
			existingButton.iconRampState:set(newIconRamp)
			existingButton.activeState:set(newActive)
			existingButton.clickableWhenViewportHiddenState:set(newClickableWhenViewportHidden)
			return existingButton, false
		end
	end

	return ownedToolbarApi
end

return OwnedToolbar