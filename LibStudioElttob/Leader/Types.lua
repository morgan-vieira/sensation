--!strict
-- (c) Studio Elttob 2024. All rights reserved, seek permission before use.

local Package = script.Parent
local LibStudioElttob = Package.Parent
local LibOpen = LibStudioElttob.Parent.LibOpen

local Event = require(LibOpen.Event)
local Interposer = require(LibStudioElttob.Interposer)

export type LeaderApi = {
	leader: () -> Interposer.Peer?,
	selfIsLeader: () -> boolean?,
	onLeaderChanged: Event.Connect<Interposer.Peer?>
}

return nil