--!strict
-- (c) Studio Elttob 2024. All rights reserved, seek permission before use.

local plugin = script:FindFirstAncestorWhichIsA("Plugin") :: Plugin

local Package = script
local LibStudioElttob = Package.Parent
local LibOpen = LibStudioElttob.Parent.LibOpen

local Maybe = require(LibOpen.Maybe)
local Log = require(LibStudioElttob.Log)

local logger = Log.create("Savety", true)

local KEY_LENGTH_MAX = 50
local VALUE_LENGTH_MAX = math.huge -- TODO: is there a limit?

local SAFE_STRING_REGEX = "^[%w%d%+%-_]*$"

export type KeySafe = string
export type ValueSafe = number | string | boolean | {ValueSafe} | {[string]: ValueSafe}

local function checkForCanary(): boolean
	return plugin:GetSetting("_SavetyCanaryValue") == "_SavetyCanaryValue"
end

local function tryRecordCanary(): Maybe.Maybe<nil>
	for _ = 1, 10 do
		plugin:SetSetting("_SavetyCanaryValue", "_SavetyCanaryValue")
		task.wait(0.3)
		if checkForCanary() then
			return Maybe.Some(nil)
		end
	end
	return Maybe.None "Failed to save the canary value to disk"
end

local function blockingTestIfProbablyFirstTime(): boolean
	for _ = 1, 10 do
		if checkForCanary() then
			return false
		end
		task.wait(0.3)
	end
	return true
end

local Savety = {}

function Savety.castToValueSafe(
	x: unknown
): Maybe.Maybe<ValueSafe>
	if typeof(x) == "number" or typeof(x) == "boolean" then
		return Maybe.Some(x)
	elseif typeof(x) == "string" then
		return
			if #x > VALUE_LENGTH_MAX then
				Maybe.None "String value is too long"
			elseif string.match(x, SAFE_STRING_REGEX) == nil then
				Maybe.None "Illegal characters found in string value"
			else
				Maybe.Some(x)
	elseif typeof(x) == "table" then
		if getmetatable(x :: any) ~= nil then
			return Maybe.None "Tables can't have metatables."
		end
		for key, value in pairs(x :: any) do
			local keyResult = Savety.castToKeySafe(key)
			if not keyResult.some then
				return keyResult
			end
			local valueResult = Savety.castToValueSafe(key)
			if not valueResult.some then
				return valueResult
			end
		end
		return Maybe.Some(x :: {})
	else
		return Maybe.None "Unrecognised value type"
	end
end

function Savety.castToKeySafe(
	x: unknown
): Maybe.Maybe<KeySafe>
	return 
		if typeof(x) ~= "string" then
			Maybe.None "Keys must be strings"
		elseif #x >= KEY_LENGTH_MAX then
			Maybe.None "Keys must be shorter than 50 characters"
		elseif string.match(x, SAFE_STRING_REGEX) == nil then
			Maybe.None "Illegal characters found in key"
		else
			Maybe.Some(x)
end

local initialised = false
local userConfirmed = false

function Savety.blockingInit(): Maybe.Maybe<{
	isProbablyFirstTime: boolean
}>
	if initialised then
		return Maybe.None "Already initialised"
	end
	local isProbablyFirstTime = blockingTestIfProbablyFirstTime()
	local canaryResult = tryRecordCanary()
	if not canaryResult.some then
		return canaryResult
	end
	initialised = true
	userConfirmed = not isProbablyFirstTime
	return Maybe.Some {
		isProbablyFirstTime = isProbablyFirstTime
	}
end

-- Mostly just here to encourage devs to ask users about this.
function Savety.confirmUserAcknowledgedFirstTime(
	isDefinitelyFirstTime: boolean
): boolean
	userConfirmed = true
	return isDefinitelyFirstTime
end

function Savety.tryUpdateBlocking(
	key: KeySafe,
	update: (old: ValueSafe?) -> ValueSafe?
): Maybe.Maybe<nil>
	if not initialised then
		return Maybe.None "Initialise Savety to use its functions."
	elseif not userConfirmed then
		return Maybe.None "Confirm with the user whether it's their first time before overwriting any data."
	end

	logger.info(`Updating {key} now...`)

	for attempt = 1, 10 do
		local existing = nil
		do
			local consecutiveCanary = 0
			local success = false
			for _ = 1, 10 do
				if checkForCanary() then
					consecutiveCanary += 1
					existing = plugin:GetSetting(key)
					if existing ~= nil or consecutiveCanary >= 3 then
						success = true
						break
					end
				else
					consecutiveCanary = 0
				end
				task.wait(0.1)
			end
			if not success then
				return Maybe.None "Too many unsuccessful attempts to read the value on disk"
			end
		end

		logger.info(`Discovered successfully`)

		if typeof(existing) ~= "table" or typeof(existing.__generation) ~= "number" then
			existing = {
				__generation = 0,
				__tiebreaker = math.random(),
				value = existing
			}
		end

		local updated = {
			__generation = existing.__generation + 1,
			__tiebreaker = math.random(),
			value = update(existing.value)
		}

		local success = nil
		for _ = 1, 10 do
			plugin:SetSetting(key, updated)
			task.wait(0.1)
			local readback = plugin:GetSetting(key)
			if readback == nil then
				continue
			elseif typeof(readback) ~= "table" or typeof(readback.__generation) ~= "number" then
				success = false
				break
			elseif readback.__generation == updated.__generation then
				-- let the readback differ slightly if the data was saved imprecisely
				if readback.__tiebreaker > updated.__tiebreaker + 0.0001 then
					success = false
					break
				else
					success = true
					break
				end
			else
				success = false
				break
			end
		end

		if success then
			logger.info(`Saved successfully`)
			return Maybe.Some(nil)
		else
			task.wait(0.1)
		end
	end
	return Maybe.None "Too many unsuccessful attempts to update the value on disk"
end

function Savety.tryReadBlocking(
	key: KeySafe
): Maybe.Maybe<unknown>
	if not initialised then
		return Maybe.None "Initialise Savety to use its functions."
	end

	local existing = nil
	do
		local consecutiveCanary = 0
		local success = false
		for _ = 1, 10 do
			if checkForCanary() then
				consecutiveCanary += 1
				existing = plugin:GetSetting(key)
				if existing ~= nil or consecutiveCanary >= 3 then
					success = true
					break
				end
			else
				consecutiveCanary = 0
			end
			task.wait(0.1)
		end
		if not success then
			return Maybe.None "Too many unsuccessful attempts to read the value on disk"
		end
	end

	if typeof(existing) ~= "table" or typeof(existing.__generation) ~= "number" then
		return Maybe.Some(existing)
	else
		return Maybe.Some(existing.value)
	end
end

return Savety