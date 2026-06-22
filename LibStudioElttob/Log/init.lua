--!strict
-- (c) Studio Elttob 2024. All rights reserved, seek permission before use.

local Package = script
local LibStudioElttob = Package.Parent

local IsLocalDev = require(LibStudioElttob.IsLocalDev)
local emoji = require(Package.emoji)

local GUID_REGEX_UNBRACKETED = "%w%w%w%w%w%w%w%w%-%w%w%w%w%-%w%w%w%w%-%w%w%w%w%-%w%w%w%w%w%w%w%w%w%w%w%w"
local GUID_REGEX_BRACKETED = "{" .. GUID_REGEX_UNBRACKETED .. "}"

local function prettyGUID(
	guid: string
): string
	local index1 = 0
	local index2 = 0
	for index = 1, #guid do
		index1 *= string.byte("z") - string.byte("0")
		index1 += (string.byte(string.sub(guid, index, index)) - string.byte("0"))
		index1 %= #guid
		index2 *= string.byte("z") - string.byte("0")
		index2 += (string.byte(string.sub(guid, -index, -index)) - string.byte("0"))
		index2 %= #guid
	end
	return `GUID{emoji[index1]}{emoji[index2]}`
end

local function tostringAll(
	...: unknown
): {string}
	local parts: {string} = {}
	for index = 1, select("#", ...) do
		parts[index] = tostring(select(index, ...))
	end
	return parts
end

local function toLogMessage(
	tag: string, 
	...: unknown
): string
	return `[Suite] [{tag}] ` .. 
		table.concat(tostringAll(...), " ")
		:gsub(GUID_REGEX_BRACKETED, prettyGUID)
		:gsub(GUID_REGEX_UNBRACKETED, prettyGUID)
end

local Log = {}

function Log.create(
	tag: string,
	enabled: boolean
)
	local verbose = IsLocalDev and enabled 
	return {
		info = function(...)
			if verbose then
				print(toLogMessage(tag, ...))
			end
		end,
		warn = function(...)
			if verbose then
				warn(toLogMessage(tag, ...))
			end
		end
	}
end

if IsLocalDev then
	print(toLogMessage("Log", "This is a local development environment!"))
end

return Log